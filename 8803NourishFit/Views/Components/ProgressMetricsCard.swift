import SwiftUI

// MARK: - Progress Metrics Card Component
struct ProgressMetricsCard: View {
    let progressMetrics: ProgressMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Circular Progress Indicators
            HStack(spacing: 20) {
                // Training Days
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progressMetrics.trainingDays) / CGFloat(progressMetrics.totalTrainingDays))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(progressMetrics.trainingDays)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Training Days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(progressMetrics.trainingDays)/\(progressMetrics.totalTrainingDays)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Weight Change
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.green.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .stroke(Color.green, lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Text(progressMetrics.weightChange >= 0 ? "+\(String(format: "%.1f", progressMetrics.weightChange))" : "\(String(format: "%.1f", progressMetrics.weightChange))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Weight Change")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("kg")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Plan Completion
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progressMetrics.planCompletion) / 100.0)
                            .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(progressMetrics.planCompletion)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Plan Completion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Macros Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Macros")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                // Macro Donut Chart
                HStack(spacing: 20) {
                    // Donut Chart
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                            .frame(width: 120, height: 120)
                        
                        // Protein segment (Purple)
                        Circle()
                            .trim(from: 0, to: CGFloat(progressMetrics.macros.protein) / 100.0)
                            .stroke(Color.purple, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        // Carb segment (Blue) - starts after protein
                        Circle()
                            .trim(from: CGFloat(progressMetrics.macros.protein) / 100.0, 
                                  to: CGFloat(progressMetrics.macros.protein + progressMetrics.macros.carbs) / 100.0)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        // Fat segment (Teal/Green) - starts after protein + carb
                        Circle()
                            .trim(from: CGFloat(progressMetrics.macros.protein + progressMetrics.macros.carbs) / 100.0, 
                                  to: 1.0)
                            .stroke(Color.teal, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        // Percentage labels positioned around the donut
                        // Protein label (top-left)
                        Text("\(progressMetrics.macros.protein)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .offset(x: -30, y: -30)
                        
                        // Carb label (top-right)
                        Text("\(progressMetrics.macros.carbs)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .offset(x: 30, y: -30)
                        
                        // Fat label (bottom-right)
                        Text("\(progressMetrics.macros.fat)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .offset(x: 30, y: 30)
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        // Carb
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                            Text("Carb")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Fat
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 12, height: 12)
                            Text("Fat")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Protein
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 12, height: 12)
                            Text("Protein")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
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
    ProgressMetricsCard(
        progressMetrics: ProgressMetrics(
            trainingDays: 5,
            totalTrainingDays: 6,
            weightChange: -0.8,
            planCompletion: 92,
            macros: Macronutrients(protein: 23, carbs: 45, fat: 32)
        )
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
