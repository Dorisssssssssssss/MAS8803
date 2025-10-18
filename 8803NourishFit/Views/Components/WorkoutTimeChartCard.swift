import SwiftUI

// MARK: - Workout Time Chart Card Component
struct WorkoutTimeChartCard: View {
    let workoutTimeData: [WorkoutTimeData]
    
    private let chartHeight: CGFloat = 150
    private let maxYValue: CGFloat = 80
    private let yAxisSteps = [0, 20, 40, 60, 80]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Workout Time")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Chart
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    // Background and Grid Lines
                    VStack(spacing: 0) {
                        ForEach(yAxisSteps.reversed(), id: \.self) { value in
                            HStack {
                                // Y-axis label
                                Text("\(value)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 25, alignment: .trailing)
                                
                                // Grid line
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 0.5)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: chartHeight / CGFloat(yAxisSteps.count - 1))
                        }
                    }
                    
                    // Line Chart
                    if workoutTimeData.count > 1 {
                        Path { path in
                            let chartWidth = geometry.size.width - 40
                            let chartHeight = self.chartHeight
                            let stepX = chartWidth / CGFloat(workoutTimeData.count - 1)
                            
                            for (index, data) in workoutTimeData.enumerated() {
                                let x = 30 + CGFloat(index) * stepX
                                let y = chartHeight - (CGFloat(data.duration) / maxYValue * chartHeight)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        
                        // Data points
                        ForEach(workoutTimeData.indices, id: \.self) { index in
                            let data = workoutTimeData[index]
                            let chartWidth = geometry.size.width - 40
                            let stepX = chartWidth / CGFloat(workoutTimeData.count - 1)
                            let x = 30 + CGFloat(index) * stepX
                            let y = chartHeight - (CGFloat(data.duration) / maxYValue * chartHeight)
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                    
                    // X-axis labels
                    HStack(spacing: 0) {
                        ForEach(workoutTimeData.indices, id: \.self) { index in
                            let data = workoutTimeData[index]
                            let chartWidth = geometry.size.width - 40
                            let stepX = chartWidth / CGFloat(workoutTimeData.count - 1)
                            
                            Text(formatDate(data.date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: stepX, alignment: .center)
                                .offset(x: index == 0 ? 15 : (index == workoutTimeData.count - 1 ? -15 : 0))
                        }
                    }
                    .offset(y: chartHeight + 15)
                }
            }
            .frame(height: chartHeight + 40)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    WorkoutTimeChartCard(
        workoutTimeData: [
            WorkoutTimeData(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), duration: 45),
            WorkoutTimeData(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), duration: 60),
            WorkoutTimeData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), duration: 30),
            WorkoutTimeData(date: Date(), duration: 75)
        ]
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
