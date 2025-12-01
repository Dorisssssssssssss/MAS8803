import Foundation

// MARK: - User Profile Model
struct UserProfile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var fitnessLevel: FitnessLevel
    var goal: FitnessGoal
    var profileImage: String?
    
    // Nutritional Goals
    var dailyCalorieGoal: Int
    var proteinGoal: Int // g
    var carbsGoal: Int // g
    var fatGoal: Int // g
    
    enum FitnessLevel: String, CaseIterable, Codable {
        case beginner = "Fitness Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    enum FitnessGoal: String, CaseIterable, Codable {
        case fatLoss = "Fat Loss Goal"
        case muscleGain = "Muscle Gain"
        case endurance = "Endurance"
        case general = "General Fitness"
    }
}

// MARK: - Workout Plan Model
struct WorkoutPlan: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var duration: Int // minutes
    var exercises: [Exercise]
    var isCompleted: Bool = false
    var date: Date
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var duration: Int? // for time-based exercises
    var isCompleted: Bool = false
}

// MARK: - Progress Model
struct Progress: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var workoutsCompleted: Int
    var totalWorkouts: Int
    var caloriesBurned: Int
    var duration: Int // minutes
}

// MARK: - Calorie Balance Model
struct CalorieBalance: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var intake: Int
    var goal: Int
    var burned: Int
    var remaining: Int
    
    var percentage: Double {
        return Double(intake) / Double(goal)
    }
}

// MARK: - AICoachTip Model
struct AICoachTip: Identifiable, Codable {
    let id = UUID()
    var message: String
    var timestamp: Date
    var actions: [TipAction]
}

struct TipAction: Identifiable, Codable {
    let id = UUID()
    var title: String
    var type: ActionType
    
    enum ActionType: String, CaseIterable, Codable {
        case hiit
        case walk
        case workout
        case rest
        case nutrition
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self).lowercased()
            if let type = ActionType(rawValue: value) {
                self = type
            } else {
                self = .workout
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}

// MARK: - Progress Metrics Model
struct ProgressMetrics: Identifiable, Codable {
    let id = UUID()
    var trainingDays: Int
    var totalTrainingDays: Int
    var weightChange: Double // kg
    var planCompletion: Int // percentage
    var macros: Macronutrients
}

struct Macronutrients: Codable {
    var protein: Int // percentage
    var carbs: Int // percentage
    var fat: Int // percentage
}

// MARK: - WorkoutTimeData Model
struct WorkoutTimeData: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var duration: Int // minutes
}

// MARK: - Notification Model
struct AppNotification: Identifiable, Codable {
    let id = UUID()
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool = false
    var type: NotificationType
    
    enum NotificationType: String, CaseIterable, Codable {
        case workout = "Workout"
        case reminder = "Reminder"
        case achievement = "Achievement"
        case system = "System"
    }
}

// MARK: - Suggestion Model
struct Suggestion: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var category: SuggestionCategory
    var isAccepted: Bool = false
    var timestamp: Date
    
    enum SuggestionCategory: String, CaseIterable, Codable {
        case aerobic = "Aerobic Substitution"
        case equipment = "No equipment substitution"
        case walking = "Stair/Walking Plan"
    }
}

// MARK: - Calendar Event Model
struct CalendarEvent: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var date: Date
    var duration: Int // minutes
    var type: EventType
    var isCompleted: Bool = false
    
    enum EventType: String, CaseIterable, Codable {
        case workout = "Workout"
        case rest = "Rest Day"
        case goal = "Goal"
        case custom = "Custom"
    }
}

// MARK: - Settings Model
struct AppSettings: Codable {
    var notificationsEnabled: Bool = true
    var workoutReminders: Bool = true
    var dataIntegration: Bool = true
    var accessibility: AccessibilitySettings = AccessibilitySettings()
    var privacy: PrivacySettings = PrivacySettings()
}

struct AccessibilitySettings: Codable {
    var voiceOverEnabled: Bool = false
    var largeTextEnabled: Bool = false
    var highContrastEnabled: Bool = false
}

struct PrivacySettings: Codable {
    var dataSharing: Bool = false
    var analyticsEnabled: Bool = false
    var locationServices: Bool = false
}
