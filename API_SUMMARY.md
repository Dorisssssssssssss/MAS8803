# NourishFit 数据访问概览（MVP：Firebase 优先）

## 📋 总览

课堂版 MVP 不再自建 REST 后端。除 Coze 图像识别通过 Cloud Function 代理外，其余功能全部直接使用 Firebase SDK（Auth + Firestore）。

---

## 🔐 1. 用户认证与管理（Firebase）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 用户注册/登录 | Firebase Auth | 直接在 iOS 调用 | Email/Password 登录注册 |
| 用户资料 | Firestore | `users/{uid}` | iOS 直接读写 |

---

## 🍎 2. 营养追踪（Firestore）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 今日卡路里/餐食 | Firestore | `meals`（按日查询聚合） | 首页卡路里卡片、今日餐食 |
| 记录食物摄入 | Firestore | `meals` | 记录一餐 |
| 拍照识别食物 | Cloud Function | `recognize_food_proxy` | 代理 Coze 分析图片 |

**关键视图**: `HomeView`, `CalendarView`

---

## 💪 3. 锻炼追踪（Firestore）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 今日锻炼 | Firestore | `workouts`（按日查询） | 今日锻炼汇总 |
| 记录锻炼 | Firestore | `workouts` | 写入 exercises 列表 |
| 锻炼历史 | Firestore | `workouts`（按区间查询） | 训练时长图表 |

**关键视图**: `HomeView`, `CalendarView`

---

## 🤖 4. AI 教练（MVP）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 建议内容 | 本地示例/客户端逻辑 | - | 用于演示，非后端生成 |
| 食物识别 | Cloud Function | `recognize_food_proxy` | 代理 Coze |

**关键视图**: `HomeView`, `SuggestionsView`

**核心功能**: 这是应用的核心差异化功能，需要后端 AI 模型支持

---

## 📊 5. 进度追踪（Firestore）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 本周进度 | 客户端聚合 | `workouts`/`meals` | 客户端汇总训练天数/宏量 |
| 身体指标 | Firestore | `metrics` | 记录/查询体重、腰围 |

**关键视图**: `HomeView` (ProgressMetricsCard)

---

## 🔔 6. 通知（MVP）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 通知 | 本地示例 | - | 可选，不对后端 |

**关键视图**: `HomeView`, `SuggestionsView`, `ProfileView`

---

## 📅 7. 日历与计划（Firestore）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 日历事件 | Firestore | `calendar_events` | 读写、完成标记 |

**关键视图**: `CalendarView`

---

## 🔗 8. 数据集成（可选）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| Apple Health | iOS 本机 | - | 直接在设备侧处理 |

**关键视图**: `ProfileView`

---

## ⚙️ 9. 设置（Firestore）

| 接口 | 方法 | 端点 | 用途 |
|------|------|------|------|
| 设置 | Firestore | `users/{uid}/meta/settings` | 读写设置 |
| 导出 | 占位 | - | MVP 返回本地占位 |

**关键视图**: `ProfileView`, `SettingsView`

---

## 🔌 10. 实时（略）

| 类型 | 端点 | 用途 |
|------|------|------|
| 如需实时 | 可后续补充 | - |

**用途**: 
- 实时推送新的 AI 建议
- 实时提醒锻炼时间
- 实时同步多设备数据

---

## 📱 页面与数据源映射（MVP）

### HomeView (首页)
- 用户资料: Firestore `users/{uid}`
- 今日卡路里/餐食: Firestore `meals`（客户端聚合）
- AI 建议: 本地示例
- 周进度/历史: Firestore `workouts` + 客户端聚合

### SuggestionsView (AI 教练页)
- 建议卡片: 本地示例

### CalendarView (记录页)
- 今日营养/记录一餐: Firestore `meals`
- 拍照识别食物: Cloud Function 代理
- 今日锻炼/记录锻炼: Firestore `workouts`
- 身体指标: Firestore `metrics`

### ProfileView (个人资料页)
- 资料: Firestore `users/{uid}`
- 设置: Firestore `users/{uid}/meta/settings`

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

