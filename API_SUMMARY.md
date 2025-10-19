# NourishFit 后端 API 接口概览

## 📋 接口总览

本应用需要接入以下 **10 大类 50+ 个** 后端 API 接口。

---

## 🔐 1. 用户认证与管理 (4 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 用户注册 | POST | `/auth/register` | 新用户注册 |
| 用户登录 | POST | `/auth/login` | 用户登录获取 token |
| 获取用户资料 | GET | `/users/profile` | 获取当前用户信息 |
| 更新用户资料 | PUT | `/users/profile` | 更新用户信息（姓名、目标等）|

---

## 🍎 2. 营养追踪 (4 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取今日卡路里平衡 | GET | `/nutrition/calorie-balance/today` | 显示首页卡路里卡片 |
| 记录食物摄入 | POST | `/nutrition/meals` | 记录用户吃了什么 |
| 获取今日营养摄入 | GET | `/nutrition/meals/today` | 显示 Log 页面的营养记录 |
| 拍照识别食物 | POST | `/nutrition/food-recognition` | AI 识别食物照片 |

**关键视图**: `HomeView`, `CalendarView`

---

## 💪 3. 锻炼追踪 (4 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取今日锻炼记录 | GET | `/workouts/today` | 显示今日完成的锻炼 |
| 记录锻炼 | POST | `/workouts` | 保存用户的锻炼数据 |
| 完成锻炼项目 | PUT | `/workouts/exercises/{id}/complete` | 标记某个动作为完成 |
| 获取锻炼历史 | GET | `/workouts/history` | 获取锻炼时长图表数据 |

**关键视图**: `HomeView`, `CalendarView`

---

## 🤖 4. AI 教练建议 (5 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取今日 AI 建议 | GET | `/ai-coach/suggestions/today` | 显示 AI 教练的个性化建议 |
| 接受建议 | POST | `/ai-coach/suggestions/{id}/accept` | 用户接受 AI 建议 |
| 重新生成建议 | POST | `/ai-coach/suggestions/{id}/regenerate` | 用户要求重新生成建议 |
| 编辑建议 | PUT | `/ai-coach/suggestions/{id}` | 用户自定义修改建议 |
| 延迟建议 | POST | `/ai-coach/suggestions/{id}/delay` | 推迟建议执行 |
| 获取离线备选方案 | GET | `/ai-coach/offline-plans` | 无器械/有氧替代方案 |

**关键视图**: `HomeView`, `SuggestionsView`

**核心功能**: 这是应用的核心差异化功能，需要后端 AI 模型支持

---

## 📊 5. 进度追踪 (3 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取本周进度指标 | GET | `/progress/metrics/week` | 显示训练天数、体重变化等 |
| 记录身体指标 | POST | `/progress/body-metrics` | 记录体重、腰围等 |
| 获取身体指标历史 | GET | `/progress/body-metrics` | 查看身体数据趋势 |

**关键视图**: `HomeView` (ProgressMetricsCard)

---

## 🔔 6. 通知系统 (4 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取未读通知 | GET | `/notifications/unread` | 获取未读通知列表 |
| 标记通知为已读 | PUT | `/notifications/{id}/read` | 用户查看通知后标记 |
| 获取通知历史 | GET | `/notifications/history` | 查看所有历史通知 |
| 更新通知设置 | PUT | `/notifications/settings` | 设置通知频率、风格等 |

**关键视图**: `HomeView`, `SuggestionsView`, `ProfileView`

---

## 📅 7. 日历与计划 (3 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取日历事件 | GET | `/calendar/events` | 获取训练计划和事件 |
| 创建日历事件 | POST | `/calendar/events` | 创建新的训练计划 |
| 完成事件 | PUT | `/calendar/events/{id}/complete` | 标记事件完成 |

**关键视图**: `CalendarView`

---

## 🔗 8. 数据集成 (3 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 连接 Apple Health | POST | `/integrations/apple-health/connect` | 授权连接 Apple Health |
| 同步健康数据 | POST | `/integrations/apple-health/sync` | 同步步数、卡路里等数据 |
| 断开集成 | DELETE | `/integrations/{provider}/disconnect` | 断开第三方数据源 |

**关键视图**: `ProfileView`

---

## ⚙️ 9. 设置管理 (4 个接口)

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 获取应用设置 | GET | `/settings` | 获取所有设置项 |
| 更新设置 | PUT | `/settings` | 更新可访问性、隐私等设置 |
| 导出用户数据 | POST | `/settings/export-data` | GDPR 合规：导出用户数据 |
| 删除账户 | DELETE | `/users/account` | 永久删除用户账户 |

**关键视图**: `ProfileView`, `SettingsView`

---

## 🔌 10. WebSocket 实时通知 (1 个连接)

| 类型 | 端点 | 用途 |
|------|------|------|
| WebSocket 连接 | `ws://api.nourishfit.com/v1/ws` | 实时推送通知、建议更新等 |

**用途**: 
- 实时推送新的 AI 建议
- 实时提醒锻炼时间
- 实时同步多设备数据

---

## 📱 各页面所需 API 映射

### HomeView (首页)
- ✅ 获取用户资料
- ✅ 获取今日卡路里平衡
- ✅ 获取今日 AI 建议
- ✅ 获取本周进度指标
- ✅ 获取锻炼历史（图表）
- ✅ 获取未读通知

### SuggestionsView (AI 教练页)
- ✅ 获取今日 AI 建议
- ✅ 接受/重新生成/编辑/延迟建议
- ✅ 获取离线备选方案
- ✅ 获取通知历史

### CalendarView (记录页)
- ✅ 获取今日营养摄入
- ✅ 记录食物摄入
- ✅ 拍照识别食物
- ✅ 获取今日锻炼记录
- ✅ 记录锻炼
- ✅ 完成锻炼项目
- ✅ 记录身体指标

### ProfileView (个人资料页)
- ✅ 获取用户资料
- ✅ 更新用户资料
- ✅ 管理数据集成
- ✅ 获取/更新设置
- ✅ 导出数据
- ✅ 删除账户

---

## 🚀 实施优先级

### Phase 1: MVP 核心功能 (必须)
1. **用户认证**: 登录/注册
2. **营养追踪**: 卡路里平衡、记录食物
3. **锻炼追踪**: 记录锻炼、查看历史
4. **AI 建议**: 获取和接受建议

### Phase 2: 增强功能 (重要)
1. **进度追踪**: 身体指标、周进度
2. **通知系统**: 推送通知
3. **日历计划**: 训练计划管理

### Phase 3: 高级功能 (建议)
1. **AI 拍照识别**: 食物识别
2. **数据集成**: Apple Health 等
3. **实时通知**: WebSocket
4. **离线支持**: 本地缓存

---

## 🛠️ 技术栈建议

### 后端框架选择
- **Python**: FastAPI / Django REST Framework
- **Node.js**: Express / NestJS
- **Go**: Gin / Echo
- **Ruby**: Rails API

### 数据库
- **主数据库**: PostgreSQL
- **缓存**: Redis
- **时序数据**: InfluxDB (用于健康指标)

### AI 服务
- **GPT API**: 用于生成个性化建议
- **图像识别**: TensorFlow / PyTorch + 食物识别模型
- **推荐系统**: 基于用户历史数据的机器学习模型

### 部署
- **容器化**: Docker + Kubernetes
- **云服务**: AWS / Google Cloud / Azure
- **CDN**: CloudFlare (用于图片等静态资源)

---

## 📊 预估数据量

根据应用功能，预估每个用户的日均 API 请求：

| 场景 | 日均请求数 |
|------|-----------|
| 启动应用（加载首页数据）| 5-8 次 |
| 记录食物 | 3-6 次 |
| 记录锻炼 | 2-4 次 |
| 查看通知/建议 | 3-5 次 |
| **总计** | **13-23 次/天** |

对于 10,000 活跃用户：
- 日请求量: 130,000 - 230,000 次
- 月请求量: 约 400 万 - 700 万次

---

## 🔒 安全考虑

1. **认证**: JWT Token + Refresh Token
2. **加密**: HTTPS + 数据库字段加密
3. **限流**: 防止 API 滥用
4. **数据隐私**: GDPR 合规
5. **权限控制**: 用户只能访问自己的数据

---

## 📝 下一步行动

### 对于前端开发者（你）：
1. ✅ 阅读 `API_DOCUMENTATION.md` 了解接口详情
2. ✅ 查看 `NetworkService.swift` 了解调用方式
3. ✅ 参考 `INTEGRATION_GUIDE.md` 进行集成
4. ⏳ 根据后端进度逐步替换模拟数据

### 对于后端开发者：
1. 选择技术栈和框架
2. 设计数据库 Schema
3. 按照 Phase 1 → Phase 2 → Phase 3 顺序开发
4. 提供 Swagger/OpenAPI 文档
5. 设置测试环境供前端集成测试

---

## 📞 需要协调的事项

1. **API Base URL**: 开发、测试、生产环境的地址
2. **认证方式**: Token 格式、过期时间、刷新策略
3. **错误码规范**: 统一的错误响应格式
4. **数据格式**: 日期、时间、数字的格式约定
5. **测试账号**: 提供测试用的用户账号

---

希望这份文档能帮助你和后端团队高效协作！🎉

