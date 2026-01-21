//
//  RootView.swift
//  Cloudo
//
//  Root view that handles navigation between onboarding and main app
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
