import Foundation
import SwiftUI
import Combine

// MARK: - Main App ViewModel
class AppViewModel: ObservableObject {
    @Published var currentTab: TabSelection = .home
    @Published var userProfile: UserProfile = UserProfile(
        name: "Aiony Haust",
        fitnessLevel: .beginner,
        goal: .fatLoss
    )
    @Published var progress: [Progress] = []
    @Published var calorieBalance: CalorieBalance?
    @Published var aiCoachTip: AICoachTip?
    @Published var progressMetrics: ProgressMetrics?
    @Published var workoutTimeData: [WorkoutTimeData] = []
    @Published var notifications: [AppNotification] = []
    @Published var suggestions: [Suggestion] = []
    @Published var calendarEvents: [CalendarEvent] = []
    @Published var scheduleItems: [ScheduleItem] = []
    @Published var settings: AppSettings = AppSettings()
    
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
}