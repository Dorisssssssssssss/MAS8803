import SwiftUI

// MARK: - Custom Tab Bar Component
struct CustomTabBar: View {
    @Binding var selectedTab: AppViewModel.TabSelection
    let tabs: [AppViewModel.TabSelection] = AppViewModel.TabSelection.allCases
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: AppViewModel.TabSelection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
    }
    .background(Color.gray.opacity(0.1))
}
