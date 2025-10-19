# NourishFit 后端 API 接口文档

## 基础信息

**Base URL**: `https://api.nourishfit.com/v1`

**认证方式**: Bearer Token (JWT)

**请求头**:
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

---

## 1. 用户认证与管理

### 1.1 用户注册
```
POST /auth/register
```

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "Aiony Haust",
  "fitnessLevel": "beginner",
  "goal": "fatLoss"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

### 1.2 用户登录
```
POST /auth/login
```

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### 1.3 获取用户资料
```
GET /users/profile
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Aiony Haust",
    "email": "user@example.com",
    "fitnessLevel": "beginner",
    "goal": "fatLoss",
    "profileImage": "url",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 1.4 更新用户资料
```
PUT /users/profile
```

**请求体**:
```json
{
  "name": "Aiony Haust",
  "fitnessLevel": "intermediate",
  "goal": "muscleGain",
  "profileImage": "url"
}
```

---

## 2. 营养追踪

### 2.1 获取今日卡路里平衡
```
GET /nutrition/calorie-balance/today
```

**响应**:
```json
{
  "success": true,
  "data": {
    "date": "2024-07-15",
    "intake": 1847,
    "goal": 2100,
    "burned": 2234,
    "remaining": 253,
    "percentage": 0.88
  }
}
```

### 2.2 记录食物摄入
```
POST /nutrition/meals
```

**请求体**:
```json
{
  "mealType": "breakfast",
  "items": [
    {
      "name": "Apple",
      "quantity": 1,
      "unit": "piece",
      "calories": 95,
      "protein": 0.5,
      "carbs": 25,
      "fat": 0.3
    }
  ],
  "timestamp": "2024-07-15T08:30:00Z"
}
```

### 2.3 获取今日营养摄入记录
```
GET /nutrition/meals/today
```

**响应**:
```json
{
  "success": true,
  "data": {
    "date": "2024-07-15",
    "totalCalories": 1245,
    "goalCalories": 1800,
    "meals": [
      {
        "id": "uuid",
        "mealType": "breakfast",
        "items": [...],
        "timestamp": "2024-07-15T08:30:00Z"
      }
    ],
    "macros": {
      "protein": {
        "current": 165,
        "goal": 206,
        "percentage": 0.8
      },
      "carbs": {
        "current": 80,
        "goal": 178,
        "percentage": 0.45
      },
      "fat": {
        "current": 45,
        "goal": 69,
        "percentage": 0.65
      }
    }
  }
}
```

### 2.4 拍照识别食物
```
POST /nutrition/food-recognition
Content-Type: multipart/form-data
```

**请求体**:
```
image: [image file]
```

**响应**:
```json
{
  "success": true,
  "data": {
    "recognizedFoods": [
      {
        "name": "Apple",
        "confidence": 0.95,
        "calories": 95,
        "protein": 0.5,
        "carbs": 25,
        "fat": 0.3
      }
    ]
  }
}
```

---

## 3. 锻炼追踪

### 3.1 获取今日锻炼记录
```
GET /workouts/today
```

**响应**:
```json
{
  "success": true,
  "data": {
    "date": "2024-07-15",
    "totalDuration": 45,
    "caloriesBurned": 350,
    "exercises": [
      {
        "id": "uuid",
        "name": "Squats",
        "sets": 3,
        "reps": 12,
        "duration": 25,
        "isCompleted": true,
        "timestamp": "2024-07-15T09:00:00Z"
      }
    ]
  }
}
```

### 3.2 记录锻炼
```
POST /workouts
```

**请求体**:
```json
{
  "exercises": [
    {
      "name": "Squats",
      "sets": 3,
      "reps": 12,
      "duration": 25,
      "caloriesBurned": 120
    }
  ],
  "timestamp": "2024-07-15T09:00:00Z"
}
```

### 3.3 完成锻炼项目
```
PUT /workouts/exercises/{exerciseId}/complete
```

### 3.4 获取锻炼历史数据
```
GET /workouts/history?startDate=2024-07-01&endDate=2024-07-07
```

**响应**:
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-07-01",
      "duration": 50,
      "caloriesBurned": 400
    },
    {
      "date": "2024-07-03",
      "duration": 65,
      "caloriesBurned": 520
    }
  ]
}
```

---

## 4. AI 教练建议

### 4.1 获取今日 AI 建议
```
GET /ai-coach/suggestions/today
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "message": "You went over your target by 500 kcal last night. Recommendation: Add 20 min HIIT or 2,000 extra steps today.",
    "timestamp": "2024-07-15T07:00:00Z",
    "actions": [
      {
        "id": "uuid",
        "title": "Do HIIT",
        "type": "hiit"
      },
      {
        "id": "uuid",
        "title": "Take a Walk",
        "type": "walk"
      }
    ],
    "suggestions": {
      "training": {
        "title": "Training Adjustment",
        "description": "Reduce aerobic exercise by 20 minutes and increase strength training.",
        "icon": "dumbbell"
      },
      "diet": {
        "title": "Dietary Adjustments",
        "description": "Increase protein by 15g, reduce carbohydrates by 30g",
        "icon": "apple"
      }
    },
    "reasoning": "Based on your recent activity and nutrition data, your calorie intake exceeded your goal..."
  }
}
```

### 4.2 接受 AI 建议
```
POST /ai-coach/suggestions/{suggestionId}/accept
```

### 4.3 拒绝并重新生成建议
```
POST /ai-coach/suggestions/{suggestionId}/regenerate
```

**请求体** (可选):
```json
{
  "preferences": {
    "focusArea": "nutrition",
    "intensity": "moderate"
  }
}
```

### 4.4 编辑建议
```
PUT /ai-coach/suggestions/{suggestionId}
```

**请求体**:
```json
{
  "training": {
    "description": "Reduce aerobic exercise by 10 minutes"
  }
}
```

### 4.5 延迟建议
```
POST /ai-coach/suggestions/{suggestionId}/delay
```

**请求体**:
```json
{
  "delayUntil": "2024-07-16T07:00:00Z"
}
```

### 4.6 获取离线备选方案
```
GET /ai-coach/offline-plans
```

**响应**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "category": "equipment",
      "title": "No equipment substitution",
      "exercises": ["Push-ups", "Squats", "Plank"],
      "icon": "house"
    },
    {
      "id": "uuid",
      "category": "aerobic",
      "title": "Aerobic Substitution",
      "exercises": ["Running in place", "Jumping rope", "High knees"],
      "icon": "heart"
    }
  ]
}
```

---

## 5. 进度追踪

### 5.1 获取本周进度指标
```
GET /progress/metrics/week
```

**响应**:
```json
{
  "success": true,
  "data": {
    "trainingDays": 5,
    "totalTrainingDays": 6,
    "weightChange": -0.8,
    "planCompletion": 92,
    "macros": {
      "protein": 52,
      "carbs": 25,
      "fat": 23
    }
  }
}
```

### 5.2 记录身体指标
```
POST /progress/body-metrics
```

**请求体**:
```json
{
  "weight": 68.5,
  "waist": 74,
  "timestamp": "2024-07-15T08:00:00Z"
}
```

### 5.3 获取身体指标历史
```
GET /progress/body-metrics?period=week
```

**响应**:
```json
{
  "success": true,
  "data": {
    "period": "week",
    "metrics": [
      {
        "date": "2024-07-15",
        "weight": 68.5,
        "waist": 74
      }
    ]
  }
}
```

---

## 6. 通知系统

### 6.1 获取未读通知
```
GET /notifications/unread
```

**响应**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Workout Reminder",
      "message": "Time for your afternoon workout!",
      "timestamp": "2024-07-15T14:00:00Z",
      "isRead": false,
      "type": "workout"
    }
  ]
}
```

### 6.2 标记通知为已读
```
PUT /notifications/{notificationId}/read
```

### 6.3 获取通知历史
```
GET /notifications/history?page=1&limit=20
```

### 6.4 更新通知设置
```
PUT /notifications/settings
```

**请求体**:
```json
{
  "enabled": true,
  "workoutReminders": true,
  "frequency": "daily",
  "toneAndStyle": "encouraging"
}
```

---

## 7. 日历与计划

### 7.1 获取日历事件
```
GET /calendar/events?startDate=2024-07-01&endDate=2024-07-31
```

**响应**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Morning Run",
      "description": "30-minute morning run in the park",
      "date": "2024-07-15",
      "duration": 30,
      "type": "workout",
      "isCompleted": false
    }
  ]
}
```

### 7.2 创建日历事件
```
POST /calendar/events
```

**请求体**:
```json
{
  "title": "Morning Run",
  "description": "30-minute morning run in the park",
  "date": "2024-07-15",
  "duration": 30,
  "type": "workout"
}
```

### 7.3 更新事件完成状态
```
PUT /calendar/events/{eventId}/complete
```

---

## 8. 数据集成

### 8.1 连接 Apple Health
```
POST /integrations/apple-health/connect
```

**请求体**:
```json
{
  "authorizationCode": "apple_health_auth_code"
}
```

### 8.2 同步 Apple Health 数据
```
POST /integrations/apple-health/sync
```

### 8.3 断开数据集成
```
DELETE /integrations/{provider}/disconnect
```

---

## 9. 设置管理

### 9.1 获取应用设置
```
GET /settings
```

**响应**:
```json
{
  "success": true,
  "data": {
    "notificationsEnabled": true,
    "workoutReminders": true,
    "dataIntegration": true,
    "accessibility": {
      "voiceOverEnabled": false,
      "largeTextEnabled": false,
      "highContrastEnabled": false
    },
    "privacy": {
      "dataSharing": false,
      "analyticsEnabled": false,
      "locationServices": false
    }
  }
}
```

### 9.2 更新设置
```
PUT /settings
```

**请求体**:
```json
{
  "accessibility": {
    "largeTextEnabled": true
  }
}
```

### 9.3 导出用户数据
```
POST /settings/export-data
```

**响应**:
```json
{
  "success": true,
  "data": {
    "exportId": "uuid",
    "downloadUrl": "https://...",
    "expiresAt": "2024-07-16T00:00:00Z"
  }
}
```

### 9.4 删除账户
```
DELETE /users/account
```

---

## 10. WebSocket 实时通知

### 连接
```
ws://api.nourishfit.com/v1/ws?token={access_token}
```

### 接收消息格式
```json
{
  "type": "notification",
  "data": {
    "id": "uuid",
    "title": "New Suggestion Available",
    "message": "Your AI coach has a new suggestion for you",
    "timestamp": "2024-07-15T10:00:00Z"
  }
}
```

---

## 错误响应格式

所有 API 错误响应遵循统一格式：

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "人类可读的错误消息",
    "details": {}
  }
}
```

### 常见错误码

- `AUTH_REQUIRED` (401): 需要认证
- `FORBIDDEN` (403): 没有权限
- `NOT_FOUND` (404): 资源不存在
- `VALIDATION_ERROR` (422): 请求参数验证失败
- `SERVER_ERROR` (500): 服务器内部错误

---

## 分页

使用分页的端点遵循以下格式：

**请求参数**:
- `page`: 页码（从 1 开始）
- `limit`: 每页数量（默认 20，最大 100）

**响应格式**:
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

## 数据同步建议

1. **实时数据**: 使用 WebSocket 接收实时通知
2. **离线支持**: 本地缓存数据，在线时同步
3. **定期同步**: 每次打开 App 时同步最新数据
4. **增量同步**: 使用 `lastSyncTime` 参数只获取更新的数据

示例：
```
GET /sync/incremental?lastSyncTime=2024-07-15T10:00:00Z
```

