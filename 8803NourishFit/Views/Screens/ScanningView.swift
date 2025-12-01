import SwiftUI

// MARK: - Scanning View
struct ScanningView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool // Add binding to control dismissal
    let selectedImage: UIImage
    let mealType: String
    @ObservedObject var viewModel: AppViewModel
    
    @State private var currentStep: ScanningStep = .analyzing
    @State private var progress: Double = 0.0
    @State private var showingResultView = false
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            ScrollView {
                VStack(spacing: 24) {
                    // Image Display with Scanning Effect
                    scanningImageView
                    
                    // Progress Bar
                    progressBarView
                    
                    // Analysis Steps
                    analysisStepsView
                }
                .frame(maxWidth: 359) // Limit content width to 359px
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(maxWidth: .infinity) // Center the content
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingResultView, onDismiss: {
            // If the result view was dismissed and the analysis data is cleared (meaning it was saved),
            // we should also dismiss the scanning view.
            if viewModel.currentFoodAnalysis == nil {
                isPresented = false
            }
        }) {
            FoodAnalysisResultView(isPresented: $isPresented, selectedImage: selectedImage, mealType: mealType, viewModel: viewModel)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Analysis Failed"),
                message: Text(viewModel.errorMessage ?? "Unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
        .onAppear {
            startScanning()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .font(.title3)
            }
            
            Text("Scanning")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Scanning Image View
    private var scanningImageView: some View {
        ZStack {
            // Image
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
                .overlay(
                    // Grid overlay
                    GridOverlay()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    // Corner brackets
                    CornerBrackets()
                        .stroke(Color.blue, lineWidth: 3)
                )
                .overlay(
                    // Bottom gradient glow
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.blue.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Progress Bar View
    private var progressBarView: some View {
        HStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 62/255, green: 129/255, blue: 246/255),  // #3E81F6
                                    Color(red: 135/255, green: 93/255, blue: 245/255)   // #875DF5
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(progress * 100))%")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
    
    // MARK: - Analysis Steps View
    private var analysisStepsView: some View {
        VStack(spacing: 16) {
            // Step 1: Analyzing image
            StepRow(
                icon: "sparkles",
                iconColor: .blue,
                title: "Analyzing image...",
                titleColor: .blue,
                status: currentStep.rawValue >= ScanningStep.analyzing.rawValue ? .completed : .pending
            )
            
            // Step 2: Identifying food items
            StepRow(
                icon: "brain",
                iconColor: Color(red: 135/255, green: 93/255, blue: 245/255),
                title: "Identifying food items...",
                titleColor: Color(red: 135/255, green: 93/255, blue: 245/255),
                status: currentStep == .identifying ? .inProgress : 
                        (currentStep.rawValue > ScanningStep.identifying.rawValue ? .completed : .pending),
                isHighlighted: currentStep == .identifying
            )
            
            // Step 3: Calculating nutrition
            StepRow(
                icon: "checkmark.circle",
                iconColor: currentStep.rawValue >= ScanningStep.calculating.rawValue ? .blue : .gray,
                title: "Calculating nutrition...",
                titleColor: currentStep.rawValue >= ScanningStep.calculating.rawValue ? .blue : .gray,
                status: currentStep == .calculating ? .inProgress :
                        (currentStep.rawValue > ScanningStep.calculating.rawValue ? .completed : .pending)
            )
        }
    }
    
    // MARK: - Start Scanning Animation
    private func startScanning() {
        // Start the API call
        viewModel.recognizeFood(image: selectedImage, mealType: mealType)
        
        // Step 1: Analyzing (0-33%)
        withAnimation(.linear(duration: 1.0)) {
            progress = 0.33
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            currentStep = .identifying
            
            // Step 2: Identifying (33-84%)
            withAnimation(.linear(duration: 1.5)) {
                progress = 0.84
            }
            
            // Wait for API to finish
            waitForAnalysisCompletion()
        }
    }
    
    private func waitForAnalysisCompletion() {
        print("⏳ Waiting for analysis completion...")
        // Check if analysis is done
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !viewModel.isLoading {
                if viewModel.currentFoodAnalysis != nil {
                    print("✅ Analysis completed successfully!")
                    timer.invalidate()
                    finishScanning()
                } else if let error = viewModel.errorMessage {
                    print("❌ Analysis failed with error: \(error)")
                    timer.invalidate()
                    // Show alert instead of dismissing immediately
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func finishScanning() {
        DispatchQueue.main.async {
            currentStep = .calculating
            
            // Step 3: Calculating (84-100%)
            withAnimation(.linear(duration: 0.5)) {
                progress = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Complete - show result view
                showingResultView = true
            }
        }
    }
}

// MARK: - Scanning Step Enum
enum ScanningStep: Int {
    case analyzing = 0
    case identifying = 1
    case calculating = 2
}

// MARK: - Step Status Enum
enum StepStatus {
    case completed
    case inProgress
    case pending
}

// MARK: - Step Row Component
struct StepRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let titleColor: Color
    let status: StepStatus
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 30)
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(titleColor)
            
            Spacer()
            
            // Status Indicator
            statusIndicator
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isHighlighted ? Color.gray.opacity(0.05) : Color.clear)
        .cornerRadius(12)
        .shadow(
            color: isHighlighted ? Color.black.opacity(0.1) : Color.clear,
            radius: isHighlighted ? 8 : 0,
            x: 0,
            y: isHighlighted ? 4 : 0
        )
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
                .font(.title3)
            
        case .inProgress:
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .opacity(0.5)
                        .scaleEffect(1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: status
                        )
                }
            }
            
        case .pending:
            EmptyView()
        }
    }
}

// MARK: - Grid Overlay Shape
struct GridOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gridSize: CGFloat = 20
        
        // Vertical lines
        var x: CGFloat = gridSize
        while x < rect.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            x += gridSize
        }
        
        // Horizontal lines
        var y: CGFloat = gridSize
        while y < rect.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            y += gridSize
        }
        
        return path
    }
}

// MARK: - Corner Brackets Shape
struct CornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bracketLength: CGFloat = 30
        let offset: CGFloat = 10
        
        // Top-left bracket
        path.move(to: CGPoint(x: offset + bracketLength, y: offset))
        path.addLine(to: CGPoint(x: offset, y: offset))
        path.addLine(to: CGPoint(x: offset, y: offset + bracketLength))
        
        // Top-right bracket
        path.move(to: CGPoint(x: rect.width - offset - bracketLength, y: offset))
        path.addLine(to: CGPoint(x: rect.width - offset, y: offset))
        path.addLine(to: CGPoint(x: rect.width - offset, y: offset + bracketLength))
        
        // Bottom-left bracket
        path.move(to: CGPoint(x: offset, y: rect.height - offset - bracketLength))
        path.addLine(to: CGPoint(x: offset, y: rect.height - offset))
        path.addLine(to: CGPoint(x: offset + bracketLength, y: rect.height - offset))
        
        // Bottom-right bracket
        path.move(to: CGPoint(x: rect.width - offset, y: rect.height - offset - bracketLength))
        path.addLine(to: CGPoint(x: rect.width - offset, y: rect.height - offset))
        path.addLine(to: CGPoint(x: rect.width - offset - bracketLength, y: rect.height - offset))
        
        return path
    }
}

// MARK: - Preview
#Preview {
    ScanningView(
        isPresented: .constant(true),
        selectedImage: UIImage(systemName: "photo")!,
        mealType: "Breakfast",
        viewModel: AppViewModel()
    )
}

