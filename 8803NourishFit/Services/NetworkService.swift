import Foundation
import Combine

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.nourishfit.com/v1"
    private var accessToken: String?
    
    private init() {}
    
    // MARK: - Configuration
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    // MARK: - Generic Request Method
    private func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) -> AnyPublisher<T, Error> {
        
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response in
                guard response.success, let data = response.data else {
                    throw NetworkError.apiError(response.error?.message ?? "Unknown error")
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - HTTP Methods
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}

// MARK: - Authentication API
extension NetworkService {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let body = LoginRequest(email: email, password: password)
        return request(endpoint: "/auth/login", method: .post, body: body)
    }
    
    func register(email: String, password: String, name: String, fitnessLevel: String, goal: String) -> AnyPublisher<AuthResponse, Error> {
        let body = RegisterRequest(email: email, password: password, name: name, fitnessLevel: fitnessLevel, goal: goal)
        return request(endpoint: "/auth/register", method: .post, body: body)
    }
}

// MARK: - User Profile API
extension NetworkService {
    func getUserProfile() -> AnyPublisher<UserProfile, Error> {
        return request(endpoint: "/users/profile")
    }
    
    func updateUserProfile(_ profile: UserProfile) -> AnyPublisher<UserProfile, Error> {
        return request(endpoint: "/users/profile", method: .put, body: profile)
    }
}

// MARK: - Nutrition API
extension NetworkService {
    func getTodayCalorieBalance() -> AnyPublisher<CalorieBalance, Error> {
        return request(endpoint: "/nutrition/calorie-balance/today")
    }
    
    func recordMeal(_ meal: MealRequest) -> AnyPublisher<MealResponse, Error> {
        return request(endpoint: "/nutrition/meals", method: .post, body: meal)
    }
    
    func getTodayMeals() -> AnyPublisher<TodayNutritionResponse, Error> {
        return request(endpoint: "/nutrition/meals/today")
    }
    
    func recognizeFood(image: Data) -> AnyPublisher<FoodRecognitionResponse, Error> {
        // 实现多部分表单上传
        // 这里需要特殊处理，暂时留空
        fatalError("Not implemented")
    }
}

// MARK: - Workout API
extension NetworkService {
    func getTodayWorkouts() -> AnyPublisher<WorkoutDayResponse, Error> {
        return request(endpoint: "/workouts/today")
    }
    
    func recordWorkout(_ workout: WorkoutRequest) -> AnyPublisher<WorkoutResponse, Error> {
        return request(endpoint: "/workouts", method: .post, body: workout)
    }
    
    func completeExercise(exerciseId: String) -> AnyPublisher<EmptyResponse, Error> {
        return request(endpoint: "/workouts/exercises/\(exerciseId)/complete", method: .put)
    }
    
    func getWorkoutHistory(startDate: String, endDate: String) -> AnyPublisher<[WorkoutTimeData], Error> {
        return request(endpoint: "/workouts/history?startDate=\(startDate)&endDate=\(endDate)")
    }
}

// MARK: - AI Coach API
extension NetworkService {
    func getTodayAISuggestion() -> AnyPublisher<AISuggestionResponse, Error> {
        return request(endpoint: "/ai-coach/suggestions/today")
    }
    
    func acceptSuggestion(suggestionId: String) -> AnyPublisher<EmptyResponse, Error> {
        return request(endpoint: "/ai-coach/suggestions/\(suggestionId)/accept", method: .post)
    }
    
    func regenerateSuggestion(suggestionId: String) -> AnyPublisher<AISuggestionResponse, Error> {
        return request(endpoint: "/ai-coach/suggestions/\(suggestionId)/regenerate", method: .post)
    }
    
    func delaySuggestion(suggestionId: String, delayUntil: Date) -> AnyPublisher<EmptyResponse, Error> {
        let body = DelaySuggestionRequest(delayUntil: delayUntil)
        return request(endpoint: "/ai-coach/suggestions/\(suggestionId)/delay", method: .post, body: body)
    }
    
    func getOfflinePlans() -> AnyPublisher<[OfflinePlan], Error> {
        return request(endpoint: "/ai-coach/offline-plans")
    }
}

// MARK: - Progress API
extension NetworkService {
    func getWeeklyMetrics() -> AnyPublisher<ProgressMetrics, Error> {
        return request(endpoint: "/progress/metrics/week")
    }
    
    func recordBodyMetrics(_ metrics: BodyMetricsRequest) -> AnyPublisher<EmptyResponse, Error> {
        return request(endpoint: "/progress/body-metrics", method: .post, body: metrics)
    }
    
    func getBodyMetricsHistory(period: String) -> AnyPublisher<BodyMetricsHistoryResponse, Error> {
        return request(endpoint: "/progress/body-metrics?period=\(period)")
    }
}

// MARK: - Notifications API
extension NetworkService {
    func getUnreadNotifications() -> AnyPublisher<[AppNotification], Error> {
        return request(endpoint: "/notifications/unread")
    }
    
    func markNotificationAsRead(notificationId: String) -> AnyPublisher<EmptyResponse, Error> {
        return request(endpoint: "/notifications/\(notificationId)/read", method: .put)
    }
    
    func getNotificationHistory(page: Int, limit: Int) -> AnyPublisher<PaginatedResponse<AppNotification>, Error> {
        return request(endpoint: "/notifications/history?page=\(page)&limit=\(limit)")
    }
}

// MARK: - Calendar API
extension NetworkService {
    func getCalendarEvents(startDate: String, endDate: String) -> AnyPublisher<[CalendarEvent], Error> {
        return request(endpoint: "/calendar/events?startDate=\(startDate)&endDate=\(endDate)")
    }
    
    func createCalendarEvent(_ event: CalendarEventRequest) -> AnyPublisher<CalendarEvent, Error> {
        return request(endpoint: "/calendar/events", method: .post, body: event)
    }
    
    func completeEvent(eventId: String) -> AnyPublisher<EmptyResponse, Error> {
        return request(endpoint: "/calendar/events/\(eventId)/complete", method: .put)
    }
}

// MARK: - Settings API
extension NetworkService {
    func getSettings() -> AnyPublisher<AppSettings, Error> {
        return request(endpoint: "/settings")
    }
    
    func updateSettings(_ settings: AppSettings) -> AnyPublisher<AppSettings, Error> {
        return request(endpoint: "/settings", method: .put, body: settings)
    }
    
    func exportUserData() -> AnyPublisher<ExportDataResponse, Error> {
        return request(endpoint: "/settings/export-data", method: .post)
    }
}

// MARK: - Request/Response Models

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIError?
}

struct APIError: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let name: String
    let fitnessLevel: String
    let goal: String
}

struct AuthResponse: Decodable {
    let userId: String
    let accessToken: String
    let refreshToken: String
}

struct MealRequest: Encodable {
    let mealType: String
    let items: [MealItem]
    let timestamp: Date
}

struct MealItem: Codable {
    let name: String
    let quantity: Double
    let unit: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct MealResponse: Decodable {
    let id: String
    let mealType: String
    let items: [MealItem]
    let timestamp: Date
}

struct TodayNutritionResponse: Decodable {
    let date: String
    let totalCalories: Int
    let goalCalories: Int
    let meals: [MealResponse]
    let macros: MacroProgress
}

struct MacroProgress: Decodable {
    let protein: MacroDetail
    let carbs: MacroDetail
    let fat: MacroDetail
}

struct MacroDetail: Decodable {
    let current: Double
    let goal: Double
    let percentage: Double
}

struct FoodRecognitionResponse: Decodable {
    let recognizedFoods: [RecognizedFood]
}

struct RecognizedFood: Decodable {
    let name: String
    let confidence: Double
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct WorkoutRequest: Encodable {
    let exercises: [ExerciseRequest]
    let timestamp: Date
}

struct ExerciseRequest: Encodable {
    let name: String
    let sets: Int
    let reps: Int
    let duration: Int?
    let caloriesBurned: Int?
}

struct WorkoutDayResponse: Decodable {
    let date: String
    let totalDuration: Int
    let caloriesBurned: Int
    let exercises: [Exercise]
}

struct WorkoutResponse: Decodable {
    let id: String
    let exercises: [Exercise]
}

struct AISuggestionResponse: Decodable {
    let id: String
    let message: String
    let timestamp: Date
    let actions: [TipAction]
    let suggestions: SuggestionDetails
    let reasoning: String?
}

struct SuggestionDetails: Decodable {
    let training: AISuggestionItem?
    let diet: AISuggestionItem?
}

struct AISuggestionItem: Decodable {
    let title: String
    let description: String
    let icon: String
}

struct DelaySuggestionRequest: Encodable {
    let delayUntil: Date
}

struct OfflinePlan: Decodable, Identifiable {
    let id: String
    let category: String
    let title: String
    let exercises: [String]
    let icon: String
}

struct BodyMetricsRequest: Encodable {
    let weight: Double?
    let waist: Double?
    let timestamp: Date
}

struct BodyMetricsHistoryResponse: Decodable {
    let period: String
    let metrics: [BodyMetric]
}

struct BodyMetric: Decodable {
    let date: String
    let weight: Double?
    let waist: Double?
}

struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

struct CalendarEventRequest: Encodable {
    let title: String
    let description: String
    let date: String
    let duration: Int
    let type: String
}

struct ExportDataResponse: Decodable {
    let exportId: String
    let downloadUrl: String
    let expiresAt: Date
}

struct EmptyResponse: Decodable {}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingError
    case httpError(statusCode: Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .encodingError:
            return "Failed to encode request"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .apiError(let message):
            return message
        }
    }
}

