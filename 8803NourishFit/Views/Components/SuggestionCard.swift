import SwiftUI

// MARK: - Suggestion Card Component
struct SuggestionCard: View {
    let suggestion: Suggestion
    let onAccept: () -> Void
    let onRegenerate: () -> Void
    let onEdit: () -> Void
    let onDelay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Suggestion")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Based on your data analysis, I've customized today's plan for you.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Suggestion Content
            VStack(alignment: .leading, spacing: 12) {
                // Main Suggestion
                SuggestionItem(
                    title: suggestion.title,
                    description: suggestion.description,
                    isSelected: true
                )
                
                // Alternative Suggestions
                if suggestion.category == .aerobic {
                    SuggestionItem(
                        title: "No equipment substitution",
                        description: "Push-ups, squats, plank",
                        isSelected: false
                    )
                    
                    SuggestionItem(
                        title: "Stair/Walking Plan",
                        description: "30 minutes of brisk walking or stair climbing",
                        isSelected: false
                    )
                }
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                ActionButton(
                    title: "Accept",
                    icon: "checkmark",
                    style: .primary,
                    action: onAccept
                )
                
                ActionButton(
                    title: "Regenerate",
                    icon: "arrow.clockwise",
                    style: .secondary,
                    action: onRegenerate
                )
                
                ActionButton(
                    title: "Edit",
                    icon: "pencil",
                    style: .tertiary,
                    action: onEdit
                )
                
                ActionButton(
                    title: "Delay",
                    icon: "clock",
                    style: .quaternary,
                    action: onDelay
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Suggestion Item
struct SuggestionItem: View {
    let title: String
    let description: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection Indicator
            Circle()
                .stroke(isSelected ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .fill(isSelected ? Color.purple : Color.clear)
                        .frame(width: 12, height: 12)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, tertiary, quaternary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Color.green.opacity(0.1)
            case .secondary: return Color.blue.opacity(0.1)
            case .tertiary: return Color.yellow.opacity(0.1)
            case .quaternary: return Color.gray.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary: return Color.green
            case .secondary: return Color.blue
            case .tertiary: return Color.yellow
            case .quaternary: return Color.gray
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary: return .primary
            case .secondary: return .primary
            case .tertiary: return .primary
            case .quaternary: return .primary
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(style.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    SuggestionCard(
        suggestion: Suggestion(
            title: "Aerobic Substitution",
            description: "Running in place, jumping rope, high knees",
            category: .aerobic,
            timestamp: Date()
        ),
        onAccept: {},
        onRegenerate: {},
        onEdit: {},
        onDelay: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

