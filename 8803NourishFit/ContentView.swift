//
//  ContentView.swift
//  8803NourishFit
//
//  Created by XIN on 10/14/25.
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            TabView(selection: $viewModel.currentTab) {
                HomeView(viewModel: viewModel)
                    .tag(AppViewModel.TabSelection.home)
                
                SuggestionsView(viewModel: viewModel)
                    .tag(AppViewModel.TabSelection.suggestions)
                
                CalendarView(viewModel: viewModel)
                    .tag(AppViewModel.TabSelection.calendar)
                
                SettingsView(viewModel: viewModel)
                    .tag(AppViewModel.TabSelection.settings)
                
                ProfileView(viewModel: viewModel)
                    .tag(AppViewModel.TabSelection.profile)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $viewModel.currentTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
