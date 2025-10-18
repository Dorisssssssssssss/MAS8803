import SwiftUI

// MARK: - Progress Card Component
struct ProgressCard: View {
    let progress: Progress
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Progress Content
            VStack(spacing: 12) {
                // Workouts Completed
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(progress.workoutsCompleted)/\(progress.totalWorkouts)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("Workouts Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progress Ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progress.workoutsCompleted) / CGFloat(progress.totalWorkouts))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int((CGFloat(progress.workoutsCompleted) / CGFloat(progress.totalWorkouts)) * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                // Stats Row
                HStack(spacing: 20) {
                    StatItem(
                        icon: "flame.fill",
                        value: "\(progress.caloriesBurned)",
                        label: "Calories",
                        color: .orange
                    )
                    
                    StatItem(
                        icon: "clock.fill",
                        value: "\(progress.duration)m",
                        label: "Duration",
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
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProgressCard(
        progress: Progress(
            date: Date(),
            workoutsCompleted: 3,
            totalWorkouts: 5,
            caloriesBurned: 450,
            duration: 60
        ),
        title: "Progress"
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

