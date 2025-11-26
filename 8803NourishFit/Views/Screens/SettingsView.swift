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
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Card #1: Weekly Training Overview
                    WeeklyTrainingOverviewCard()
                    
                    // Card #2: Weekly Calorie Overview
                    WeeklyCalorieOverviewCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // Space for tab bar
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
            
            // Floating dropdown menu
            if showingHeaderImagePickerOptions {
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
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSourceType)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingScanningView) {
            if let image = selectedImage {
                ScanningView(selectedImage: image, viewModel: viewModel)
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
    // TODO: Replace with actual training data from backend
    // Data represents calories burned during training each day
    let trainingData = [
        ("Mon", 45),
        ("Tue", 55),
        ("Wed", 40),
        ("Thu", 60),
        ("Fri", 50),
        ("Sat", 65),
        ("Sun", 55)
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
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 0) {
                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach([80, 60, 40, 20, 0], id: \.self) { value in
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
                                    .frame(width: 28, height: max(CGFloat(calories) / 80 * 240, 2))
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
    // TODO: Replace with actual intake data from backend
    let intakeData = [1700, 2000, 1600, 2150, 1900, 2300, 2000]
    let targetCalories = 2400
    
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
                    Text("2,429 cal/day")
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
                    Text("2,400 cal/day")
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
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
                    Text("+29 cal/day")
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255)) // #6366F1
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
