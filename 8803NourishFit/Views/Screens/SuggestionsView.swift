import SwiftUI

// MARK: - Suggestions View
struct SuggestionsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingCustomizeSheet = false
    @State private var showingImagePicker = false
    @State private var showingHeaderImagePickerOptions = false
    @State private var selectedImage: UIImage?
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @State private var showingScanningView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Today's Suggestion Card
                        todaysSuggestionCard
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        // Why AI Recommended This Section
                        whyAIRecommendedSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
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
        }
        .sheet(isPresented: $showingCustomizeSheet) {
            CustomizeSuggestionsView()
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
    
    // MARK: - Today's Suggestion Card
    private var todaysSuggestionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("Today's Suggestion")
                .font(.headline)
                .fontWeight(.bold)
            
            // Subtitle
            Text("Based on your data analysis, I've customized today's plan for you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Training Section
            VStack(alignment: .leading, spacing: 12) {
                // Section Header
                HStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.yellow)
                        .font(.body)
                    
                    Text("Training")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                // Training Items
                VStack(spacing: 8) {
                    SuggestionItemRow(
                        title: "Squats",
                        details: "3 sets × 12 reps | 25min"
                    )
                    
                    SuggestionItemRow(
                        title: "Bench Press",
                        details: "3 sets × 10 reps | 20min"
                    )
                    
                    SuggestionItemRow(
                        title: "Deadlift",
                        details: "3 sets × 8 reps | 20min"
                    )
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            
            // Dietary Section
            VStack(alignment: .leading, spacing: 12) {
                // Section Header
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                        .font(.body)
                    
                    Text("Dietary")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                // Dietary Items
                VStack(spacing: 8) {
                    SuggestionItemRow(
                        title: "Protein",
                        details: "100g | 2 Eggs"
                    )
                    
                    SuggestionItemRow(
                        title: "Fiber",
                        details: "50g | 1 Carrot"
                    )
                    
                    SuggestionItemRow(
                        title: "Vitamin C",
                        details: "2g | 1 Apple"
                    )
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
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
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Accept Button
                Button(action: {
                    // Accept action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.body)
                        
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                
                // Regenerate Button
                Button(action: {
                    // Regenerate action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.blue)
                            .font(.body)
                        
                        Text("Regenerate")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
            }
            
            HStack(spacing: 12) {
                // Edit Button
                Button(action: {
                    // Edit action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.body)
                        
                        Text("Edit")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                
                // Delay Button
                Button(action: {
                    // Delay action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                            .font(.body)
                        
                        Text("Delay")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Why AI Recommended This Section
    // TODO: This section will be populated with backend data
    private var whyAIRecommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with match percentage and toggle
            HStack {
                Text("Why AI Recommended This")
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Gradient text for match percentage
                    Text("92% match")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                    Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Image(systemName: "chevron.up")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            // Reason Cards - TODO: Will be populated from backend
            VStack(spacing: 12) {
                // Card 1: Perfect for Your Schedule
                ReasonCard(
                    title: "Perfect for Your Schedule",
                    description: "You typically exercise in the night. This gentle yoga routine will help you wake up and set a positive tone for the day."
                )
                
                // Card 2: Low Impact, High Benefit
                ReasonCard(
                    title: "Low Impact, High Benefit",
                    description: "Based on your current activity level, this workout provides effective stretching without overexertion."
                )
                
                // Card 3: Builds Foundation
                ReasonCard(
                    title: "Builds Foundation",
                    description: "Improves flexibility and core strength, which will support you as you progress to more intense activities."
                )
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


// MARK: - Suggestion Item Row
struct SuggestionItemRow: View {
    let title: String
    let details: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Regenerate icon button
            Button(action: {
                // Regenerate this item
                print("Regenerate \(title)")
            }) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .font(.caption)
                            .fontWeight(.bold)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Title
            Text(title)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Details
            Text(details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Reason Card
struct ReasonCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Gradient title
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                            Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Customize Suggestions View
struct CustomizeSuggestionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Customize your suggestions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                // Customization options would go here
                
                Spacer()
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SuggestionsView(viewModel: AppViewModel())
}
