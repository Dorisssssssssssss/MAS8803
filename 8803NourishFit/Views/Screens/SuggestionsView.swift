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
    
    private var currentSuggestion: AISuggestionResponse? {
        viewModel.aiSuggestionDetails
    }
    
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
                ScanningView(selectedImage: image, mealType: "Snack", viewModel: viewModel)
            }
        }
        .onChange(of: selectedImage) { _, newValue in
            if let _ = newValue {
                showingScanningView = true
            }
        }
        .onChange(of: showingScanningView) { _, newValue in
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
            
            // Introductory Text from AI suggestion
            Text(currentSuggestion?.message ?? "Based on your data analysis, I've customized today's plan for you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Training Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: currentSuggestion?.suggestions.training?.icon, fallback: "dumbbell.fill"))
                        .foregroundColor(.yellow)
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentSuggestion?.suggestions.training?.title ?? "Training Adjustment")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(currentSuggestion?.suggestions.training?.description ?? "Reduce aerobic exercise by 20 minutes and increase strength training.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Training Items (static sample list)
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
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: currentSuggestion?.suggestions.diet?.icon, fallback: "apple.fill"))
                        .foregroundColor(.green)
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentSuggestion?.suggestions.diet?.title ?? "Dietary Adjustments")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(currentSuggestion?.suggestions.diet?.description ?? "Increase protein by 15g, reduce carbohydrates by 30g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
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
            
            // Why do we recommend this?
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Why do we recommend this?")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text((currentSuggestion?.reasoning?.isEmpty == false ? currentSuggestion?.reasoning : "Click to view detailed analysis") ?? "Click to view detailed analysis")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 239/255, green: 245/255, blue: 255/255),
                    Color(red: 250/255, green: 245/255, blue: 255/255)
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
                // Accept Button (placeholder)
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
                
                // Regenerate Button: use your AI refresh logic
                Button(action: {
                    viewModel.refreshAICoachTip()
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
    private var whyAIRecommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Why AI Recommended This")
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("92% match")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 62/255, green: 129/255, blue: 246/255),
                                    Color(red: 135/255, green: 93/255, blue: 245/255)
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
            
            VStack(spacing: 12) {
                ReasonCard(
                    title: "Perfect for Your Schedule",
                    description: "You typically exercise in the night. This gentle yoga routine will help you wake up and set a positive tone for the day."
                )
                ReasonCard(
                    title: "Low Impact, High Benefit",
                    description: "Based on your current activity level, this workout provides effective stretching without overexertion."
                )
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
    
    private func iconName(for icon: String?, fallback: String) -> String {
        switch icon?.lowercased() {
        case "dumbbell":
            return "dumbbell.fill"
        case "figure.walk":
            return "figure.walk"
        case "flame":
            return "flame.fill"
        case "bolt":
            return "bolt.fill"
        case "clock":
            return "clock.fill"
        case "fork.knife":
            return "fork.knife"
        case "leaf":
            return "leaf.fill"
        case "apple":
            return "apple.fill"
        case "cup.and.saucer":
            return "cup.and.saucer.fill"
        default:
            return fallback
        }
    }
}

// MARK: - Suggestion Item Row
struct SuggestionItemRow: View {
    let title: String
    let details: String
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                // Regenerate this item (placeholder)
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
            
            Text(title)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
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
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 62/255, green: 129/255, blue: 246/255),
                            Color(red: 135/255, green: 93/255, blue: 245/255)
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


