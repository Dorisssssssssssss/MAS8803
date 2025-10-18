import SwiftUI

// MARK: - Suggestions View
struct SuggestionsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingCustomizeSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Today's Suggestion Card
                    todaysSuggestionCard
                    
                    // Offline Plan B Section
                    offlinePlanBSection
                    
                    // Notification Section
                    notificationSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCustomizeSheet) {
            CustomizeSuggestionsView()
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
                    // Camera action
                }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.gray)
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
                .fontWeight(.semibold)
            
            // Introductory Text
            Text("Based on your data analysis, I've customized today's plan for you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Training Adjustment
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Training Adjustment")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Reduce aerobic exercise by 20 minutes and increase strength training.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Dietary Adjustments
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dietary Adjustments")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Increase protein by 15g, reduce carbohydrates by 30g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
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
                            
                            Text("Click to view detailed analysis")
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
            
            // Action Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Accept Button
                    Button(action: {
                        // Accept action
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Accept")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    // Regenerate Button
                    Button(action: {
                        // Regenerate action
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.white)
                            Text("Regenerate")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
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
                                .foregroundColor(.primary)
                            Text("Edit")
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(10)
                    }
                    
                    // Delay Button
                    Button(action: {
                        // Delay action
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.primary)
                            Text("Delay")
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Offline Plan B Section
    private var offlinePlanBSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "circle.dotted")
                    .foregroundColor(.purple)
                    .font(.title3)
                
                Text("Offline Plan B")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                // No equipment substitution
                OfflinePlanCard(
                    icon: "house.fill",
                    iconColor: .purple,
                    title: "No equipment substitution",
                    description: "Push-ups, squats, plank"
                )
                
                // Aerobic Substitution
                OfflinePlanCard(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Aerobic Substitution",
                    description: "Running in place, jumping rope, high knees"
                )
                
                // Stair/Walking Plan
                OfflinePlanCard(
                    icon: "figure.walk",
                    iconColor: .green,
                    title: "Stair/Walking Plan",
                    description: "30 minutes of brisk walking or stair climbing"
                )
            }
        }
    }
    
    // MARK: - Notification Section
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Notification")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("History") {
                    // History action
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                // Notification Item 1
                NotificationItem(
                    color: .orange,
                    title: "Ignored yesterday's suggestion",
                    message: "Increase protein intake - 2 hours ago"
                )
                
                // Notification Item 2
                NotificationItem(
                    color: .blue,
                    title: "Training plan has been updated",
                    message: "Adjusted based on sleep data - 1 day ago"
                )
                
                // Notification Item 3
                NotificationItem(
                    color: .green,
                    title: "Goal Achievement Reminder",
                    message: "This week's training completion rate: 90% - 2 days ago"
                )
            }
            
            Button("View All Notifications") {
                // View all notifications action
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
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

// MARK: - Offline Plan Card
struct OfflinePlanCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
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

// MARK: - Notification Item
struct NotificationItem: View {
    let color: Color
    let title: String
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
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
