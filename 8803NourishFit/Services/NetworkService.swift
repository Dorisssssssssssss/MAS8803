import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
}

// MARK: - Authentication API
extension NetworkService {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        return Future<AuthResponse, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let user = result?.user else {
                    promise(.failure(NetworkError.apiError("Auth user missing")))
                    return
                }
                user.getIDToken(completion: { token, tokenError in
                    if let tokenError = tokenError {
                        promise(.failure(tokenError))
                        return
                    }
                    let response = AuthResponse(
                        userId: user.uid,
                        accessToken: token ?? "",
                        refreshToken: ""
                    )
                    promise(.success(response))
                })
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func register(email: String, password: String, name: String, fitnessLevel: String, goal: String) -> AnyPublisher<AuthResponse, Error> {
        return Future<AuthResponse, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let user = result?.user else {
                    promise(.failure(NetworkError.apiError("Auth user missing")))
                    return
                }
                // Initialize profile in Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "name": name,
                    "email": email,
                    "fitnessLevel": fitnessLevel,
                    "goal": goal,
                    "profileImage": NSNull(),
                    "createdAt": Timestamp(date: Date()),
                    "updatedAt": Timestamp(date: Date())
                ], merge: true) { _ in
                    user.getIDToken(completion: { token, tokenError in
                        if let tokenError = tokenError {
                            promise(.failure(tokenError))
                            return
                        }
                        let response = AuthResponse(
                            userId: user.uid,
                            accessToken: token ?? "",
                            refreshToken: ""
                        )
                        promise(.success(response))
                    })
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - User Profile API
extension NetworkService {
    func getUserProfile() -> AnyPublisher<UserProfile, Error> {
        return Future<UserProfile, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else {
                promise(.failure(NetworkError.apiError("Not authenticated")))
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let data = snapshot?.data() else {
                    promise(.failure(NetworkError.apiError("Profile not found")))
                    return
                }
                let name = data["name"] as? String ?? ""
                let fitnessLevelStr = data["fitnessLevel"] as? String ?? UserProfile.FitnessLevel.beginner.rawValue
                let goalStr = data["goal"] as? String ?? UserProfile.FitnessGoal.fatLoss.rawValue
                let profileImage = data["profileImage"] as? String

                let fitnessLevel = UserProfile.FitnessLevel(rawValue: fitnessLevelStr) ?? .beginner
                let goal = UserProfile.FitnessGoal(rawValue: goalStr) ?? .fatLoss

                let profile = UserProfile(name: name, fitnessLevel: fitnessLevel, goal: goal, profileImage: profileImage)
                promise(.success(profile))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func updateUserProfile(_ profile: UserProfile) -> AnyPublisher<UserProfile, Error> {
        return Future<UserProfile, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else {
                promise(.failure(NetworkError.apiError("Not authenticated")))
                return
            }
            let db = Firestore.firestore()
            let data: [String: Any] = [
                "name": profile.name,
                "fitnessLevel": profile.fitnessLevel.rawValue,
                "goal": profile.goal.rawValue,
                "profileImage": profile.profileImage as Any,
                "updatedAt": Timestamp(date: Date())
            ]
            db.collection("users").document(uid).setData(data, merge: true) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(profile))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - Nutrition API
extension NetworkService {
    func getTodayCalorieBalance() -> AnyPublisher<CalorieBalance, Error> {
        return Future<CalorieBalance, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            db.collection("meals")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .whereField("timestamp", isLessThan: Timestamp(date: end))
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let totalCalories: Int = snapshot?.documents.reduce(0) { acc, doc in
                        let data = doc.data()
                        let items = data["recognizedFoods"] as? [[String: Any]] ?? data["items"] as? [[String: Any]] ?? []
                        let cals = items.reduce(0) { s, item in s + (item["calories"] as? Int ?? 0) }
                        return acc + cals
                    } ?? 0
                    let goal = 2000
                    let burned = 0
                    let balance = CalorieBalance(
                        date: Date(),
                        intake: totalCalories,
                        goal: goal,
                        burned: burned,
                        remaining: max(goal - totalCalories, 0)
                    )
                    promise(.success(balance))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func recordMeal(_ meal: MealRequest) -> AnyPublisher<MealResponse, Error> {
        return Future<MealResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let doc = db.collection("meals").document()
            let items = meal.items.map { item -> [String: Any] in
                [
                    "name": item.name,
                    "quantity": item.quantity,
                    "unit": item.unit,
                    "calories": item.calories,
                    "protein": item.protein,
                    "carbs": item.carbs,
                    "fat": item.fat
                ]
            }
            let data: [String: Any] = [
                "userId": userId,
                "mealType": meal.mealType,
                "timestamp": Timestamp(date: meal.timestamp),
                "items": items
            ]
            doc.setData(data) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                let response = MealResponse(
                    id: doc.documentID,
                    mealType: meal.mealType,
                    items: meal.items,
                    timestamp: meal.timestamp
                )
                promise(.success(response))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func getTodayMeals() -> AnyPublisher<TodayNutritionResponse, Error> {
        return Future<TodayNutritionResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            db.collection("meals")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .whereField("timestamp", isLessThan: Timestamp(date: end))
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let meals: [MealResponse] = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        let mealType = data["mealType"] as? String ?? ""
                        let ts = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let rawItems = data["items"] as? [[String: Any]] ?? data["recognizedFoods"] as? [[String: Any]] ?? []
                        let items: [MealItem] = rawItems.compactMap { m in
                            guard let name = m["name"] as? String else { return nil }
                            return MealItem(
                                name: name,
                                quantity: (m["quantity"] as? Double) ?? 1.0,
                                unit: (m["unit"] as? String) ?? "serving",
                                calories: (m["calories"] as? Int) ?? 0,
                                protein: (m["protein"] as? Double) ?? 0,
                                carbs: (m["carbs"] as? Double) ?? 0,
                                fat: (m["fat"] as? Double) ?? 0
                            )
                        }
                        return MealResponse(id: doc.documentID, mealType: mealType, items: items, timestamp: ts)
                    } ?? []

                    let total = meals.flatMap { $0.items }.reduce(0) { $0 + $1.calories }
                    let goal = 2000
                    let macros = MacroProgress(
                        protein: MacroDetail(current: meals.flatMap { $0.items }.reduce(0) { $0 + $1.protein }, goal: 150, percentage: 0),
                        carbs: MacroDetail(current: meals.flatMap { $0.items }.reduce(0) { $0 + $1.carbs }, goal: 220, percentage: 0),
                        fat: MacroDetail(current: meals.flatMap { $0.items }.reduce(0) { $0 + $1.fat }, goal: 60, percentage: 0)
                    )
                    let resp = TodayNutritionResponse(
                        date: ISO8601DateFormatter().string(from: Date()),
                        totalCalories: total,
                        goalCalories: goal,
                        meals: meals,
                        macros: macros
                    )
                    promise(.success(resp))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func recognizeFood(image: UIImage, mealType: String) -> AnyPublisher<FoodRecognitionResponse, Error> {
        print("📸 Converting image to base64...")
        // Convert UIImage to base64 string
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
        }
        
        let base64String = imageData.base64EncodedString()
        print("✅ Image converted to base64, length: \(base64String.count)")
        
        // Get current user ID (use fallback for development)
        let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
        
        // Call our Cloud Function
        let cloudFunctionURL = "https://recognize-food-proxy-2quduy4awa-uc.a.run.app"
        print("🌐 Calling Cloud Function: \(cloudFunctionURL)")
        
        guard let url = URL(string: cloudFunctionURL) else {
            print("❌ Invalid Cloud Function URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "base64Image": base64String,
            "userId": userId,
            "mealType": mealType
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
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
            .decode(type: FoodRecognitionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Firestore Integration
    func saveMealToFirestore(mealData: FoodRecognitionResponse, mealType: String) -> AnyPublisher<Void, Error> {
        let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
        
        let db = Firestore.firestore()
        let mealDocument = db.collection("meals").document()
        
        let mealData: [String: Any] = [
            "userId": userId,
            "mealType": mealType,
            "timestamp": Timestamp(date: Date()),
            "recognizedFoods": mealData.recognizedFoods.map { food in
                [
                    "name": food.name,
                    "confidence": food.confidence,
                    "calories": food.calories,
                    "protein": food.protein,
                    "carbs": food.carbs,
                    "fat": food.fat
                ]
            }
        ]
        
        return Future<Void, Error> { promise in
            mealDocument.setData(mealData) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getTodayMealsFromFirestore() -> AnyPublisher<[MealResponse], Error> {
        let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
        
        let db = Firestore.firestore()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return Future<[MealResponse], Error> { promise in
            db.collection("meals")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let meals = documents.compactMap { doc -> MealResponse? in
                        let data = doc.data()
                        guard let mealType = data["mealType"] as? String,
                              let timestampData = data["timestamp"] as? Timestamp,
                              let recognizedFoods = data["recognizedFoods"] as? [[String: Any]] else {
                            return nil
                        }
                        
                        // Filter for today's meals on client side
                        let mealDate = timestampData.dateValue()
                        if !Calendar.current.isDate(mealDate, inSameDayAs: Date()) {
                            return nil
                        }
                        
                        // Convert Timestamp to Date
                        let mealTimestamp = timestampData.dateValue()
                        
                        let items = recognizedFoods.compactMap { foodData -> MealItem? in
                            guard let name = foodData["name"] as? String,
                                  let calories = foodData["calories"] as? Int,
                                  let protein = foodData["protein"] as? Double,
                                  let carbs = foodData["carbs"] as? Double,
                                  let fat = foodData["fat"] as? Double else {
                                return nil
                            }
                            
                            return MealItem(
                                name: name,
                                quantity: 1.0,
                                unit: "serving",
                                calories: calories,
                                protein: protein,
                                carbs: carbs,
                                fat: fat
                            )
                        }
                        
                        return MealResponse(
                            id: doc.documentID,
                            mealType: mealType,
                            items: items,
                            timestamp: mealTimestamp
                        )
                    }
                    
                    promise(.success(meals))
                }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Workout API
extension NetworkService {
    func getTodayWorkouts() -> AnyPublisher<WorkoutDayResponse, Error> {
        return Future<WorkoutDayResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            db.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .whereField("timestamp", isLessThan: Timestamp(date: end))
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let exercises: [Exercise] = snapshot?.documents.flatMap { doc -> [Exercise] in
                        let data = doc.data()
                        let raw = data["exercises"] as? [[String: Any]] ?? []
                        return raw.map { r in
                            Exercise(
                                name: (r["name"] as? String) ?? "",
                                sets: (r["sets"] as? Int) ?? 0,
                                reps: (r["reps"] as? Int) ?? 0,
                                duration: r["duration"] as? Int,
                                isCompleted: (r["isCompleted"] as? Bool) ?? false
                            )
                        }
                    } ?? []
                    let totalDuration = exercises.reduce(0) { $0 + (Int($1.duration ?? 0)) }
                    let caloriesBurned = snapshot?.documents.reduce(0) { acc, doc in
                        acc + (doc.data()["caloriesBurned"] as? Int ?? 0)
                    } ?? 0
                    let resp = WorkoutDayResponse(date: ISO8601DateFormatter().string(from: Date()), totalDuration: totalDuration, caloriesBurned: caloriesBurned, exercises: exercises)
                    promise(.success(resp))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func recordWorkout(_ workout: WorkoutRequest) -> AnyPublisher<WorkoutResponse, Error> {
        return Future<WorkoutResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let doc = db.collection("workouts").document()
            let exercises = workout.exercises.map { e -> [String: Any] in
                [
                    "name": e.name,
                    "sets": e.sets,
                    "reps": e.reps,
                    "duration": e.duration as Any,
                    "caloriesBurned": e.caloriesBurned as Any,
                    "isCompleted": false
                ]
            }
            let calories = workout.exercises.reduce(0) { $0 + (Int($1.caloriesBurned ?? 0)) }
            let data: [String: Any] = [
                "userId": userId,
                "timestamp": Timestamp(date: workout.timestamp),
                "exercises": exercises,
                "caloriesBurned": calories
            ]
            doc.setData(data) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                let ex = workout.exercises.map { Exercise(name: $0.name, sets: $0.sets, reps: $0.reps, duration: $0.duration, isCompleted: false) }
                let resp = WorkoutResponse(id: doc.documentID, exercises: ex)
                promise(.success(resp))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func completeExercise(exerciseId: String) -> AnyPublisher<EmptyResponse, Error> {
        // MVP: 标记完成可在客户端直接更新，或后续扩展为带 workoutId + exerciseId 的更新。
        return Just(EmptyResponse())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getWorkoutHistory(startDate: String, endDate: String) -> AnyPublisher<[WorkoutTimeData], Error> {
        return Future<[WorkoutTimeData], Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let start = formatter.date(from: startDate) ?? Date()
            let end = (formatter.date(from: endDate) ?? Date())
            db.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .whereField("timestamp", isLessThanOrEqualTo: Timestamp(date: end))
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    // Sum duration per day
                    var perDay: [String: Int] = [:]
                    let dayFmt = DateFormatter()
                    dayFmt.dateFormat = "yyyy-MM-dd"
                    snapshot?.documents.forEach { doc in
                        let ts = (doc.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let day = dayFmt.string(from: ts)
                        let exercises = (doc.data()["exercises"] as? [[String: Any]] ?? [])
                        let dur = exercises.reduce(0) { $0 + (Int(($1["duration"] as? Int) ?? 0)) }
                        perDay[day, default: 0] += dur
                    }
                    let result = perDay.compactMap { (day, dur) -> WorkoutTimeData? in
                        guard let date = formatter.date(from: day) else { return nil }
                        return WorkoutTimeData(date: date, duration: dur)
                    }.sorted { $0.date < $1.date }
                    promise(.success(result))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - AI Coach API (via Cloud Function)
extension NetworkService {
    func getTodayAISuggestion() -> AnyPublisher<AISuggestionResponse, Error> {
        // Replace with your deployed Cloud Function URL
        let cloudFunctionURL = "https://ai-coach-suggestion-REPLACE.a.run.app"
        guard let url = URL(string: cloudFunctionURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["userId": userId]
        do { request.httpBody = try JSONSerialization.data(withJSONObject: body) } catch {
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .decode(type: AISuggestionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Progress API
extension NetworkService {
    func getWeeklyMetrics() -> AnyPublisher<ProgressMetrics, Error> {
        return Future<ProgressMetrics, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let start = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!
            db.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .getDocuments { snapshot, error in
                    if let error = error { promise(.failure(error)); return }
                    let days = Set(snapshot?.documents.compactMap { (doc) -> String? in
                        let ts = (doc.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: ts)
                    } ?? [])
                    // Simple macros from meals for the week
                    let mealsRef = db.collection("meals")
                    mealsRef
                        .whereField("userId", isEqualTo: userId)
                        .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                        .getDocuments { ms, me in
                            if let me = me { promise(.failure(me)); return }
                            let allItems = ms?.documents.flatMap { $0.data()["items"] as? [[String: Any]] ?? [] } ?? []
                            let protein = allItems.reduce(0.0) { $0 + ( ($1["protein"] as? Double) ?? 0) }
                            let carbs = allItems.reduce(0.0) { $0 + ( ($1["carbs"] as? Double) ?? 0) }
                            let fat = allItems.reduce(0.0) { $0 + ( ($1["fat"] as? Double) ?? 0) }
                            let metrics = ProgressMetrics(
                                trainingDays: days.count,
                                totalTrainingDays: 7,
                                weightChange: 0.0,
                                planCompletion: Int(Double(days.count) / 7.0 * 100.0),
                                macros: Macronutrients(
                                    protein: Int(protein.rounded()),
                                    carbs: Int(carbs.rounded()),
                                    fat: Int(fat.rounded())
                                )
                            )
                            promise(.success(metrics))
                        }
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func recordBodyMetrics(_ metrics: BodyMetricsRequest) -> AnyPublisher<EmptyResponse, Error> {
        return Future<EmptyResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let data: [String: Any] = [
                "userId": userId,
                "timestamp": Timestamp(date: metrics.timestamp),
                "weight": metrics.weight as Any,
                "waist": metrics.waist as Any
            ]
            db.collection("metrics").addDocument(data: data) { error in
                if let error = error { promise(.failure(error)) } else { promise(.success(EmptyResponse())) }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func getBodyMetricsHistory(period: String) -> AnyPublisher<BodyMetricsHistoryResponse, Error> {
        return Future<BodyMetricsHistoryResponse, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let now = Date()
            let start: Date
            switch period {
            case "month": start = Calendar.current.date(byAdding: .day, value: -30, to: now)!
            case "week": fallthrough
            default: start = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            }
            db.collection("metrics")
                .whereField("userId", isEqualTo: userId)
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
                .order(by: "timestamp")
                .getDocuments { snapshot, error in
                    if let error = error { promise(.failure(error)); return }
                    let dayFmt = DateFormatter(); dayFmt.dateFormat = "yyyy-MM-dd"
                    let history: [BodyMetric] = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        let ts = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        return BodyMetric(
                            date: dayFmt.string(from: ts),
                            weight: data["weight"] as? Double,
                            waist: data["waist"] as? Double
                        )
                    } ?? []
                    promise(.success(BodyMetricsHistoryResponse(period: period, metrics: history)))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - Notifications API (MVP: local/sample data in ViewModel)

// MARK: - Calendar API
extension NetworkService {
    func getCalendarEvents(startDate: String, endDate: String) -> AnyPublisher<[CalendarEvent], Error> {
        return Future<[CalendarEvent], Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
            let start = formatter.date(from: startDate) ?? Date()
            let end = formatter.date(from: endDate) ?? Date()
            db.collection("calendar_events")
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: start))
                .whereField("date", isLessThanOrEqualTo: Timestamp(date: end))
                .order(by: "date")
                .getDocuments { snapshot, error in
                    if let error = error { promise(.failure(error)); return }
                    let events: [CalendarEvent] = snapshot?.documents.compactMap { doc in
                        let d = doc.data()
                        return CalendarEvent(
                            title: (d["title"] as? String) ?? "",
                            description: (d["description"] as? String) ?? "",
                            date: (d["date"] as? Timestamp)?.dateValue() ?? Date(),
                            duration: (d["duration"] as? Int) ?? 0,
                            type: CalendarEvent.EventType(rawValue: (d["type"] as? String) ?? "Workout") ?? .workout,
                            isCompleted: (d["isCompleted"] as? Bool) ?? false
                        )
                    } ?? []
                    promise(.success(events))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func createCalendarEvent(_ event: CalendarEventRequest) -> AnyPublisher<CalendarEvent, Error> {
        return Future<CalendarEvent, Error> { promise in
            let db = Firestore.firestore()
            let userId = Auth.auth().currentUser?.uid ?? "dev_user_123"
            let doc = db.collection("calendar_events").document()
            let data: [String: Any] = [
                "userId": userId,
                "title": event.title,
                "description": event.description,
                "date": Timestamp(date: ISO8601DateFormatter().date(from: event.date) ?? Date()),
                "duration": event.duration,
                "type": event.type,
                "isCompleted": false
            ]
            doc.setData(data) { error in
                if let error = error { promise(.failure(error)); return }
                let created = CalendarEvent(
                    title: event.title,
                    description: event.description,
                    date: ISO8601DateFormatter().date(from: event.date) ?? Date(),
                    duration: event.duration,
                    type: CalendarEvent.EventType(rawValue: event.type) ?? .custom,
                    isCompleted: false
                )
                promise(.success(created))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func completeEvent(eventId: String) -> AnyPublisher<EmptyResponse, Error> {
        return Future<EmptyResponse, Error> { promise in
            let db = Firestore.firestore()
            db.collection("calendar_events").document(eventId).setData(["isCompleted": true], merge: true) { error in
                if let error = error { promise(.failure(error)) } else { promise(.success(EmptyResponse())) }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - Settings API
extension NetworkService {
    func getSettings() -> AnyPublisher<AppSettings, Error> {
        return Future<AppSettings, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else {
                promise(.failure(NetworkError.apiError("Not authenticated")))
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(uid).collection("meta").document("settings").getDocument { snap, error in
                if let error = error { promise(.failure(error)); return }
                guard let data = snap?.data() else {
                    promise(.success(AppSettings()))
                    return
                }
                do {
                    let json = try JSONSerialization.data(withJSONObject: data)
                    let settings = try JSONDecoder().decode(AppSettings.self, from: json)
                    promise(.success(settings))
                } catch {
                    promise(.success(AppSettings()))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func updateSettings(_ settings: AppSettings) -> AnyPublisher<AppSettings, Error> {
        return Future<AppSettings, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else {
                promise(.failure(NetworkError.apiError("Not authenticated")))
                return
            }
            let db = Firestore.firestore()
            do {
                let data = try JSONSerialization.jsonObject(with: JSONEncoder().encode(settings)) as? [String: Any] ?? [:]
                db.collection("users").document(uid).collection("meta").document("settings").setData(data, merge: true) { error in
                    if let error = error { promise(.failure(error)) } else { promise(.success(settings)) }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func exportUserData() -> AnyPublisher<ExportDataResponse, Error> {
        // MVP: 返回占位导出结果
        let resp = ExportDataResponse(exportId: UUID().uuidString, downloadUrl: "", expiresAt: Date().addingTimeInterval(3600))
        return Just(resp)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request/Response Models

// Removed APIResponse/APIError for MVP (no custom REST backend)

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

// Removed pagination wrappers (not used in MVP)

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

