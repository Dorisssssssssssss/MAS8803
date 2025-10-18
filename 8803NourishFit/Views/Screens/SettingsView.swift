import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Weekly Training Overview Section
                    weeklyTrainingOverviewSection
                    
                    // Calendar Schedule Section
                    calendarScheduleSection
                    
                    // AI Prediction Adjustment Section
                    aiPredictionAdjustmentSection
                    
                    // Quick Operation Section
                    quickOperationSection
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
                    Image(systemName: "camera")
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
    
    // MARK: - Weekly Training Overview Section
    private var weeklyTrainingOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Training Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Week 23")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                // Strength Training
                TrainingProgressRow(
                    title: "Strength Training",
                    percentage: 60,
                    color: .blue
                )
                
                // Aerobic Training
                TrainingProgressRow(
                    title: "Aerobic Training",
                    percentage: 40,
                    color: .green
                )
            }
            
            // AI Dynamic Adjustment Range
            HStack(spacing: 12) {
                Image(systemName: "robot")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Dynamic Adjustment Range")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 16) {
                        Text("Duration: ±20%")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("Intensity: ±20%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Calendar Schedule Section
    private var calendarScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Calendar Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Customize") {
                    // Customize action
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                // Monday 26
                ScheduleRow(
                    day: "Monday 26",
                    title: "Strength Training",
                    time: "9:00 a.m - 10:30 a.m",
                    status: .normal,
                    color: .blue
                )
                
                // Tuesday 27 - Time Conflict
                ScheduleRow(
                    day: "Tuesday 27",
                    title: "Time Conflict",
                    subtitle: "Meeting vs Aerobic Training",
                    time: "",
                    status: .conflict,
                    color: .red
                )
                
                // Wednesday 26
                ScheduleRow(
                    day: "Wednesday 26",
                    title: "Aerobic Training",
                    time: "7:00 p.m - 8:00 p.m",
                    status: .normal,
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - AI Prediction Adjustment Section
    private var aiPredictionAdjustmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Prediction Adjustment")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Historical Behavior
                PredictionCard(
                    title: "Historical Behavior",
                    accuracy: "85% Accuracy",
                    description: "You typically reduce your training intensity by 15% on Thursdays. It is recommended to adjust your schedule in advance.",
                    backgroundColor: Color.blue.opacity(0.1),
                    textColor: .blue
                )
                
                // Schedule Conflict
                PredictionCard(
                    title: "Schedule conflict",
                    accuracy: "2 Conflicts",
                    description: "There may be overtime on Friday evening, so it is recommended to reschedule the training to Saturday morning.",
                    backgroundColor: Color.yellow.opacity(0.1),
                    textColor: .orange
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Quick Operation Section
    private var quickOperationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Operation")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickOperationButton(
                    title: "Regenerate",
                    icon: "arrow.clockwise",
                    color: .blue
                )
                
                QuickOperationButton(
                    title: "Edit",
                    icon: "pencil",
                    color: .yellow
                )
                
                QuickOperationButton(
                    title: "Share",
                    icon: "square.and.arrow.up",
                    color: .green
                )
                
                QuickOperationButton(
                    title: "History",
                    icon: "clock",
                    color: .gray
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

// MARK: - Training Progress Row
struct TrainingProgressRow: View {
    let title: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(percentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(CGFloat(percentage) / 100.0 * geometry.size.width, geometry.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Schedule Row
struct ScheduleRow: View {
    let day: String
    let title: String
    var subtitle: String = ""
    let time: String
    let status: ScheduleStatus
    let color: Color
    
    enum ScheduleStatus {
        case normal
        case conflict
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(status == .conflict ? .red : .primary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                if !time.isEmpty {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if status == .conflict {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(status == .conflict ? Color.red.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Prediction Card
struct PredictionCard: View {
    let title: String
    let accuracy: String
    let description: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(accuracy)
                    .font(.caption)
                    .foregroundColor(textColor)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

// MARK: - Quick Operation Button
struct QuickOperationButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Action
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    SettingsView(viewModel: AppViewModel())
}
