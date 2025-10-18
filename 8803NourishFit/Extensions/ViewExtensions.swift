import SwiftUI

// MARK: - View Extensions
extension View {
    // MARK: - Animation Extensions
    func fadeIn(delay: Double = 0) -> some View {
        self.opacity(0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).delay(delay)) {
                    _ = self.opacity(1)
                }
            }
    }
    
    func slideIn(from edge: Edge = .trailing, delay: Double = 0) -> some View {
        let offset = edge == .trailing ? 300.0 : -300.0
        return self.offset(x: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    _ = self.offset(x: 0)
                }
            }
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        self.scaleEffect(0.8)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    _ = self.scaleEffect(1.0)
                }
            }
    }
    
    // MARK: - Layout Extensions
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(20)
            .cardShadow()
    }
    
    func buttonStyle() -> some View {
        self
            .buttonShadow()
    }
    
    func modalStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(20)
            .modalShadow()
    }
    
    // MARK: - Interaction Extensions
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
    
    func successHaptic() -> some View {
        self.onTapGesture {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    func errorHaptic() -> some View {
        self.onTapGesture {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
    
    // MARK: - Accessibility Extensions
    func customAccessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(label)
    }
    
    func customAccessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(hint)
    }
    
    func accessibilityAction(_ name: String, action: @escaping () -> Void) -> some View {
        self.accessibilityAction(named: name, action)
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    let size: ButtonSize
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium:
                return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large:
                return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .caption
            case .medium:
                return .subheadline
            case .large:
                return .headline
            }
        }
    }
    
    init(color: Color = .primaryBlue, size: ButtonSize = .medium) {
        self.color = color
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.semibold))
            .foregroundColor(.white)
            .padding(size.padding)
            .background(color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let color: Color
    let size: PrimaryButtonStyle.ButtonSize
    
    init(color: Color = .primaryBlue, size: PrimaryButtonStyle.ButtonSize = .medium) {
        self.color = color
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.semibold))
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 1)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(40)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
        }
    }
}

// MARK: - Custom Empty State View
struct CustomEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.textSecondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(40)
    }
}

// MARK: - Preview Helpers
extension View {
    func previewWithAllColorSchemes() -> some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            self
                .preferredColorScheme(colorScheme)
                .previewDisplayName("\(colorScheme)")
        }
    }
    
    func previewWithDifferentSizes() -> some View {
        ForEach([DeviceSize.iPhoneSE, DeviceSize.iPhone12, DeviceSize.iPhone12ProMax], id: \.self) { size in
            self
                .previewDevice(size.previewDevice)
                .previewDisplayName(size.displayName)
        }
    }
}

// MARK: - Device Size Helper
enum DeviceSize: String, CaseIterable {
    case iPhoneSE = "iPhone SE"
    case iPhone12 = "iPhone 12"
    case iPhone12ProMax = "iPhone 12 Pro Max"
    
    var previewDevice: PreviewDevice {
        PreviewDevice(rawValue: rawValue)
    }
    
    var displayName: String {
        rawValue
    }
}
