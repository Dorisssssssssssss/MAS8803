# 集成指南（MVP：Firebase 优先）

本指南说明如何在 NourishFit 应用中集成 Firebase（Auth + Firestore）与 Cloud Function 代理（Coze）。

## 目录

1. [快速开始](#快速开始)
2. [在 ViewModel 中使用](#在-viewmodel-中使用)
3. [错误处理](#错误处理)
4. [离线支持](#离线支持)

---

## 快速开始

### 1. Firebase 控制台
- 启用 Authentication（Email/Password）
- 启用 Firestore（Production 模式），设置规则仅允许本人读写 `users/{uid}`、`meals`、`workouts`、`metrics`、`calendar_events` 等

### 2. iOS 侧添加 Firebase SDK
- 项目已通过 SPM 引入 `firebase-ios-sdk`
- 在 App 启动时配置 Firebase（`_803NourishFitApp.swift` 已包含）

### 3. Cloud Function（Coze 代理）
- 部署 `recognize_food_proxy` 函数并配置 Coze 密钥（环境变量/Functions config）

---

## 在 ViewModel 中使用

### 示例：从 Firestore 加载用户资料/餐食等

修改 `AppViewModel.swift`：

```swift
import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentTab: TabSelection = .home
    @Published var userProfile: UserProfile?
    @Published var calorieBalance: CalorieBalance?
    @Published var aiCoachTip: AICoachTip?
    @Published var progressMetrics: ProgressMetrics?
    @Published var workoutTimeData: [WorkoutTimeData] = []
    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        Publishers.Zip(
            NetworkService.shared.getUserProfile(),
            NetworkService.shared.getTodayCalorieBalance()
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion { self?.errorMessage = error.localizedDescription }
            },
            receiveValue: { [weak self] (profile, calories) in
                self?.userProfile = profile
                self?.calorieBalance = calories
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Individual Load Methods
    
    private func loadUserProfile() -> AnyPublisher<UserProfile, Error> {
        return NetworkService.shared.getUserProfile()
    }
    
    private func loadTodayCalorieBalance() -> AnyPublisher<CalorieBalance, Error> {
        return NetworkService.shared.getTodayCalorieBalance()
    }
    
    // AI 建议（MVP）：使用本地示例数据
    
    private func loadWeeklyMetrics() -> AnyPublisher<ProgressMetrics, Error> {
        return NetworkService.shared.getWeeklyMetrics()
    }
    
    private func loadWorkoutHistory() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        
        NetworkService.shared.getWorkoutHistory(
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate)
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load workout history: \(error)")
                }
            },
            receiveValue: { [weak self] data in
                self?.workoutTimeData = data
            }
        )
        .store(in: &cancellables)
    }
    
    // 通知（MVP）：使用本地示例数据
    
    // MARK: - Actions
    
    func acceptAISuggestion() {
        guard let suggestionId = aiCoachTip?.id.uuidString else { return }
        
        NetworkService.shared.acceptSuggestion(suggestionId: suggestionId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to accept suggestion: \(error)")
                    }
                },
                receiveValue: { _ in
                    print("Suggestion accepted")
                }
            )
            .store(in: &cancellables)
    }
    
    func regenerateAISuggestion() {
        guard let suggestionId = aiCoachTip?.id.uuidString else { return }
        
        NetworkService.shared.regenerateSuggestion(suggestionId: suggestionId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to regenerate suggestion: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.aiCoachTip = AICoachTip(
                        message: response.message,
                        timestamp: response.timestamp,
                        actions: response.actions
                    )
                }
            )
            .store(in: &cancellables)
    }
    
    func markNotificationAsRead(_ notification: AppNotification) {
        NetworkService.shared.markNotificationAsRead(notificationId: notification.id.uuidString)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to mark notification as read: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    if let index = self?.notifications.firstIndex(where: { $0.id == notification.id }) {
                        self?.notifications[index].isRead = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func recordMeal(mealType: String, items: [MealItem]) {
        let request = MealRequest(
            mealType: mealType,
            items: items,
            timestamp: Date()
        )
        
        NetworkService.shared.recordMeal(request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to record meal: \(error)")
                    }
                },
                receiveValue: { _ in
                    print("Meal recorded successfully")
                    // 重新加载卡路里数据
                }
            )
            .store(in: &cancellables)
    }
    
    func recordWorkout(exercises: [ExerciseRequest]) {
        let request = WorkoutRequest(
            exercises: exercises,
            timestamp: Date()
        )
        
        NetworkService.shared.recordWorkout(request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to record workout: \(error)")
                    }
                },
                receiveValue: { _ in
                    print("Workout recorded successfully")
                    // 重新加载锻炼数据
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }
}
```

---

## 错误处理

### 统一错误处理示例

```swift
class AppViewModel: ObservableObject {
    @Published var errorAlert: ErrorAlert?
    
    struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(401):
                // Token 过期，需要重新登录
                showLoginScreen()
            case .apiError(let message):
                errorAlert = ErrorAlert(
                    title: "错误",
                    message: message
                )
            default:
                errorAlert = ErrorAlert(
                    title: "网络错误",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    private func showLoginScreen() {
        // 导航到登录页面
    }
}
```

### 在 View 中显示错误

```swift
struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        // ... 视图内容
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("确定"))
            )
        }
    }
}
```

---

## 离线支持

### 实现离线缓存

```swift
class CacheManager {
    static let shared = CacheManager()
    private let userDefaults = UserDefaults.standard
    
    // 保存数据到本地
    func save<T: Codable>(_ data: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    // 从本地加载数据
    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    // 清除缓存
    func clear(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
```

### 在 ViewModel 中使用缓存

```swift
private func loadTodayCalorieBalance() -> AnyPublisher<CalorieBalance, Error> {
    // 先从缓存加载
    if let cached: CalorieBalance = CacheManager.shared.load(forKey: "calorieBalance") {
        self.calorieBalance = cached
    }
    
    // 然后从网络加载最新数据
    return NetworkService.shared.getTodayCalorieBalance()
        .handleEvents(receiveOutput: { [weak self] balance in
            // 保存到缓存
            CacheManager.shared.save(balance, forKey: "calorieBalance")
        })
        .eraseToAnyPublisher()
}
```

---

## WebSocket 实时（可选）

```swift
import Foundation
import Combine

class WebSocketManager: NSObject {
    static let shared = WebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let notificationSubject = PassthroughSubject<AppNotification, Never>()
    
    var notificationPublisher: AnyPublisher<AppNotification, Never> {
        notificationSubject.eraseToAnyPublisher()
    }
    
    func connect(token: String) {
        guard let url = URL(string: "wss://your-realtime-endpoint?token=\(token)") else {
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // 继续接收下一条消息
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let response = try? JSONDecoder().decode(WebSocketMessage.self, from: data) else {
            return
        }
        
        if response.type == "notification" {
            // 发布新通知
            notificationSubject.send(response.notification)
        }
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
    }
}

struct WebSocketMessage: Decodable {
    let type: String
    let notification: AppNotification
    
    enum CodingKeys: String, CodingKey {
        case type
        case notification = "data"
    }
}
```

### 在 ViewModel 中监听 WebSocket

```swift
class AppViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        // 连接 WebSocket
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            WebSocketManager.shared.connect(token: token)
        }
        
        // 监听实时通知
        WebSocketManager.shared.notificationPublisher
            .sink { [weak self] notification in
                self?.notifications.insert(notification, at: 0)
                // 可以显示本地通知
                self?.showLocalNotification(notification)
            }
            .store(in: &cancellables)
    }
    
    private func showLocalNotification(_ notification: AppNotification) {
        // 使用 UNUserNotificationCenter 显示本地通知
    }
}
```

---

## 推荐的开发流程

### 1. 开发阶段（使用模拟数据）

保持当前的 `loadSampleData()` 方法用于开发和测试 UI：

```swift
#if DEBUG
init() {
    loadSampleData()  // 开发时使用模拟数据
}
#else
init() {
    loadData()  // 生产环境使用真实 API
}
#endif
```

### 2. 集成阶段

逐步替换模拟数据为真实 API 调用：

1. 首先集成用户认证 API
2. 然后集成核心功能（卡路里、锻炼）
3. 最后集成辅助功能（通知、设置）

### 3. 测试阶段

- 单元测试：测试 NetworkService 的各个方法
- 集成测试：测试 ViewModel 与 API 的交互
- UI 测试：测试完整的用户流程

---

## 环境配置
不再需要 REST BaseURL。Firebase 配置由 `GoogleService-Info.plist` 提供。

---

## 性能优化建议

1. **请求去重**: 避免重复请求相同的数据
2. **批量请求**: 合并多个小请求为一个大请求
3. **请求取消**: 当视图消失时取消未完成的请求
4. **图片缓存**: 使用 URLCache 或第三方库缓存图片
5. **分页加载**: 对于列表数据使用分页加载

---

## 常见问题

### Q: 如何处理 Token 过期？

A: 在 NetworkService 中添加自动刷新 token 的逻辑：

```swift
private func refreshToken() -> AnyPublisher<AuthResponse, Error> {
    // 实现 token 刷新逻辑
}
```

### Q: 如何实现请求重试？

A: 使用 Combine 的 `retry` 操作符：

```swift
return request(endpoint: "/users/profile")
    .retry(3)  // 失败时重试 3 次
    .eraseToAnyPublisher()
```

### Q: 如何显示加载状态？

A: 在 ViewModel 中添加 `isLoading` 状态：

```swift
@Published var isLoading = false

func loadData() {
    isLoading = true
    
    networkRequest
        .sink(
            receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            },
            receiveValue: { ... }
        )
}
```

---

## 需要的第三方库（可选）

虽然本示例使用系统自带的 URLSession 和 Combine，但您也可以考虑使用：

- **Alamofire**: 更强大的网络库
- **Moya**: 网络层抽象
- **Kingfisher**: 图片加载和缓存
- **SwiftyJSON**: JSON 解析辅助

添加到 Package.swift 或使用 CocoaPods/SPM 安装。

