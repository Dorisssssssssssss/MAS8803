import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingImagePicker = false
    @State private var showingImagePickerOptions = false
    @State private var showingHeaderImagePickerOptions = false
    @State private var selectedImage: UIImage?
    @State private var selectedMealType = "Breakfast"
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        NavigationView {
            if !viewModel.isAuthenticated {
                authenticationView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Calorie Balance Card
                        CalorieBalanceCard(viewModel: viewModel)
                        
                        // Food Recognition Section
                        foodRecognitionSection
                        
                        // AI Coach Tip Card
                        if let aiCoachTip = viewModel.aiCoachTip {
                            AICoachTipCard(
                                aiCoachTip: aiCoachTip,
                                onActionTap: { action in
                                    // Handle tip action
                                    print("Tapped action: \(action.title)")
                                }
                            )
                        }
                        
                        // Calendar Schedule Card
                        CalendarScheduleCard(
                            scheduleItems: viewModel.scheduleItems,
                            onCustomizeTap: {
                                // Handle customize tap
                                print("Customize tapped")
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(Color.gray.opacity(0.05))
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSourceType)
                .ignoresSafeArea()
        }
        .confirmationDialog("Select Image Source", isPresented: $showingImagePickerOptions) {
            Button("Camera") {
                imageSourceType = .camera
                showingImagePicker = true
            }
            Button("Photo Library") {
                imageSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Select Image Source", isPresented: $showingHeaderImagePickerOptions) {
            Button("Camera") {
                imageSourceType = .camera
                showingImagePicker = true
            }
            Button("Photo Library") {
                imageSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                viewModel.recognizeFood(image: image, mealType: selectedMealType)
                selectedImage = nil
            }
        }
        .onChange(of: showingImagePicker) { isShowing in
            if !isShowing {
                // Reset any UI state when picker is dismissed
                showingImagePickerOptions = false
                showingHeaderImagePickerOptions = false
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
                    showingHeaderImagePickerOptions = true
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
    
    // MARK: - Authentication View
    private var authenticationView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Welcome to NourishFit")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your AI-powered health companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.signInAnonymously()
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Get Started")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Food Recognition Section
    private var foodRecognitionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Food Recognition")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Meal Type Selector
                HStack {
                    Text("Meal Type:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Meal Type", selection: $selectedMealType) {
                        Text("Breakfast").tag("Breakfast")
                        Text("Lunch").tag("Lunch")
                        Text("Dinner").tag("Dinner")
                        Text("Snack").tag("Snack")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Image Selection Button
                Button(action: {
                    showingImagePickerOptions = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select Image")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                
                // Loading State
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Analyzing food...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView(viewModel: AppViewModel())
}
