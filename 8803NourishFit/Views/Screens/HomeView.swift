import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Calorie Balance Card
                    if let calorieBalance = viewModel.calorieBalance {
                        CalorieBalanceCard(calorieBalance: calorieBalance)
                    }
                    
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    HomeView(viewModel: AppViewModel())
}
