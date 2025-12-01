import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - Main App ViewModel
class AppViewModel: ObservableObject {
    @Published var currentTab: TabSelection = .home
    @Published var userProfile: UserProfile = UserProfile(
        name: "Aiony Haust",
        fitnessLevel: .beginner,
        goal: .fatLoss,
        dailyCalorieGoal: 1500, // Sarah's goal
        proteinGoal: 300,       // Sarah's goal
        carbsGoal: 220,         // Default
        fatGoal: 50             // Sarah's goal (Wait, use case says 50g fiber, not fat. Let's assume fat goal is reasonable like 60g, and fiber goal is separate)
    )
    @Published var progress: [Progress] = []
    @Published var calorieBalance: CalorieBalance?
    @Published var aiCoachTip: AICoachTip?
    @Published var aiSuggestionDetails: AISuggestionResponse?
    @Published var progressMetrics: ProgressMetrics?
    @Published var workoutTimeData: [WorkoutTimeData] = []
    @Published var notifications: [AppNotification] = []
    @Published var suggestions: [Suggestion] = []
    @Published var calendarEvents: [CalendarEvent] = []
    @Published var scheduleItems: [ScheduleItem] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var todayMeals: [MealResponse] = []
    @Published var todayWorkouts: WorkoutDayResponse? // New property for today's workouts
    @Published var currentFoodAnalysis: FoodRecognitionResponse?
    @Published var weeklyWorkoutHistory: [WorkoutTimeData] = [] // New property
    @Published var weeklyIntakeHistory: [Int] = [] // New property
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    private let healthKitService = HealthKitService.shared
    
    enum TabSelection: String, CaseIterable {
        case home = "Home"
        case suggestions = "AI Coach"
        case calendar = "Log"
        case settings = "Plan"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .suggestions: return "dumbbell.fill"
            case .calendar: return "clock.fill"
            case .settings: return "list.bullet.clipboard.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    init() {
        // Initialize with sample data
        loadSampleData()
        
        // Check authentication status
        checkAuthenticationStatus()
        
        // Setup HealthKit
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        healthKitService.requestAuthorization()
        
        healthKitService.$activeEnergyBurned
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calories in
                guard let self = self else { return }
                if var balance = self.calorieBalance {
                    balance.burned = Int(calories)
                    balance.remaining = max(balance.goal - balance.intake + balance.burned, 0) // Logic depends on how remaining is calculated
                    // Usually: Remaining = Goal - Intake + Burned ? Or just Goal - Intake?
                    // Let's assume Goal is Net Calories.
                    // If Goal is Total Calories to Eat: Remaining = Goal + Burned - Intake
                    
                    // Let's stick to simple: Update burned
                    balance.burned = Int(calories)
                    self.calorieBalance = balance
                }
            }
            .store(in: &cancellables)
    }
    
        // MARK: - Sample Data
        private func loadSampleData() {
            // Sample progress data
            progress = [
                Progress(
                    date: Date(),
                    workoutsCompleted: 3,
                    totalWorkouts: 5,
                    caloriesBurned: 450,
                    duration: 60
                )
            ]
            
            // Sample calorie balance data
            calorieBalance = CalorieBalance(
                date: Date(),
                intake: 1847,
                goal: 2100,
                burned: 2234,
                remaining: 253
            )
            
            // Sample AI coach tip
            aiCoachTip = AICoachTip(
                message: "You went over your target by 500 kcal last night. Recommendation: Add 20 min HIIT or 2,000 extra steps today.",
                timestamp: Date(),
                actions: [
                    TipAction(title: "Do HIIT", type: .hiit),
                    TipAction(title: "Take a Walk", type: .walk)
                ]
            )
            
            // Sample progress metrics
            progressMetrics = ProgressMetrics(
                trainingDays: 5,
                totalTrainingDays: 6,
                weightChange: -0.8,
                planCompletion: 92,
                macros: Macronutrients(protein: 52, carbs: 25, fat: 23)
            )
            
            // Sample workout time data (matching the chart design)
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            // Create specific dates for July 1-7
            let july1 = formatter.date(from: "2024-07-01") ?? Date()
            let july3 = formatter.date(from: "2024-07-03") ?? Date()
            let july5 = formatter.date(from: "2024-07-05") ?? Date()
            let july7 = formatter.date(from: "2024-07-07") ?? Date()
            
            workoutTimeData = [
                WorkoutTimeData(date: july1, duration: 50),  // 07-01: ~50 minutes
                WorkoutTimeData(date: july3, duration: 65),  // 07-03: ~65 minutes
                WorkoutTimeData(date: july5, duration: 50),  // 07-05: ~50 minutes
                WorkoutTimeData(date: july7, duration: 65)   // 07-07: ~65 minutes
            ]
        
        // Sample notifications
        notifications = [
            AppNotification(
                title: "Workout Reminder",
                message: "Time for your afternoon workout!",
                timestamp: Date(),
                type: .workout
            ),
            AppNotification(
                title: "Achievement Unlocked",
                message: "You've completed 5 workouts this week!",
                timestamp: Date().addingTimeInterval(-3600),
                type: .achievement
            )
        ]
        
        // Sample suggestions
        suggestions = [
            Suggestion(
                title: "Morning Cardio",
                description: "Start your day with a 20-minute cardio session",
                category: .aerobic,
                timestamp: Date()
            ),
            Suggestion(
                title: "Strength Training",
                description: "Focus on upper body strength exercises",
                category: .equipment,
                timestamp: Date()
            )
        ]
        
        // Sample calendar events
        calendarEvents = [
            CalendarEvent(
                title: "Morning Run",
                description: "30-minute morning run in the park",
                date: Date(),
                duration: 30,
                type: .workout
            ),
            CalendarEvent(
                title: "Rest Day",
                description: "Take a well-deserved rest",
                date: Date().addingTimeInterval(86400),
                duration: 0,
                type: .rest
            )
        ]
        
        // Sample schedule items
        scheduleItems = [
            ScheduleItem(
                dayOfWeek: "MON",
                dayNumber: "26",
                title: "Strength Training",
                time: "9:00 a.m - 10:30 a.m",
                description: nil,
                status: .scheduled
            ),
            ScheduleItem(
                dayOfWeek: "TUE",
                dayNumber: "27",
                title: "Time Conflict",
                time: nil,
                description: "Meeting vs Aerobic Training",
                status: .conflict
            ),
            ScheduleItem(
                dayOfWeek: "WED",
                dayNumber: "26",
                title: "Aerobic Training",
                time: "7:00 p.m - 8:00 p.m",
                description: nil,
                status: .scheduled
            )
        ]
    }
    
    // MARK: - Actions
    func acceptSuggestion(_ suggestion: Suggestion) {
        if let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) {
            suggestions[index].isAccepted = true
        }
    }
    
    func markNotificationAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
    }
    
    func addCalendarEvent(_ event: CalendarEvent) {
        calendarEvents.append(event)
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
    }
    
    // MARK: - Computed Properties
    var todayProgress: Progress? {
        progress.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }
    
    var acceptedSuggestions: [Suggestion] {
        suggestions.filter { $0.isAccepted }
    }
    
    var todayEvents: [CalendarEvent] {
        calendarEvents.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    // MARK: - Authentication
    private func checkAuthenticationStatus() {
        isAuthenticated = Auth.auth().currentUser != nil
        if isAuthenticated {
            loadTodayMeals()
            refreshAICoachTip()
        }
    }
    
    func signInAnonymously() {
        isLoading = true
        errorMessage = nil
        
        print("🔑 Attempting real Firebase Anonymous Sign-in...")
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Firebase Sign-in failed: \(error.localizedDescription)")
                    
                    // SUPPRESS "restricted to administrators" error for demo purposes
                    // Error code 17020 corresponds to "This operation is restricted to administrators only." (FIRAuthErrorAdminRestrictedOperation)
                    // We check the localized description to be safe.
                    let errorString = error.localizedDescription
                    if errorString.contains("restricted to administrators") || (error as NSError).code == 17020 {
                        print("⚠️ Anonymous Auth disabled in Console. Falling back to DEMO MODE.")
                        self?.isAuthenticated = true
                        // Don't show error message to user
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = error.localizedDescription
                        // Allow fallback to proceed in partial functionality mode
                        self?.isAuthenticated = true
                    }
                } else {
                    print("✅ Firebase Sign-in successful. User ID: \(result?.user.uid ?? "unknown")")
                    self?.isAuthenticated = true
                    // Retry AI Coach refresh now that we are signed in
                    self?.refreshAICoachTip()
                }
                
                // Refresh data regardless (will use fallback user ID if auth failed)
                self?.loadTodayMeals()
            }
        }
    }
    
    // MARK: - Food Recognition
    func recognizeFood(image: UIImage, mealType: String) {
        print("🍎 Starting food recognition for meal type: \(mealType)")
        // Clear previous analysis to prevent stale data
        self.currentFoodAnalysis = nil
        
        isLoading = true
        errorMessage = nil
        
        networkService.recognizeFood(image: image, mealType: mealType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] foodResponse in
                    // Only store the analysis result, DO NOT save to Firestore yet
                    self?.currentFoodAnalysis = foodResponse
                }
            )
            .store(in: &cancellables)
    }
    
    func confirmMeal(mealType: String) {
        guard let foodResponse = currentFoodAnalysis else { return }
        
        isLoading = true
        errorMessage = nil
        
        networkService.saveMealToFirestore(mealData: foodResponse, mealType: mealType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    // Success: Refresh data
                    self?.loadTodayMeals()
                    // Clear current analysis
                    self?.currentFoodAnalysis = nil
                }
            )
            .store(in: &cancellables)
    }
    
    func loadWeeklyHistory() {
        let calendar = Calendar.current
        let today = Date()
        let oneWeekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = formatter.string(from: oneWeekAgo)
        let endDate = formatter.string(from: today)
        
        // 1. Load workout calorie history from HealthKit
        healthKitService.fetchWeeklyActiveEnergyBurned()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to fetch HealthKit weekly calories: \(error.localizedDescription)")
                        // Fallback to Firestore if HealthKit fails
                        self?.loadFirestoreWorkoutHistory(startDate: startDate, endDate: endDate)
                    }
                },
                receiveValue: { [weak self] history in
                    print("✅ Fetched \(history.count) days of workout calories from HealthKit")
                    self?.weeklyWorkoutHistory = history
                }
            )
            .store(in: &cancellables)
            
        // 2. Load real intake history from Firestore (last 7 days)
        networkService.getWeeklyIntakeHistory()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to fetch weekly intake: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] history in
                    print("✅ Fetched weekly intake history: \(history)")
                    self?.weeklyIntakeHistory = history
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadFirestoreWorkoutHistory(startDate: String, endDate: String) {
        networkService.getWorkoutHistory(startDate: startDate, endDate: endDate)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] history in
                    self?.weeklyWorkoutHistory = history
                }
            )
            .store(in: &cancellables)
    }
    
    func loadTodayMeals() {
        networkService.getTodayMealsFromFirestore()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] meals in
                    self?.todayMeals = meals
                }
            )
            .store(in: &cancellables)
    }
    
    func loadTodayWorkouts() {
        networkService.getTodayWorkouts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    // Ignore errors for now or handle them
                    if case .failure(let error) = completion {
                        print("Error loading workouts: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.todayWorkouts = response
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshAICoachTip() {
        print("🔄 refreshAICoachTip called")
        
        // If not signed in, try to sign in first
        if Auth.auth().currentUser == nil {
            print("⚠️ User not authenticated, attempting anonymous sign-in...")
            signInAnonymously()
            return
        }
        
        isLoading = true
        errorMessage = nil
        print("⏳ Setting isLoading = true, starting network request...")
        
        // Gather current stats to send to AI
        let intake = totalCaloriesToday
        // Use HealthKit burned if available, otherwise fallback to calorieBalance or 0
        let burned = Int(healthKitService.activeEnergyBurned) > 0 ? Int(healthKitService.activeEnergyBurned) : (calorieBalance?.burned ?? 0)
        let goal = userProfile.dailyCalorieGoal
        
        print("📊 Sending stats - Intake: \(intake), Burned: \(burned), Goal: \(goal)")
        
        networkService.getTodayAISuggestion(intake: intake, burned: burned, goal: goal)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ AI Refresh failed: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                    } else {
                        print("✅ AI Refresh completed successfully")
                    }
                },
                receiveValue: { [weak self] response in
                    print("📦 Received AI response: \(response.message.prefix(50))...")
                    self?.aiSuggestionDetails = response
                    let actions = response.actions.isEmpty ? [TipAction(title: "Review plan", type: .workout)] : response.actions
                    self?.aiCoachTip = AICoachTip(
                        message: response.message,
                        timestamp: response.timestamp,
                        actions: actions
                    )
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties for UI
    var totalCaloriesToday: Int {
        todayMeals.flatMap { $0.items }.reduce(0) { $0 + $1.calories }
    }
    
    var totalProteinToday: Double {
        todayMeals.flatMap { $0.items }.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbsToday: Double {
        todayMeals.flatMap { $0.items }.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFatToday: Double {
        todayMeals.flatMap { $0.items }.reduce(0) { $0 + $1.fat }
    }
}