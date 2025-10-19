import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Card #1: Weekly Training Overview
                WeeklyTrainingOverviewCard()
                
                // Card #2: Weekly Calorie Overview
                WeeklyCalorieOverviewCard()
                
                // Card #3: Progress Calendar
                ProgressCalendarCard(selectedDate: $selectedDate)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // Space for tab bar
        }
        .background(Color.gray.opacity(0.05))
        .navigationBarHidden(true)
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
        .background(Color.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Card #1: Weekly Training Overview
struct WeeklyTrainingOverviewCard: View {
    let trainingData = [
        ("Mon", 45, 60),
        ("Tue", 30, 60),
        ("Wed", 60, 60),
        ("Thu", 25, 60),
        ("Fri", 50, 60),
        ("Sat", 40, 60),
        ("Sun", 35, 60)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Weekly Training Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Week 23")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Bar Chart with Grid
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                                .offset(y: CGFloat(index) * geometry.size.height / 4)
                        }
                    }
                    
                    // Y-axis labels
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach([0, 20, 40, 60, 80], id: \.self) { value in
                                Text("\(value)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: geometry.size.height / 4, alignment: .bottom)
                            }
                        }
                        .frame(width: 30)
                        
                        // Chart area
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(trainingData, id: \.0) { day, actual, target in
                                VStack(spacing: 4) {
                                    VStack(spacing: 2) {
                                        // Target bar (green)
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.green.opacity(0.3))
                                            .frame(width: 20, height: CGFloat(target) / 80 * (geometry.size.height - 20))
                                        
                                        // Actual bar (blue)
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.blue)
                                            .frame(width: 20, height: CGFloat(actual) / 80 * (geometry.size.height - 20))
                                    }
                                    
                                    Text(day)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Card #2: Weekly Calorie Overview
struct WeeklyCalorieOverviewCard: View {
    let calorieData = [2200, 2400, 2100, 2500, 2300, 2600, 2400]
    let targetCalories = 2400
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Weekly Calorie Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Week 23")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Line Chart with Grid
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                                .offset(y: CGFloat(index) * geometry.size.height / 4)
                        }
                    }
                    
                    // Y-axis labels
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach([0, 700, 1400, 2100, 2800], id: \.self) { value in
                                Text("\(value)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(height: geometry.size.height / 4, alignment: .bottom)
                            }
                        }
                        .frame(width: 30)
                        
                        // Chart area
                        ZStack {
                            // Target line (dashed gray)
                            Path { path in
                                let targetY = geometry.size.height - (CGFloat(targetCalories) / 2800) * geometry.size.height
                                path.move(to: CGPoint(x: 0, y: targetY))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: targetY))
                            }
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                            
                            // Data line
                            Path { path in
                                for (index, calories) in calorieData.enumerated() {
                                    let x = CGFloat(index) / CGFloat(calorieData.count - 1) * geometry.size.width
                                    let y = geometry.size.height - (CGFloat(calories) / 2800) * geometry.size.height
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(Color.blue, lineWidth: 2)
                            
                            // Data points
                            ForEach(Array(calorieData.enumerated()), id: \.offset) { index, calories in
                                let x = CGFloat(index) / CGFloat(calorieData.count - 1) * geometry.size.width
                                let y = geometry.size.height - (CGFloat(calories) / 2800) * geometry.size.height
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 6, height: 6)
                                    .position(x: x, y: y)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 100)
            
            // Bottom Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("2,429 cal/day")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("2,400 cal/day")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Variance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("+29 cal/day")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Card #3: Progress Calendar
struct ProgressCalendarCard: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(selectedDate: Binding<Date>) {
        // Set initial month to October 2020
        var components = DateComponents()
        components.year = 2020
        components.month = 10
        components.day = 1
        let october2020 = Calendar.current.date(from: components) ?? Date()
        
        // Set selected date to October 8, 2020
        components.day = 8
        let october8 = Calendar.current.date(from: components) ?? Date()
        
        self._selectedDate = Binding(
            get: { october8 },
            set: { _ in }
        )
        self._currentMonth = State(initialValue: october2020)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with month navigation
            HStack {
                Text("Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
            
            // Calendar
            VStack(spacing: 8) {
                // Weekday headers
                HStack {
                    ForEach(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(calendarDays, id: \.self) { date in
                        if let date = date {
                            Button(action: {
                                selectedDate = date
                            }) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(isSelectedDate(date) ? .white : .primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(isSelectedDate(date) ? Color.red : Color.clear)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Text("")
                                .frame(width: 32, height: 32)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<32
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 // Convert to Monday = 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 0..<adjustedFirstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isSelectedDate(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func monthYearString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    SettingsView(viewModel: AppViewModel())
}
