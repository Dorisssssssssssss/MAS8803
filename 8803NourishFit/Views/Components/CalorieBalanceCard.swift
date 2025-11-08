import SwiftUI

// MARK: - Calorie Balance Card Component
struct CalorieBalanceCard: View {
    @ObservedObject var viewModel: AppViewModel
    
    private var calorieBalance: CalorieBalance {
        CalorieBalance(
            date: Date(),
            intake: viewModel.totalCaloriesToday,
            goal: 2100, // Default goal, can be made configurable
            burned: 0, // Will be updated when workout data is available
            remaining: max(0, 2100 - viewModel.totalCaloriesToday)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Today's Calorie Balance")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Main Calorie Display
            VStack(spacing: 16) {
                // Intake Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intake")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        Text("\(calorieBalance.intake)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                    }
                }
                
                // Progress Section
                VStack(spacing: 8) {
                    HStack {
                        Text("Goal \(calorieBalance.goal) kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(calorieBalance.percentage * 100))% done")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
                }
                
                // Bottom Stats
                HStack(spacing: 16) {
                    // Burned
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Burned")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calorieBalance.burned) kcal")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Remaining
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calorieBalance.remaining) kcal")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
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
    CalorieBalanceCard(viewModel: AppViewModel())
        .padding()
        .background(Color.gray.opacity(0.1))
}



