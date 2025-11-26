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
    @State private var showingScanningView = false
    
    var body: some View {
        NavigationView {
            if !viewModel.isAuthenticated {
                authenticationView
            } else {
                ZStack(alignment: .topTrailing) {
                    // Main Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerView
                            
                            // Calorie Balance Card
                            CalorieBalanceCard(viewModel: viewModel)
                            
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
                                                Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                                Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
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
                                    .background(Color(red: 239/255, green: 239/255, blue: 239/255)) // #EFEFEF
                                    .cornerRadius(20)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 245/255, green: 245/255, blue: 245/255)) // Light grey background
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        .frame(width: 200)
                        .offset(x: -20, y: 80) // Position 30px below camera icon
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1000) // Ensure it floats above everything
                    }
                }
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
                // Show scanning view instead of directly calling API
                showingScanningView = true
            }
        }
        .onChange(of: showingImagePicker) { oldValue, newValue in
            if !newValue {
                // Reset any UI state when picker is dismissed
                showingImagePickerOptions = false
                showingHeaderImagePickerOptions = false
            }
        }
        .onChange(of: showingScanningView) { oldValue, newValue in
            if !newValue {
                // Clear selected image after scanning view is dismissed
                selectedImage = nil
            }
        }
        // Tap outside to dismiss menu
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
