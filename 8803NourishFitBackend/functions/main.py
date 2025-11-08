import functions_framework
import requests
import os
import json
from firebase_admin import initialize_app
from firebase_functions import https_fn
from firebase_admin import auth as admin_auth, firestore
import datetime

# 初始化 Firebase Admin SDK (用于未来认证和配置读取)
initialize_app()

# 获取安全环境变量 (这些变量通过 firebase functions:config:set 设置)
# 注意：在 Cloud Functions 环境中，我们使用 os.environ.get 或 google.cloud.secretmanager 来获取配置
# 对于简单的配置，我们假设它们在部署时已通过 CLI 注入。
def get_config():
    """获取配置，优先使用环境变量，然后尝试从Firebase config（通过环境变量注入）"""
    # 在 Cloud Functions Gen 2 中，firebase_functions.config 不可用
    # 我们需要使用环境变量，这些变量在部署时通过 firebase.json 或 gcloud 设置
    
    # 方法1: 直接环境变量
    # 支持两种认证方式：Personal Access Token 或 OAuth
    api_key = os.environ.get('COZE_API_KEY')
    oauth_client_id = os.environ.get('COZE_OAUTH_CLIENT_ID')
    oauth_client_secret = os.environ.get('COZE_OAUTH_CLIENT_SECRET')
    bot_id = os.environ.get('BOT_ID')
    
    # 方法2: 如果不存在，尝试从Firebase config注入的环境变量（Firebase CLI会自动注入）
    # Firebase CLI会将functions.config的值注入为环境变量，格式为：FIREBASE_CONFIG_<path>
    if not api_key:
        # 尝试从Firebase config注入的环境变量获取
        firebase_config_str = os.environ.get('FIREBASE_CONFIG', '{}')
        try:
            import json
            firebase_config = json.loads(firebase_config_str)
            if 'coze' in firebase_config:
                api_key = api_key or firebase_config['coze'].get('api_key')
                oauth_client_id = oauth_client_id or firebase_config['coze'].get('oauth_client_id')
                oauth_client_secret = oauth_client_secret or firebase_config['coze'].get('oauth_client_secret')
                bot_id = bot_id or firebase_config['coze'].get('bot_id')
                print(f"✅ Loaded from FIREBASE_CONFIG environment variable")
        except Exception as e:
            print(f"⚠️ Could not parse FIREBASE_CONFIG: {e}")
    
    # 方法3: 如果还是不存在，尝试从Firebase config（通过环境变量注入）
    # 在Cloud Functions Gen 2中，Firebase config可能通过不同的环境变量注入
    if not api_key or not bot_id:
        # 尝试从环境变量获取（Firebase CLI可能会自动注入）
        # 格式可能是：FIREBASE_CONFIG_COZE_API_KEY 或类似
        api_key = api_key or os.environ.get('FIREBASE_CONFIG_COZE_API_KEY')
        bot_id = bot_id or os.environ.get('FIREBASE_CONFIG_COZE_BOT_ID')
        
        if api_key and bot_id:
            print(f"✅ Loaded from environment variables")
    
    # 方法4: 如果还是不存在，使用硬编码的值（仅用于测试，生产环境应该使用Secret Manager）
    # 注意：这个API密钥应该与Firebase config中的值保持一致
    # 优先使用PAT，如果没有PAT才使用OAuth
    if not api_key:
        api_key = api_key or "pat_rF4jcLWgwJMXrosv8sKXnG9vpyPsjbyvg0weVwjdWAdVTIBs8qy7uB0YSu7Hf8UP"
    
    if not oauth_client_id:
        oauth_client_id = oauth_client_id or "34952621309001917334706731063450.app.coze"
    
    # 确保使用中国版API端点
    print(f"🌐 Using Coze China API (coze.cn)")
    
    if not bot_id:
        bot_id = bot_id or "7562995438970863616"
    
    if not api_key and not oauth_client_id:
        print(f"⚠️ Using fallback config values (should use Secret Manager in production)")
    
    # 验证配置
    if not api_key and not oauth_client_id:
        raise ValueError("Either COZE_API_KEY or COZE_OAUTH_CLIENT_ID must be configured")
    if not bot_id or bot_id == "YOUR_FALLBACK_BOT_ID":
        raise ValueError("BOT_ID is not properly configured")
    
    print(f"✅ Final config - API Key: {api_key[:10] if api_key else 'None'}..., OAuth Client ID: {oauth_client_id[:20] if oauth_client_id else 'None'}..., Bot ID: {bot_id}")
    return api_key, oauth_client_id, oauth_client_secret, bot_id

# 在模块加载时获取配置
try:
    COZE_API_KEY, COZE_OAUTH_CLIENT_ID, COZE_OAUTH_CLIENT_SECRET, BOT_ID = get_config()
    if COZE_API_KEY:
        print(f"✅ API Key loaded: {COZE_API_KEY[:10]}...")
    if COZE_OAUTH_CLIENT_ID:
        print(f"✅ OAuth Client ID loaded: {COZE_OAUTH_CLIENT_ID[:20]}...")
    print(f"✅ Bot ID loaded: {BOT_ID}")
except Exception as e:
    print(f"❌ CRITICAL: Failed to load config: {e}")
    # 设置默认值，但会在函数调用时再次尝试加载
    COZE_API_KEY = None
    COZE_OAUTH_CLIENT_ID = None
    COZE_OAUTH_CLIENT_SECRET = None
    BOT_ID = None

# OAuth Token缓存（避免每次请求都获取新token）
_oauth_token_cache = {
    'token': None,
    'expires_at': 0
}

def get_oauth_access_token(client_id, client_secret=None):
    """获取OAuth access token"""
    global _oauth_token_cache
    
    # 检查缓存是否有效（提前5分钟刷新）
    import time
    if _oauth_token_cache['token'] and time.time() < _oauth_token_cache['expires_at'] - 300:
        print(f"✅ Using cached OAuth token")
        return _oauth_token_cache['token']
    
    # 获取新的access token
    print(f"🔄 Getting new OAuth access token...")
    # 使用中国版API端点
    token_url = "https://api.coze.cn/open_api/v2/oauth/token"
    
    # 对于device类型的客户端，可能不需要client_secret
    token_data = {
        "grant_type": "client_credentials",
        "client_id": client_id
    }
    
    if client_secret:
        token_data["client_secret"] = client_secret
    
    try:
        token_response = requests.post(
            token_url,
            json=token_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        print(f"📡 OAuth token response status: {token_response.status_code}")
        print(f"📡 OAuth token response: {token_response.text[:200]}")
        
        if token_response.status_code == 200:
            token_result = token_response.json()
            access_token = token_result.get('access_token')
            expires_in = token_result.get('expires_in', 3600)  # 默认1小时
            
            # 缓存token
            _oauth_token_cache['token'] = access_token
            _oauth_token_cache['expires_at'] = time.time() + expires_in
            
            print(f"✅ OAuth token obtained successfully")
            return access_token
        else:
            print(f"❌ Failed to get OAuth token: {token_response.status_code} - {token_response.text}")
            return None
    except Exception as e:
        print(f"❌ Error getting OAuth token: {e}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return None

# Coze Chat API URL
# 根据Coze API文档，正确的端点可能是：
# 选项1: 中国版API (使用coze.cn)
COZE_URL = 'https://api.coze.cn/open_api/v2/chat'
# 选项2: 国际版API (使用coze.com)
# COZE_URL = 'https://api.coze.com/open_api/v2/chat'
# 选项3: 使用open_api v3端点 (国际版)
# COZE_URL = 'https://api.coze.com/open_api/v3/chat'
# 选项4: 使用v3/chat端点 (国际版)
# COZE_URL = 'https://api.coze.com/v3/chat'

@https_fn.on_request()
def recognize_food_proxy(req: https_fn.Request) -> https_fn.Response:
    """
    HTTP Cloud Function 作为 Coze Agent 的代理。
    接收前端的图片 Base64 字符串，调用 Coze Agent，并返回结构化的 JSON 数据。
    """
    
    # 设置 CORS 头部 (允许前端跨域访问)
    response_headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }

    if req.method == 'OPTIONS':
        # 处理预检请求
        return https_fn.Response('', status=204, headers=response_headers)

    if req.method != 'POST':
        return https_fn.Response('Method Not Allowed. Use POST.', status=405, headers=response_headers)

    try:
        print("🚀 Function started processing request")
        
        # 确保配置已加载
        api_key, oauth_client_id, oauth_client_secret, bot_id = get_config()
        if (not api_key and not oauth_client_id) or not bot_id:
            print("❌ Configuration not loaded")
            return https_fn.Response(json.dumps({'error': 'Server configuration error'}), status=500, headers=response_headers)
        
        # 优先使用Personal Access Token (PAT)
        if api_key:
            print(f"✅ Using Personal Access Token (PAT) authentication")
            print(f"🔑 API Key: {api_key[:20]}...")
        elif oauth_client_id:
            # 如果没有PAT，尝试使用OAuth认证
            print(f"🔐 Attempting OAuth authentication with client_id: {oauth_client_id[:20]}...")
            
            access_token = get_oauth_access_token(oauth_client_id, oauth_client_secret)
            if not access_token:
                print("❌ Failed to get OAuth access token")
                return https_fn.Response(json.dumps({
                    'error': 'Failed to get OAuth access token',
                    'hint': 'Please configure COZE_API_KEY (Personal Access Token) instead'
                }), status=500, headers=response_headers)
            
            print(f"✅ Using OAuth authentication")
            api_key = access_token  # 使用OAuth token作为API key
        else:
            print("❌ No authentication method configured")
            return https_fn.Response(json.dumps({'error': 'No authentication method configured'}), status=500, headers=response_headers)
        
        # 1. 解析请求数据 (自动处理 JSON)
        request_json = req.get_json(silent=True)
        if not request_json:
            print("❌ Missing JSON request body")
            return https_fn.Response('Missing JSON request body.', status=400, headers=response_headers)
        
        print(f"📥 Received request data: {list(request_json.keys())}")

        base64_image = request_json.get('base64Image')
        user_id = request_json.get('userId')
        
        print(f"👤 User ID: {user_id}")
        print(f"📸 Image data length: {len(base64_image) if base64_image else 'None'}")
        
        if not base64_image or not user_id:
            print("❌ Missing base64Image or userId")
            return https_fn.Response('Missing base64Image or userId in request.', status=400, headers=response_headers)

        # --- 2. 构造 Coze Agent 请求体 ---
        # 确保Bot ID是字符串格式
        bot_id_str = str(bot_id)
        print(f"🔍 Using Bot ID: {bot_id_str} (type: {type(bot_id_str)})")
        
        # 构造Coze请求体
        # 根据Coze API文档，图片可能需要特定的格式
        # 尝试不同的图片传递方式
        
        # 方式1: 使用base64字符串（不带data:image前缀）
        image_content = base64_image
        if image_content.startswith('data:image'):
            # 移除data:image前缀，只保留base64数据
            image_content = image_content.split(',', 1)[1] if ',' in image_content else image_content
        
        print(f"📸 Image content length: {len(image_content)}, starts with: {image_content[:20]}...")
        
        # 构造消息列表
        # 根据Coze API文档，可能需要调整消息顺序
        # 方式1: 先发送图片，再发送文本（可能Bot需要先看到图片）
        messages_list = [
            {
                "role": "user",
                "content": image_content,
                "content_type": "image"
            },
            {
                "role": "user",
                "content": "请分析这份餐食并严格输出 JSON。", 
                "content_type": "text"
            }
        ]
        
        # 方式2: 如果上面的方式不行，可以尝试将图片和文本合并到一个消息中
        # messages_list = [
        #     {
        #         "role": "user",
        #         "content": [
        #             {
        #                 "type": "text",
        #                 "text": "请分析这份餐食并严格输出 JSON。"
        #             },
        #             {
        #                 "type": "image",
        #                 "image": image_content
        #             }
        #         ]
        #     }
        # ]
        
        # 如果上面的方式不行，可以尝试：
        # 方式2: 使用image_base64 content_type
        # messages_list.append({
        #     "role": "user",
        #     "content": image_content,
        #     "content_type": "image_base64"
        # })
        
        # 方式3: 使用image_url格式（需要先上传图片到URL）
        # messages_list.append({
        #     "role": "user",
        #     "content": {"url": image_url},
        #     "content_type": "image_url"
        # })
        
        coze_request_body = {
            "conversation_id": user_id, 
            "bot_id": bot_id_str,
            "user": user_id,
            "query": "请根据图片分析食物热量并严格输出 JSON。", # 触发 Agent 的指令
            "stream": False,
            "chat_id": user_id,  # 添加chat_id
            "messages": messages_list
        }
        
        print(f"📤 Request body keys: {list(coze_request_body.keys())}")
        print(f"📤 Bot ID in request: {coze_request_body.get('bot_id')}")
        
        # --- 3. 调用 Coze Agent API ---
        print(f"🤖 Calling Coze API at: {COZE_URL}")
        print(f"🔑 API Key being used: {api_key[:20]}...{api_key[-10:]} (length: {len(api_key)})")
        print(f"🔑 API Key full: {api_key}")  # 临时调试，确认API密钥
        
        coze_headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        
        print(f"📋 Authorization header: Bearer {api_key[:20]}...")

        coze_response = requests.post(
            COZE_URL,
            headers=coze_headers,
            json=coze_request_body,
            timeout=30 # 设置超时时间为 30 秒
        )
        
        print(f"📡 Coze API response status: {coze_response.status_code}")
        
        if coze_response.status_code != 200:
            print(f"❌ Coze API error: {coze_response.text[:500]}")
            
            # 检查是否是认证错误
            try:
                error_data = coze_response.json()
                error_code = error_data.get('code', 0)
                error_msg = error_data.get('msg', 'Unknown error')
                
                if error_code == 4101:
                    print(f"❌ Authentication error: API key is incorrect or expired")
                    return https_fn.Response(
                        json.dumps({
                            'error': 'Coze API authentication failed. The API key is incorrect or expired.',
                            'error_code': error_code,
                            'error_message': error_msg,
                            'hint': 'Please verify the COZE_API_KEY in Firebase config is correct and not expired.'
                        }), 
                        status=401, 
                        headers=response_headers
                    )
                elif error_code == 4200:
                    print(f"❌ Bot ID error: Bot does not exist or is not accessible")
                    return https_fn.Response(
                        json.dumps({
                            'error': 'Coze Bot ID does not exist or is not accessible.',
                            'error_code': error_code,
                            'error_message': error_msg,
                            'hint': 'Please verify the BOT_ID in Firebase config is correct and the bot exists in your Coze account.'
                        }), 
                        status=404, 
                        headers=response_headers
                    )
            except:
                pass
            
            return https_fn.Response(
                json.dumps({'error': f'Coze API returned status {coze_response.status_code}: {coze_response.text[:200]}'}), 
                status=503, 
                headers=response_headers
            )
        
        coze_response.raise_for_status() # 检查是否有 HTTP 错误

        coze_data = coze_response.json()
        print(f"📦 Coze API response data keys: {list(coze_data.keys())}")
        print(f"📦 Coze API response data (first 500 chars): {str(coze_data)[:500]}")

        # 检查是否是空结果
        if coze_data.get('msg_type') == 'empty result' or coze_data.get('data') == 'empty result':
            print(f"⚠️ Coze returned empty result")
            return https_fn.Response(json.dumps({
                'error': 'Coze Bot returned empty result. The bot may not be configured correctly or may not support image analysis.',
                'hint': 'Please check if the Bot is properly configured and supports image analysis.'
            }), status=500, headers=response_headers)

        # --- 4. 提取和返回结果 ---
        # 查找包含 JSON 结构的消息
        messages = coze_data.get('messages', [])
        print(f"📨 Number of messages: {len(messages)}")
        
        if messages:
            for i, msg in enumerate(messages):
                print(f"📨 Message {i}: type={msg.get('content_type')}, content_length={len(str(msg.get('content', '')))}")
                # 检查消息内容
                content = msg.get('content', '')
                if content:
                    print(f"📨 Message {i} content preview: {str(content)[:200]}")
        
        # 尝试查找包含JSON的消息
        json_message = None
        for msg in messages:
            content = msg.get('content', '')
            content_type = msg.get('content_type', '')
            # 检查是否是文本消息且包含JSON
            if content_type == 'text' and content and ('{' in str(content) or '[' in str(content)):
                json_message = msg
                break
        
        if json_message:
            json_string = json_message['content'].strip()
            print(f"📝 Found JSON message, length: {len(json_string)}")
            print(f"📝 JSON message preview: {json_string[:200]}...")
            
            # **关键步骤：解析 JSON**
            try:
                final_json = json.loads(json_string)
                print(f"✅ Successfully parsed JSON from Coze response")
                # 成功解析，返回给前端
                return https_fn.Response(json.dumps(final_json), status=200, headers=response_headers)
            except json.JSONDecodeError as e:
                print(f"❌ JSON Parsing Failed. Error: {e}")
                print(f"❌ Raw Coze Output: {json_string[:500]}")
                return https_fn.Response(json.dumps({'error': f'Coze returned invalid JSON format: {str(e)}', 'raw_content': json_string[:200]}), status=500, headers=response_headers)
        
        # 如果没有找到JSON消息，尝试返回所有消息内容
        print(f"⚠️ No JSON message found in {len(messages)} messages")
        if messages:
            all_content = []
            for msg in messages:
                content = msg.get('content', '')
                content_type = msg.get('content_type', 'unknown')
                all_content.append(f"{content_type}: {str(content)[:100]}")
            print(f"📋 All messages: {all_content}")
        
        return https_fn.Response(json.dumps({
            'error': 'Coze failed to return structured food data in message.',
            'messages_count': len(messages),
            'messages': [{'type': m.get('content_type'), 'content_preview': str(m.get('content', ''))[:100]} for m in messages[:3]]
        }), status=500, headers=response_headers)

    except requests.exceptions.RequestException as e:
        print(f"❌ Coze API Request Error: {e}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return https_fn.Response(json.dumps({'error': f'Failed to connect to Coze API: {str(e)}'}), status=503, headers=response_headers)
    except ValueError as e:
        print(f"❌ Configuration Error: {e}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return https_fn.Response(json.dumps({'error': f'Server configuration error: {str(e)}'}), status=500, headers=response_headers)
    except Exception as e:
        print(f"❌ Internal Server Error: {e}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return https_fn.Response(json.dumps({'error': f'An unexpected error occurred: {str(e)}'}), status=500, headers=response_headers)


@https_fn.on_request()
def ai_coach_suggestion(req: https_fn.Request) -> https_fn.Response:
    """
    Generate today's AI coach suggestion using Coze, with simple Firestore context.
    Request (JSON): { userId: string }
    Response (JSON): {
      id, message, timestamp, actions: [{id,title,type}], suggestions:{training:{...}, diet:{...}}, reasoning
    }
    """
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }
    if req.method == 'OPTIONS':
        return https_fn.Response('', status=204, headers=headers)
    if req.method not in ['GET', 'POST']:
        return https_fn.Response('Method Not Allowed. Use GET/POST.', status=405, headers=headers)

    try:
        # 确保配置已加载
        api_key, bot_id = get_config()
        if not api_key or not bot_id:
            return https_fn.Response(json.dumps({'error': 'Server configuration error'}), status=500, headers=headers)
        
        payload = req.get_json(silent=True) or {}
        user_id = payload.get('userId') or req.args.get('userId')
        if not user_id:
            return https_fn.Response(json.dumps({'error': 'Missing userId'}), status=400, headers=headers)

        # Fetch recent meals/workouts as lightweight context
        db = firestore.client()
        # last 3 meals
        meals_snap = db.collection('meals').where('userId', '==', user_id).order_by('timestamp', direction='DESCENDING').limit(3).get()
        meals_ctx = []
        for d in meals_snap:
            data = d.to_dict()
            items = data.get('items') or data.get('recognizedFoods') or []
            meals_ctx.append({
                'mealType': data.get('mealType'),
                'timestamp': str(data.get('timestamp')),
                'items': items[:5]
            })

        # last 3 workouts
        workouts_snap = db.collection('workouts').where('userId', '==', user_id).order_by('timestamp', direction='DESCENDING').limit(3).get()
        workouts_ctx = []
        for d in workouts_snap:
            data = d.to_dict()
            workouts_ctx.append({
                'timestamp': str(data.get('timestamp')),
                'exercises': data.get('exercises', [])[:6]
            })

        # Compose Coze request
        system_prompt = (
            'You are a fitness and nutrition AI coach. Based on the user\'s recent meals and workouts, '
            'produce one concise, actionable daily suggestion. Output ONLY JSON with keys: '
            '{"id","message","timestamp","actions":[{"id","title","type"}],'
            '"suggestions":{"training":{"title","description","icon"},"diet":{"title","description","icon"}},'
            '"reasoning"}. Keep it short and practical.'
        )

        coze_request_body = {
            'conversation_id': user_id,
            'bot_id': bot_id,
            'user': user_id,
            'query': system_prompt,
            'stream': False,
            'messages': [
                { 'role': 'user', 'content': json.dumps({ 'recentMeals': meals_ctx, 'recentWorkouts': workouts_ctx }, ensure_ascii=False), 'content_type': 'text' }
            ]
        }

        coze_headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }

        r = requests.post(COZE_URL, headers=coze_headers, json=coze_request_body, timeout=30)
        r.raise_for_status()
        coze_data = r.json()

        messages = coze_data.get('messages', [])
        json_message = next((m for m in messages if m.get('content_type') == 'text' and '{' in m.get('content', '')), None)
        if json_message:
            content = json_message['content'].strip()
            try:
                parsed = json.loads(content)
                # Fill minimal fields if missing
                parsed.setdefault('id', user_id)
                parsed.setdefault('timestamp', json.dumps(str(os.environ.get('FUNCTION_DEPLOY_TIME', ''))))
                parsed.setdefault('actions', [])
                parsed.setdefault('suggestions', {})
                return https_fn.Response(json.dumps(parsed, ensure_ascii=False), status=200, headers=headers)
            except json.JSONDecodeError:
                pass

        # Fallback suggestion
        fallback = {
            'id': user_id,
            'message': 'Add a 20-minute brisk walk and increase today\'s protein by ~15g.',
            'timestamp': 'now',
            'actions': [ { 'id': 'walk', 'title': 'Take a Walk', 'type': 'walk' } ],
            'suggestions': {
                'training': { 'title': 'Training Adjustment', 'description': 'Add 20-minute brisk walk.', 'icon': 'figure.walk' },
                'diet': { 'title': 'Diet Adjustment', 'description': 'Add 15g protein today.', 'icon': 'fork.knife' }
            },
            'reasoning': 'Fallback suggestion due to parsing.'
        }
        return https_fn.Response(json.dumps(fallback, ensure_ascii=False), status=200, headers=headers)

    except requests.exceptions.RequestException as e:
        return https_fn.Response(json.dumps({'error': f'Coze error: {e}'}), status=503, headers=headers)
    except Exception as e:
        return https_fn.Response(json.dumps({'error': f'Internal error: {e}'}), status=500, headers=headers)

# (Removed REST API router; MVP uses Firebase SDK on client. Keep only Coze proxy.)