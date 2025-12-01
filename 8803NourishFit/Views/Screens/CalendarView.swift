import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingImagePicker = false
    @State private var showingHeaderImagePickerOptions = false
    @State private var selectedImage: UIImage?
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingScanningView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // Main Content
                mainContentView
                
                // Floating dropdown menu
                if showingHeaderImagePickerOptions {
                    floatingDropdownMenu
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSourceType)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingScanningView) {
            if let image = selectedImage {
                ScanningView(selectedImage: image, mealType: "Snack", viewModel: viewModel)
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
                
                // Quick Log Section
                quickLogSection
                
                // Today's Intake Record Section
                todaysIntakeRecordSection
                
                // Today's Workout Record Section
                todaysWorkoutRecordSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
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
    
    // MARK: - Quick Log Section
    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Log")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                // Meals Button
                QuickLogButton(
                    title: "Meals",
                    icon: "fork.knife",
                    backgroundColor: Color.blue.opacity(0.2),
                    iconColor: .white
                )
                
                // Workout Button
                QuickLogButton(
                    title: "Workout",
                    icon: "dumbbell.fill",
                    backgroundColor: Color.green.opacity(0.2),
                    iconColor: .white
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Today's Intake Record Section
    private var todaysIntakeRecordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Intake Record")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // View all intake records
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            // Food Items
            VStack(spacing: 8) {
                if viewModel.todayMeals.isEmpty {
                    Text("No meals recorded today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(viewModel.todayMeals.flatMap { $0.items }, id: \.name) { item in
                        IntakeRecordRow(name: item.name, quantity: "\(Int(item.calories)) kcal")
                    }
                }
            }
            
            // Nutrition Intake Summary
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Nutrition Intake")
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Text("\(viewModel.totalCaloriesToday)")
                            .font(.system(size: 11))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 62/255, green: 129/255, blue: 246/255))
                        
                        Text("/ \(viewModel.userProfile.dailyCalorieGoal) kcal")
                            .font(.system(size: 11))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 135/255, green: 93/255, blue: 245/255).opacity(0.7))
                    }
                }
                
                // Macronutrients in one row
                HStack(spacing: 12) {
                    // Protein
                    MacroProgressItem(
                        label: "Protein",
                        value: "\(Int(viewModel.totalProteinToday))g",
                        progress: min(viewModel.totalProteinToday / Double(viewModel.userProfile.proteinGoal), 1.0),
                        color: Color(red: 147/255, green: 51/255, blue: 234/255) // Purple
                    )
                    
                    // Carbs
                    MacroProgressItem(
                        label: "Carbs",
                        value: "\(Int(viewModel.totalCarbsToday))g",
                        progress: min(viewModel.totalCarbsToday / Double(viewModel.userProfile.carbsGoal), 1.0),
                        color: Color(red: 59/255, green: 130/255, blue: 246/255) // Blue
                    )
                    
                    // Fat
                    MacroProgressItem(
                        label: "Fat",
                        value: "\(Int(viewModel.totalFatToday))g",
                        progress: min(viewModel.totalFatToday / Double(viewModel.userProfile.fatGoal), 1.0),
                        color: Color(red: 34/255, green: 197/255, blue: 94/255) // Green
                    )
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 239/255, green: 245/255, blue: 255/255),  // #EFF5FF
                        Color(red: 250/255, green: 245/255, blue: 255/255)   // #FAF5FF
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Today's Workout Record Section
    private var todaysWorkoutRecordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Workout Record")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if let exercises = viewModel.todayWorkouts?.exercises, !exercises.isEmpty {
                    ForEach(exercises, id: \.name) { exercise in
                        WorkoutItemRow(
                            title: exercise.name,
                            details: "\(exercise.sets) sets x \(exercise.reps) reps",
                            time: exercise.duration != nil ? "\(exercise.duration!)mins" : nil,
                            isCompleted: exercise.isCompleted,
                            showActionButtons: false
                        )
                    }
                } else {
                    Text("No workouts recorded today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
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

// MARK: - Quick Log Button
struct QuickLogButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .cornerRadius(10)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Intake Record Row
struct IntakeRecordRow: View {
    let name: String
    let quantity: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(quantity)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 249/255, green: 250/255, blue: 251/255)) // #F9FAFB
        .cornerRadius(10)
    }
}

// MARK: - Macro Progress Item (Horizontal Layout)
struct MacroProgressItem: View {
    let label: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and Value
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress Fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Workout Item Row
struct WorkoutItemRow: View {
    let title: String
    let details: String
    let time: String?
    let isCompleted: Bool
    var showActionButtons: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Status
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let time = time {
                Text(time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            } else if showActionButtons {
                HStack(spacing: 8) {
                    Button("Swap") {
                        // Swap action
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Button("Complete") {
                        // Complete action
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
        }
    }
}




// MARK: - Preview
#Preview {
    CalendarView(viewModel: AppViewModel())
}


