import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Quick Log Section
                    quickLogSection
                    
                    // Today's Intake Record Section
                    todaysIntakeRecordSection
                    
                    // Today's Workout Record Section
                    todaysWorkoutRecordSection
                    
                    // Body Metrics Section
                    bodyMetricsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Profile Section
            HStack(spacing: 12) {
                // Profile Image
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.userProfile.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Today • \(formatDate(Date()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action Icons
            HStack(spacing: 16) {
                Button(action: {
                    // Camera action
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                
                Button(action: {
                    // Notification action
                }) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Quick Log Section
    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Log")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                // Meals Button
                QuickLogButton(
                    title: "Meals",
                    icon: "fork.knife",
                    backgroundColor: Color.blue.opacity(0.2),
                    iconColor: .white
                )
                
                // Workout Button
                QuickLogButton(
                    title: "Workout",
                    icon: "dumbbell.fill",
                    backgroundColor: Color.green.opacity(0.2),
                    iconColor: .white
                )
                
                // Body Metrics Button
                QuickLogButton(
                    title: "Body Metrics",
                    icon: "hexagon.fill",
                    backgroundColor: Color.purple.opacity(0.2),
                    iconColor: .white
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Today's Intake Record Section
    private var todaysIntakeRecordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Intake Record")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // View all intake records
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            // Food Items
            VStack(spacing: 12) {
                FoodItemRow(
                    icon: "apple.fill",
                    iconColor: .orange,
                    name: "Apple",
                    quantity: "1"
                )
                
                FoodItemRow(
                    icon: "bread.fill",
                    iconColor: .yellow,
                    name: "Whole wheat bread",
                    quantity: "2"
                )
            }
            
            // Nutrition Intake Summary
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Nutrition Intake")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("1245 / 1800 kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    // Protein
                    NutritionProgressBar(
                        label: "Protein 165g",
                        progress: 0.8,
                        color: .purple
                    )
                    
                    // Carbs
                    NutritionProgressBar(
                        label: "Carbs 80g",
                        progress: 0.45,
                        color: .blue
                    )
                    
                    // Fat
                    NutritionProgressBar(
                        label: "Fat 45g",
                        progress: 0.65,
                        color: .green
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Today's Workout Record Section
    private var todaysWorkoutRecordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Workout Record")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Squats
                WorkoutItemRow(
                    title: "Squats",
                    details: "3 sets x 12 reps",
                    time: "25mins",
                    isCompleted: true
                )
                
                // Bench Press
                WorkoutItemRow(
                    title: "Bench Press",
                    details: "3 sets x 10 reps",
                    time: "20mins",
                    isCompleted: true
                )
                
                // Deadlift
                WorkoutItemRow(
                    title: "Deadlift",
                    details: "3 sets x 8 reps",
                    time: nil,
                    isCompleted: false,
                    showActionButtons: true
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Body Metrics Section
    private var bodyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Body Metrics")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Edit") {
                    // Edit body metrics
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 12) {
                // Weight Card
                BodyMetricCard(
                    icon: "scalemass.fill",
                    iconColor: .blue,
                    backgroundColor: Color.blue.opacity(0.1),
                    period: "This Week",
                    value: "68.5",
                    unit: "Weight (kg)"
                )
                
                // Waist Card
                BodyMetricCard(
                    icon: "ruler.fill",
                    iconColor: .green,
                    backgroundColor: Color.green.opacity(0.1),
                    period: "This Week",
                    value: "74",
                    unit: "Waist (cm)"
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Quick Log Button
struct QuickLogButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .cornerRadius(10)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Food Item Row
struct FoodItemRow: View {
    let icon: String
    let iconColor: Color
    let name: String
    let quantity: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 30, height: 30)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(quantity)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Nutrition Progress Bar
struct NutritionProgressBar: View {
    let label: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Workout Item Row
struct WorkoutItemRow: View {
    let title: String
    let details: String
    let time: String?
    let isCompleted: Bool
    var showActionButtons: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Status
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let time = time {
                Text(time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            } else if showActionButtons {
                HStack(spacing: 8) {
                    Button("Swap") {
                        // Swap action
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Button("Complete") {
                        // Complete action
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
        }
    }
}

// MARK: - Body Metric Card
struct BodyMetricCard: View {
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    let period: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(period)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}



// MARK: - Preview
#Preview {
    CalendarView(viewModel: AppViewModel())
}
