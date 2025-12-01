import functions_framework
import requests
import os
import json
import base64
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
# 根据Coze API文档，使用v3/chat端点
COZE_URL = 'https://api.coze.cn/v3/chat'

@https_fn.on_request(timeout_sec=300)
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
        'Content-Type': 'application/json',  # 设置Content-Type为JSON
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
        
        # 根据Coze API文档，需要先将图片上传到服务器，获取file_id
        # 步骤1: 上传图片到Coze
        print(f"📤 Step 1: Uploading image to Coze...")
        image_content = base64_image
        if image_content.startswith('data:image'):
            # 移除data:image前缀，只保留base64数据
            image_content = image_content.split(',', 1)[1] if ',' in image_content else image_content
        
        print(f"📸 Image content length: {len(image_content)}, starts with: {image_content[:20]}...")
        
        # 初始化query_text和messages_list
        query_text = "分析图片中的食物。请返回详细的营养信息，包括重量(weight)、热量(calories)、蛋白质(protein)、脂肪(fat)、碳水(carbs)、纤维(fiber)、糖(sugar)和维生素C(vitamin_c)。同时提供一段简短的营养分析建议(nutritional_insight)。请以JSON格式输出，包含items列表和totals汇总。"
        messages_list = []
        
        # 上传图片到Coze API
        image_bytes = base64.b64decode(image_content)
        
        # Coze文件上传API (根据官方文档)
        upload_url = "https://api.coze.cn/v1/files/upload"
        upload_headers = {
            'Authorization': f'Bearer {api_key}'
        }
        
        # 准备上传文件 (根据官方文档，只需要file参数)
        files = {
            'file': ('image.jpg', image_bytes, 'image/jpeg')
        }
        
        try:
            upload_response = requests.post(
                upload_url,
                headers=upload_headers,
                files=files,
                timeout=30
            )
            
            print(f"📤 Upload response status: {upload_response.status_code}")
            print(f"📤 Upload response: {upload_response.text[:200]}")
            
            if upload_response.status_code == 200:
                upload_data = upload_response.json()
                # 根据官方文档，file_id在 response.json()["data"]["id"] 路径下
                file_id = upload_data.get('data', {}).get('id') or upload_data.get('id') or upload_data.get('file_id')
                print(f"✅ Image uploaded successfully, file_id: {file_id}")
                print(f"📋 Full upload response: {json.dumps(upload_data, indent=2)}")
                
                if file_id:
                    # 步骤2: 根据Coze API文档，使用object_string格式
                    # object_string格式：content应该是序列化的JSON字符串
                    # 格式：[{"type":"image","file_id":"..."},{"type":"text","text":"..."}]
                    object_string_content = [
                        {
                            "type": "image",
                            "file_id": file_id
                        },
                        {
                            "type": "text",
                            "text": query_text
                        }
                    ]
                    
                    # 序列化为JSON字符串
                    object_string_json = json.dumps(object_string_content, ensure_ascii=False)
                    print(f"🔗 Object string content: {object_string_json}")
                    
                    # 使用object_string格式的消息
                    messages_list = [
                        {
                            "role": "user",
                            "content": object_string_json,  # 序列化的JSON字符串
                            "content_type": "object_string"
                        }
                    ]
                else:
                    print(f"⚠️ file_id is None or empty, using text only")
                    messages_list = [
                        {
                            "role": "user",
                            "content": query_text, 
                            "content_type": "text"
                        }
                    ]
            else:
                print(f"⚠️ Image upload failed, using text only")
                # 如果上传失败，只使用文本
                messages_list = [
                    {
                        "role": "user",
                        "content": query_text, 
                        "content_type": "text"
                    }
                ]
        except Exception as e:
            print(f"⚠️ Image upload error: {e}, using text only")
            import traceback
            print(f"Traceback: {traceback.format_exc()}")
            # 如果上传失败，只使用文本
            messages_list = [
                {
                    "role": "user",
                    "content": query_text, 
                    "content_type": "text"
                }
            ]
        
        print(f"📤 Messages list: {len(messages_list)} messages")
        first_msg = messages_list[0]
        if isinstance(first_msg.get('content'), list):
            print(f"📤 First message has {len(first_msg.get('content', []))} content items")
            for i, item in enumerate(first_msg.get('content', [])):
                print(f"📤 Content item {i}: type={item.get('type')}, length={len(str(item.get('text') or item.get('image', '')))}")
        else:
            print(f"📤 First message type: {first_msg.get('content_type')}, content length: {len(str(first_msg.get('content', '')))}")
        
        # 根据Coze API v3文档，构造请求体
        coze_request_body = {
            "bot_id": bot_id_str,
            "user_id": user_id,  # 使用user_id而不是user
            "stream": False,
            "auto_save_history": True,  # 保存对话记录
            "additional_messages": messages_list  # 使用additional_messages而不是messages
        }
        
        print(f"📤 Request body keys: {list(coze_request_body.keys())}")
        print(f"📤 Bot ID in request: {coze_request_body.get('bot_id')}")
        print(f"📤 Additional messages count: {len(messages_list)}")
        
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

        # 检查响应结构
        if coze_data.get('code') != 0:
            error_msg = coze_data.get('msg', 'Unknown error')
            print(f"❌ Coze API returned error: {error_msg}")
            return https_fn.Response(
                json.dumps({
                    'error': f'Coze API error: {error_msg}',
                    'code': coze_data.get('code')
                }), 
                status=500, 
                headers=response_headers
            )
        
        # 获取对话信息
        chat_data = coze_data.get('data', {})
        chat_id = chat_data.get('id')
        conversation_id = chat_data.get('conversation_id')
        status = chat_data.get('status')
        
        print(f"📋 Chat ID: {chat_id}, Conversation ID: {conversation_id}, Status: {status}")
        
        # 根据文档，如果对话未完成，需要轮询"查看对话详情"接口
        import time
        max_poll_attempts = 120  # 最多轮询120次（约2分钟）
        poll_interval = 1  # 每次间隔1秒
        poll_attempt = 0
        
        # 终态列表
        final_statuses = ['completed', 'required_action', 'canceled', 'failed']
        
        # 如果状态不是终态，进行轮询
        while status not in final_statuses and poll_attempt < max_poll_attempts:
            if status == 'in_progress':
                print(f"⏳ Chat is in progress, waiting {poll_interval} seconds before polling again... (attempt {poll_attempt + 1}/{max_poll_attempts})")
                time.sleep(poll_interval)
                
                # 调用"查看对话详情"接口
                chat_detail_url = f"https://api.coze.cn/v3/chat/retrieve"
                chat_detail_params = {
                    'chat_id': chat_id,
                    'conversation_id': conversation_id
                }
                
                print(f"📡 Polling chat detail from: {chat_detail_url}")
                chat_detail_response = requests.get(
                    chat_detail_url,
                    headers=coze_headers,
                    params=chat_detail_params,
                    timeout=30
                )
                
                if chat_detail_response.status_code == 200:
                    chat_detail_data = chat_detail_response.json()
                    if chat_detail_data.get('code') == 0:
                        chat_data = chat_detail_data.get('data', {})
                        status = chat_data.get('status')
                        print(f"📋 Updated status: {status}")
                    else:
                        print(f"⚠️ Chat detail API returned error: {chat_detail_data.get('msg')}")
                        break
                else:
                    print(f"⚠️ Failed to poll chat detail: {chat_detail_response.status_code}")
                    break
                
                poll_attempt += 1
            else:
                break
        
        if status not in final_statuses:
            print(f"⚠️ Chat did not reach final status after {poll_attempt} attempts. Current status: {status}")
            return https_fn.Response(
                json.dumps({
                    'error': f'Chat did not complete in time. Status: {status}',
                    'chat_id': chat_id,
                    'conversation_id': conversation_id,
                    'status': status
                }), 
                status=504,  # Gateway Timeout
                headers=response_headers
            )
        
        print(f"✅ Chat reached final status: {status}")
        
        # 如果对话已完成或需要操作，调用"查看对话消息详情"接口获取消息
        if status in ['completed', 'required_action'] and chat_id:
            # 调用查看对话消息详情接口
            messages_url = f"https://api.coze.cn/v3/chat/message/list"
            messages_params = {
                'chat_id': chat_id,
                'conversation_id': conversation_id
            }
            
            print(f"📡 Fetching messages from: {messages_url}")
            messages_response = requests.get(
                messages_url,
                headers=coze_headers,
                params=messages_params,
                timeout=30
            )
            
            if messages_response.status_code == 200:
                messages_data = messages_response.json()
                print(f"📦 Messages response keys: {list(messages_data.keys())}")
                if messages_data.get('code') == 0:
                    messages = messages_data.get('data', [])
                else:
                    print(f"⚠️ Messages API returned error: {messages_data.get('msg')}")
                    messages = []
            else:
                print(f"⚠️ Failed to fetch messages: {messages_response.status_code}")
                messages = []
        else:
            # 如果对话失败或取消，返回错误
            print(f"❌ Chat status is {status}, cannot fetch messages")
            messages = []
            return https_fn.Response(
                json.dumps({
                    'error': f'Chat failed or was canceled. Status: {status}',
                    'chat_id': chat_id,
                    'conversation_id': conversation_id,
                    'status': status
                }), 
                status=500, 
                headers=response_headers
            )

        # --- 4. 提取和返回结果 ---
        # 查找包含 JSON 结构的消息
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
                coze_json = json.loads(json_string)
                print(f"✅ Successfully parsed JSON from Coze response")
                
                # 转换Coze返回的格式为前端期望的格式
                # Coze格式: {"items": [{"food_name": "...", "calories": 100, "weight": "200g", "fiber_grams": 2, "sugar_grams": 1}], "totals": {...}, "nutritional_insight": "..."}
                # 前端期望: {"recognizedFoods": [{"name": "...", "calories": ..., "weight": "200g", "fiber": 2, "sugar": 1}], "nutritionalInsight": "..."}
                
                recognized_foods = []
                items = coze_json.get('items', [])
                
                for item in items:
                    food_item = {
                        "name": item.get('food_name', 'Unknown Food'),
                        "confidence": 0.9,  # 默认置信度
                        "calories": int(item.get('calories', 0)),
                        "protein": float(item.get('protein_grams', 0)),
                        "carbs": float(item.get('carbs_grams', 0)),
                        "fat": float(item.get('fat_grams', 0)),
                        "fiber": float(item.get('fiber_grams', 0)),  # 新增
                        "sugar": float(item.get('sugar_grams', 0)),  # 新增
                        "vitamin_c": float(item.get('vitamin_c_mg', 0)),  # 新增
                        "weight": item.get('weight', 'N/A')  # 新增
                    }
                    recognized_foods.append(food_item)
                
                # 如果items为空，尝试从totals中提取信息
                if not recognized_foods and 'totals' in coze_json:
                    totals = coze_json.get('totals', {})
                    if totals.get('total_calories', 0) > 0:
                        food_item = {
                            "name": "Meal",
                            "confidence": 0.9,
                            "calories": int(totals.get('total_calories', 0)),
                            "protein": float(totals.get('total_protein', 0)),
                            "carbs": float(totals.get('total_carbs', 0)),
                            "fat": float(totals.get('total_fat', 0)),
                            "fiber": float(totals.get('total_fiber', 0)),
                            "sugar": float(totals.get('total_sugar', 0)),
                            "vitamin_c": float(totals.get('total_vitamin_c', 0)),
                            "weight": "N/A"
                        }
                        recognized_foods.append(food_item)
                
                # 获取营养建议
                nutritional_insight = coze_json.get('nutritional_insight', 'Enjoy your meal!')
                
                # 构造前端期望的格式
                final_json = {
                    "recognizedFoods": recognized_foods,
                    "nutritionalInsight": nutritional_insight
                }
                
                print(f"📤 Converted to frontend format: {len(recognized_foods)} foods, insight length: {len(nutritional_insight)}")
                # 成功解析并转换，返回给前端
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
    Request (JSON): { userId: string, intake: int?, burned: int?, goal: int? }
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
        api_key, oauth_client_id, oauth_client_secret, bot_id = get_config()
        if not api_key and not bot_id:
            return https_fn.Response(json.dumps({'error': 'Server configuration error'}), status=500, headers=headers)
        
        payload = req.get_json(silent=True) or {}
        user_id = payload.get('userId') or req.args.get('userId')
        if not user_id:
            return https_fn.Response(json.dumps({'error': 'Missing userId'}), status=400, headers=headers)

        # Get current stats from request
        current_intake = payload.get('intake', 0)
        current_burned = payload.get('burned', 0)
        daily_goal = payload.get('goal', 2000)

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
            f'You are a fitness and nutrition AI coach. '
            f'User status today: Intake {current_intake} kcal / Goal {daily_goal} kcal, Burned {current_burned} kcal. '
            f'Based on this balance and recent meals/workouts, '
            'produce one concise, actionable daily suggestion. Output ONLY JSON with keys: '
            '{"id","message","timestamp","actions":[{"id","title","type"}],'
            '"suggestions":{"training":{"title","description","icon"},"diet":{"title","description","icon"}},'
            '"reasoning"}. Keep it short and practical.'
        )

        coze_request_body = {
            "bot_id": str(bot_id),
            "user_id": user_id,
            "query": system_prompt,
            "stream": False,
            "additional_messages": [
                { 
                    'role': 'user', 
                    'content': json.dumps({ 
                        'currentStats': {
                            'intake': current_intake,
                            'burned': current_burned,
                            'goal': daily_goal
                        },
                        'recentMeals': meals_ctx, 
                        'recentWorkouts': workouts_ctx 
                    }, ensure_ascii=False), 
                    'content_type': 'text' 
                }
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

        # 处理非流式响应
        messages = []
        if coze_data.get('code') == 0:
            # 需要轮询获取消息（简化起见，这里假设AI Coach响应较快，或者直接使用data中的信息如果可用）
            # 注意：实际生产环境应该像上面那样轮询
            # 这里为了保持简洁，我们尝试直接获取消息
            
            # 获取chat_id
            chat_id = coze_data.get('data', {}).get('id')
            conversation_id = coze_data.get('data', {}).get('conversation_id')
            
            # 简单轮询几次
            import time
            for _ in range(10):
                time.sleep(1)
                msgs_resp = requests.get(
                    f"https://api.coze.cn/v3/chat/message/list?chat_id={chat_id}&conversation_id={conversation_id}",
                    headers=coze_headers
                )
                if msgs_resp.status_code == 200 and msgs_resp.json().get('data'):
                    messages = msgs_resp.json().get('data', [])
                    # 检查是否有assistant的消息
                    if any(m.get('role') == 'assistant' for m in messages):
                        break
        
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
            'message': f'Today you have consumed {current_intake} kcal and burned {current_burned} kcal. Keep it up!',
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
