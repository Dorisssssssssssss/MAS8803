import SwiftUI

// MARK: - Calorie Balance Card Component
struct CalorieBalanceCard: View {
    @ObservedObject var viewModel: AppViewModel
    
    // Goals - these can be made configurable from backend
    private let intakeGoal = 2100
    private let consumeGoal = 1500
    
    private var intakeCurrent: Int {
        // TODO: Replace with actual intake data from backend
        2500 // Sample data showing over goal
    }
    
    private var consumeCurrent: Int {
        // TODO: Replace with actual consume data from backend
        500 // Sample data
    }
    
    private var intakePercentage: Double {
        Double(intakeCurrent) / Double(intakeGoal)
    }
    
    private var consumePercentage: Double {
        Double(consumeCurrent) / Double(consumeGoal)
    }
    
    // Check if intake is over goal
    private var isIntakeOverGoal: Bool {
        intakeCurrent > intakeGoal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("Today's Calorie Balance")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Intake Section
            CalorieSection(
                title: "Intake",
                current: intakeCurrent,
                goal: intakeGoal,
                percentage: intakePercentage,
                isOverGoal: isIntakeOverGoal
            )
            
            // Consume Section
            CalorieSection(
                title: "Consume",
                current: consumeCurrent,
                goal: consumeGoal,
                percentage: consumePercentage,
                isOverGoal: false
            )
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 239/255, green: 245/255, blue: 255/255), // #EFF5FF
                    Color(red: 250/255, green: 245/255, blue: 255/255)  // #FAF5FF
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Calorie Section Component
struct CalorieSection: View {
    let title: String
    let current: Int
    let goal: Int
    let percentage: Double
    let isOverGoal: Bool
    
    // Define custom colors
    private let normalBlue = Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF
    private let normalPurple = Color(red: 135/255, green: 93/255, blue: 245/255) // #875DF5
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Row: Title and Goal
            HStack(alignment: .center) {
                // Left: Title and Current Value
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(current)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isOverGoal ? .red : normalBlue)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Right: Goal
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(goal)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                isOverGoal ?
                                // Over goal: orange to red gradient
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                // Normal: blue to purple gradient (#007AFF to #875DF5)
                                LinearGradient(
                                    colors: [normalBlue, normalPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: min(geometry.size.width * CGFloat(percentage), geometry.size.width), height: 8)
                    }
                }
                .frame(height: 8)
                
                // Percentage Text
                Text("\(Int(percentage * 100))% done")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CalorieBalanceCard(viewModel: AppViewModel())
    .padding()
    .background(Color.gray.opacity(0.1))
}



