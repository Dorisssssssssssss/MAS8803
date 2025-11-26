import SwiftUI

// MARK: - Color Extensions
extension Color {
    // MARK: - Brand Colors
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
    static let primaryGreen = Color(red: 0.09, green: 0.64, blue: 0.29) // #17A34A
    static let primaryOrange = Color(red: 0.98, green: 0.6, blue: 0.29) // #FB993D
    static let primaryPurple = Color(red: 0.59, green: 0.28, blue: 1.0) // #9747FF
    static let primaryRed = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    static let backgroundSecondary = Color.white
    static let backgroundTertiary = Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
    
    // MARK: - Text Colors
    static let textPrimary = Color(red: 0.11, green: 0.11, blue: 0.11) // #1D1D1D
    static let textSecondary = Color(red: 0.5, green: 0.52, blue: 0.56) // #80858F
    static let textTertiary = Color(red: 0.85, green: 0.85, blue: 0.85) // #D9D9D9
    
    // MARK: - Card Colors
    static let cardBackground = Color.white
    static let cardBorder = Color(red: 0.85, green: 0.85, blue: 0.85) // #D9D9D9
    
    // MARK: - Success Colors
    static let successBackground = Color(red: 0.94, green: 0.99, blue: 0.96) // #EFFDF4
    static let successBorder = Color(red: 0.8, green: 0.98, blue: 0.86) // #CDF9DC
    static let successText = Color(red: 0.09, green: 0.64, blue: 0.29) // #17A34A
    
    // MARK: - Warning Colors
    static let warningBackground = Color(red: 1.0, green: 0.99, blue: 0.94) // #FFFBEB
    static let warningBorder = Color(red: 0.99, green: 0.9, blue: 0.54) // #FDE68A
    static let warningText = Color(red: 0.98, green: 0.6, blue: 0.29) // #FB993D
    
    // MARK: - Error Colors
    static let errorBackground = Color(red: 1.0, green: 0.95, blue: 0.95) // #FEF2F2
    static let errorBorder = Color(red: 1.0, green: 0.87, blue: 0.87) // #FEDFDF
    static let errorText = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444
    
    // MARK: - Info Colors
    static let infoBackground = Color(red: 0.94, green: 0.97, blue: 1.0) // #F0F7FF
    static let infoBorder = Color(red: 0.86, green: 0.91, blue: 1.0) // #DBE8FE
    static let infoText = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.primaryBlue, Color.primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color.primaryGreen, Color.successBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [Color.primaryOrange, Color.warningBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let errorGradient = LinearGradient(
        colors: [Color.primaryRed, Color.errorBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadow Extensions
extension View {
    func cardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 2
        )
    }
    
    func buttonShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    func modalShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.15),
            radius: 20,
            x: 0,
            y: 10
        )
    }
}






