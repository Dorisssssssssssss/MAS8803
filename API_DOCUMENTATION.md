# NourishFit 数据与接口文档（MVP：Firebase + Cloud Function）

## 基础信息

- 认证与数据：使用 Firebase SDK（Auth + Firestore），在 iOS 客户端直接访问。
- 图像识别（Coze）：通过 Cloud Function 代理调用，隐藏第三方密钥。

---

## 1. 用户认证与管理（Firebase）

### 1.1 用户注册/登录（客户端）
- 使用 Firebase Auth（Email/Password）
- iOS：`Auth.auth().createUser` / `Auth.auth().signIn`，获取 `currentUser.uid` 与 `getIDToken()`

### 1.2 用户资料（Firestore）
- 路径：`users/{uid}`
- 字段：`name, email, fitnessLevel, goal, profileImage, createdAt, updatedAt`

---

## 2. 营养追踪（Firestore）

### 2.1 今日卡路里/餐食
- 集合：`meals`
- 查询：按 `userId` + 当天 `timestamp` 范围过滤，客户端聚合 `items[].calories`

### 2.2 记录食物摄入
- 文档示例：
```json
{
  "userId": "uid",
  "mealType": "breakfast",
  "timestamp": "Timestamp",
  "items": [ { "name": "Apple", "quantity": 1, "unit": "piece", "calories": 95, "protein": 0.5, "carbs": 25, "fat": 0.3 } ]
}
```

### 2.3 拍照识别食物（Cloud Function 代理 Coze）
- 函数：`recognize_food_proxy`（HTTP）
- 请求：`{ base64Image, userId, mealType }`
- 返回：`{ recognizedFoods: [ { name, confidence, calories, protein, carbs, fat } ] }`

---

## 3. 锻炼追踪（Firestore）

### 3.1 记录/查询锻炼
- 集合：`workouts`，字段：`userId, timestamp, exercises[], caloriesBurned`
- 今日：按天范围查询；历史：按区间范围查询并按天聚合 `duration`

---

## 4. AI 教练（MVP）
- 客户端示例内容；如需后端生成，可后续扩展。
- 食物识别通过 Cloud Function 代理 Coze。

---

## 5. 进度追踪（Firestore + 客户端聚合）
- 本周训练天数：按 `workouts` 文档日期去重计数
- 宏量：按周累加 `meals.items[*]` 的宏量
- 身体指标集合：`metrics`（`userId, timestamp, weight, waist`）

---

## 6. 通知（MVP）
- 使用本地示例或后续接入 FCM。

---

## 7. 日历与计划（Firestore）
- 集合：`calendar_events`
- 字段：`userId, title, description, date, duration, type, isCompleted`

---

## 8. 数据集成（可选）
- 在 iOS 端处理 Apple Health 授权与同步。

---

## 9. 设置（Firestore）
- 路径：`users/{uid}/meta/settings`，读写 JSON 设置对象。

---

## 10. 实时（略）
- 如需实时能力，可后续补充。

---

## 错误处理
- Firestore/Cloud Function 的错误由客户端直接捕获；不再统一 REST 错误包装。

---

## 分页与同步
- 分页：查询时使用 `limit` 与游标
- 同步：
  - 离线支持：本地缓存，在线时同步
  - 定期同步：App 启动时刷新
  - 增量同步：客户端维护 `lastSyncTime`，查询时只取最近更新

