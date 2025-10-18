import SwiftUI

// MARK: - Calorie Balance Card Component
struct CalorieBalanceCard: View {
    let calorieBalance: CalorieBalance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Today's Calorie Balance")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Main Calorie Display
            HStack(spacing: 20) {
                // Intake
                VStack(alignment: .leading, spacing: 4) {
                    Text("Intake")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(calorieBalance.intake)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progress Bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress Fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(calorieBalance.percentage), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(calorieBalance.percentage * 100))% done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Goal
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(calorieBalance.goal)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bottom Stats
            HStack(spacing: 12) {
                // Burned
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Burned")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(calorieBalance.burned) kcal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                // Remaining
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(calorieBalance.remaining) kcal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    CalorieBalanceCard(
        calorieBalance: CalorieBalance(
            date: Date(),
            intake: 1847,
            goal: 2100,
            burned: 2234,
            remaining: 253
        )
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}


