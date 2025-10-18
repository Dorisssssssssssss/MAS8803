import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeaderView
                    
                    // Personal Information and Objectives Section
                    personalInformationSection
                    
                    // Preferences Section
                    preferencesSection
                    
                    // Data Integration Section
                    dataIntegrationSection
                    
                    // Notification Settings Section
                    notificationSettingsSection
                    
                    // Accessibility Section
                    accessibilitySection
                    
                    // Privacy and Data Section
                    privacySection
                }
                .padding(.top, 20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditProfile) {
            // Edit profile functionality
            Text("Edit Profile")
        }
    }
    
    // MARK: - Profile Header View
    private var profileHeaderView: some View {
        HStack(spacing: 16) {
            // Profile Image
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.userProfile.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Fitness Beginner · Fat Loss Goal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Edit Profile") {
                    showingEditProfile = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
    }
    
    // MARK: - Personal Information and Objectives Section
    private var personalInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information and Objectives")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "target",
                    iconColor: .blue,
                    title: "Fitness Goals",
                    subtitle: "Fat Reduction and Body Sculpting",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "ruler",
                    iconColor: .green,
                    title: "Fitness Goals",
                    subtitle: "Fat Reduction and Body Sculpting",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "fork.knife",
                    iconColor: .orange,
                    title: "Dietary preferences",
                    subtitle: "Vegetarianism · Seafood Allergy",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "minus.circle.fill",
                    iconColor: .red,
                    title: "Training Blacklist",
                    subtitle: "Squat · Deadlift",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Data Integration Section
    private var dataIntegrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Integration")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "applelogo",
                    iconColor: .black,
                    title: "Apple Health",
                    subtitle: "Connected",
                    subtitleColor: .green,
                    showToggle: true,
                    toggleOn: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "g.circle.fill",
                    iconColor: .blue,
                    title: "Google Fit",
                    subtitle: "Not connected",
                    showToggle: true,
                    toggleOn: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Notification Settings Section
    private var notificationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notification Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "bell.fill",
                    iconColor: .purple,
                    title: "Frequency",
                    subtitle: "Daily",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "bubble.left.and.bubble.right.fill",
                    iconColor: .brown,
                    title: "Tone and Style",
                    subtitle: "Encouraging",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Accessibility Section
    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accessibility")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "textformat.size",
                    iconColor: .blue,
                    title: "Font Size",
                    subtitle: "Standard",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "paintpalette.fill",
                    iconColor: .pink,
                    title: "Contrast",
                    subtitle: "High contrast",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Privacy and Data Section
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy and Data")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "shield.fill",
                    iconColor: .green,
                    title: "Privacy Setting",
                    subtitle: "Manage Data Permissions",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "arrow.down.circle.fill",
                    iconColor: .blue,
                    title: "Data Export",
                    subtitle: "Download My Data",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 60)
                
                ProfileRow(
                    icon: "trash.fill",
                    iconColor: .red,
                    title: "Delete Account",
                    subtitle: "Permanently delete all data",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var subtitleColor: Color = .secondary
    var showChevron: Bool = false
    var showToggle: Bool = false
    var toggleOn: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(subtitleColor)
            }
            
            Spacer()
            
            if showToggle {
                Toggle("", isOn: .constant(toggleOn))
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
#Preview {
    ProfileView(viewModel: AppViewModel())
}
