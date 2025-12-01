import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedDate = Date()
    @State private var showingImagePicker = false
    @State private var showingHeaderImagePickerOptions = false
    @State private var selectedImage: UIImage?
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingScanningView = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Content
            mainContentView
            
            // Floating dropdown menu
            if showingHeaderImagePickerOptions {
                floatingDropdownMenu
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSourceType)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingScanningView) {
            if let image = selectedImage {
                ScanningView(isPresented: $showingScanningView, selectedImage: image, mealType: "Snack", viewModel: viewModel)
            }
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let _ = newValue {
                showingScanningView = true
            }
        }
        .onChange(of: showingScanningView) { oldValue, newValue in
            if !newValue {
                selectedImage = nil
            }
        }
        .onTapGesture {
            if showingHeaderImagePickerOptions {
                withAnimation {
                    showingHeaderImagePickerOptions = false
                }
            }
        }
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Card #1: Weekly Training Overview
                WeeklyTrainingOverviewCard(viewModel: viewModel)
                
                // Card #2: Weekly Calorie Overview
                WeeklyCalorieOverviewCard(viewModel: viewModel)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100) // Space for tab bar
        }
        .background(Color.gray.opacity(0.05))
        .navigationBarHidden(true)
    }
    
    // MARK: - Floating Dropdown Menu
    private var floatingDropdownMenu: some View {
        VStack(spacing: 12) {
            // Camera Button
            Button(action: {
                imageSourceType = .camera
                showingHeaderImagePickerOptions = false
                showingImagePicker = true
            }) {
                Text("Camera")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 62/255, green: 129/255, blue: 246/255),
                                Color(red: 135/255, green: 93/255, blue: 245/255)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }
            
            // Photo Library Button
            Button(action: {
                imageSourceType = .photoLibrary
                showingHeaderImagePickerOptions = false
                showingImagePicker = true
            }) {
                Text("Photo Library")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 239/255, green: 239/255, blue: 239/255))
                    .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        .frame(width: 200)
        .offset(x: -20, y: 80)
        .transition(.opacity.combined(with: .scale))
        .zIndex(1000)
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
                    withAnimation {
                        showingHeaderImagePickerOptions.toggle()
                    }
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Card #1: Weekly Training Overview
struct WeeklyTrainingOverviewCard: View {
    @ObservedObject var viewModel: AppViewModel
    
    // Generate data from viewModel.weeklyWorkoutHistory
    var trainingData: [(String, Int)] {
        let history = viewModel.weeklyWorkoutHistory
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, etc.
        
        // Generate last 7 days
        var data: [(String, Int)] = []
        let today = Date()
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -6 + i, to: today) {
                let dayName = formatter.string(from: date)
                // Find matching data
                let duration = history.first(where: { calendar.isDate($0.date, inSameDayAs: date) })?.duration ?? 0
                data.append((dayName, duration))
            }
        }
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Weekly Training Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Bar Chart with Grid
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        // Adjusted Y-axis scale for calories (e.g. 0-800 kcal)
                        ForEach([800, 600, 400, 200, 0], id: \.self) { value in
                            Text("\(value)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(height: 240 / 4, alignment: .top)
                        }
                    }
                    .frame(width: 30)
                    
                    // Chart area
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines (horizontal dashed lines)
                        VStack(spacing: 0) {
                            ForEach(0..<5) { index in
                                Spacer()
                                    .frame(height: 240 / 4)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                            .frame(height: 1),
                                        alignment: .top
                                    )
                            }
                        }
                        .frame(height: 240)
                        
                        // Bars
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(trainingData, id: \.0) { day, calories in
                                // Single bar (blue-purple gradient)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                                Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                            ]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    // Normalize height relative to max 800 kcal
                                    .frame(width: 28, height: max(CGFloat(calories) / 800 * 240, 2))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 8)
                    }
                    .frame(height: 240)
                }
                .frame(height: 240)
                
                // X-axis labels (Day names)
                HStack(alignment: .top, spacing: 0) {
                    Spacer()
                        .frame(width: 30) // Align with Y-axis labels
                    
                    HStack(spacing: 12) {
                        ForEach(trainingData, id: \.0) { day, _ in
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 28)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Card #2: Weekly Intake Overview
struct WeeklyCalorieOverviewCard: View {
    @ObservedObject var viewModel: AppViewModel
    
    var intakeData: [Int] {
        if viewModel.weeklyIntakeHistory.isEmpty {
            return [1800, 1950, 1700, 2100, 1850, 2200, 0]
        }
        return viewModel.weeklyIntakeHistory
    }
    
    let targetCalories = 2100
    
    var averageIntake: Int {
        let sum = intakeData.reduce(0, +)
        return intakeData.isEmpty ? 0 : sum / intakeData.count
    }
    
    var variance: Int {
        averageIntake - targetCalories
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Weekly Intake Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Week 23")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Line Chart with Grid
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach([2800, 2100, 1400, 700, 0], id: \.self) { value in
                            Text("\(value)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(height: 240 / 4, alignment: .top)
                        }
                    }
                    .frame(width: 40)
                    
                    // Chart area
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines (horizontal dashed lines)
                        VStack(spacing: 0) {
                            ForEach(0..<5) { index in
                                Spacer()
                                    .frame(height: 240 / 4)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                            .frame(height: 1),
                                        alignment: .top
                                    )
                            }
                        }
                        .frame(height: 240)
                        
                        // Line chart
                        GeometryReader { geometry in
                            ZStack {
                                // Data line with gradient stroke
                                Path { path in
                                    for (index, calories) in intakeData.enumerated() {
                                        let x = CGFloat(index) / CGFloat(intakeData.count - 1) * geometry.size.width
                                        let y = geometry.size.height - (CGFloat(calories) / 2800) * geometry.size.height
                                        
                                        if index == 0 {
                                            path.move(to: CGPoint(x: x, y: y))
                                        } else {
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                }
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                            Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                                
                                // Data points (teal-green circles)
                                ForEach(Array(intakeData.enumerated()), id: \.offset) { index, calories in
                                    let x = CGFloat(index) / CGFloat(intakeData.count - 1) * geometry.size.width
                                    let y = geometry.size.height - (CGFloat(calories) / 2800) * geometry.size.height
                                    
                                    Circle()
                                        .fill(Color(red: 48/255, green: 176/255, blue: 199/255)) // Teal-green
                                        .frame(width: 8, height: 8)
                                        .position(x: x, y: y)
                                }
                            }
                        }
                        .frame(height: 240)
                        .padding(.horizontal, 8)
                    }
                    .frame(height: 240)
                }
                .frame(height: 240)
                
                // X-axis labels (Day names)
                HStack(alignment: .top, spacing: 0) {
                    Spacer()
                        .frame(width: 40) // Align with Y-axis labels
                    
                    HStack(spacing: 0) {
                        ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            
            // Bottom Stats with dividers
            HStack(spacing: 12) {
                // Weekly Average
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(averageIntake) cal/day")
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255)) // #6366F1
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                // Target
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(targetCalories) cal/day")
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                // Variance
                VStack(alignment: .leading, spacing: 4) {
                    Text("Variance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(variance > 0 ? "+" : "")\(variance) cal/day")
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(variance > 0 ? .red : .green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
    SettingsView(viewModel: AppViewModel())
}
