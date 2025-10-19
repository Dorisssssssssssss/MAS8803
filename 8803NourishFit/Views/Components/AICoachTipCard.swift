import SwiftUI

// MARK: - AI Coach Tip Card Component
struct AICoachTipCard: View {
    let aiCoachTip: AICoachTip
    let onActionTap: (TipAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                Text("AI Coach Tip")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See another option") {
                    // Handle see another option
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // Tip Message
            Text(aiCoachTip.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // Action Buttons
            HStack(spacing: 12) {
                ForEach(aiCoachTip.actions) { action in
                    Button(action: {
                        onActionTap(action)
                    }) {
                        Text(action.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    AICoachTipCard(
        aiCoachTip: AICoachTip(
            message: "You went over your target by 500 kcal last night. Recommendation: Add 20 min HIIT or 2,000 extra steps today.",
            timestamp: Date(),
            actions: [
                TipAction(title: "Do HIIT", type: .hiit),
                TipAction(title: "Take a Walk", type: .walk)
            ]
        ),
        onActionTap: { _ in }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}



