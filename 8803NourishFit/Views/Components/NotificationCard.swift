import SwiftUI

// MARK: - Notification Card Component
struct NotificationCard: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon based on notification type
                iconView
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text(formatTimestamp(notification.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Icon View
    private var iconView: some View {
        Circle()
            .fill(iconBackgroundColor)
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title3)
            )
    }
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        switch notification.type {
        case .workout:
            return Color.blue.opacity(0.05)
        case .reminder:
            return Color.orange.opacity(0.05)
        case .achievement:
            return Color.green.opacity(0.05)
        case .system:
            return Color.gray.opacity(0.05)
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type {
        case .workout:
            return Color.blue.opacity(0.15)
        case .reminder:
            return Color.orange.opacity(0.15)
        case .achievement:
            return Color.green.opacity(0.15)
        case .system:
            return Color.gray.opacity(0.15)
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .workout:
            return Color.blue
        case .reminder:
            return Color.orange
        case .achievement:
            return Color.green
        case .system:
            return Color.gray
        }
    }
    
    private var iconName: String {
        switch notification.type {
        case .workout:
            return "figure.run"
        case .reminder:
            return "bell.fill"
        case .achievement:
            return "trophy.fill"
        case .system:
            return "info.circle.fill"
        }
    }
    
    // MARK: - Helper Functions
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        NotificationCard(
            notification: AppNotification(
                title: "Workout Reminder",
                message: "Time for your afternoon workout! Let's get moving!",
                timestamp: Date(),
                isRead: false,
                type: .workout
            ),
            onTap: {}
        )
        
        NotificationCard(
            notification: AppNotification(
                title: "Achievement Unlocked",
                message: "You've completed 5 workouts this week!",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true,
                type: .achievement
            ),
            onTap: {}
        )
        
        NotificationCard(
            notification: AppNotification(
                title: "Daily Reminder",
                message: "Don't forget to log your meals today",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                type: .reminder
            ),
            onTap: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}





