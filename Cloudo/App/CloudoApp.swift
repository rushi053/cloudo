//
//  CloudoApp.swift
//  Cloudo
//
//  A privacy-focused, performant task management app
//  Created by Rushiraj Jadeja
//

import SwiftUI

@main
struct CloudoApp: App {
    // MARK: - Properties
    
    /// Shared persistence controller for Core Data
    let persistenceController = PersistenceController.shared
    
    /// App-wide state manager
    @StateObject private var appState = AppState()
    
    // MARK: - Initialization
    
    init() {
        configureAppearance()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
                .onAppear {
                    // Reschedule all notifications on app launch for reliability
                    NotificationService.shared.rescheduleAllNotifications(
                        context: persistenceController.container.viewContext
                    )
                }
        }
    }
    
    // MARK: - Private Methods
    
    /// Configure global UI appearance
    private func configureAppearance() {
        // Configure navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar
        UITabBar.appearance().isHidden = true
    }
}

// MARK: - App State

/// Central state manager for app-wide settings
final class AppState: ObservableObject {
    // MARK: - Published Properties
    
    /// Current theme mode
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    /// Whether onboarding has been completed
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    /// Whether notifications are enabled
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    
    /// Whether haptics are enabled
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    
    /// Default sort option
    @AppStorage("defaultSortOption") var defaultSortOption: String = SortOption.dateCreated.rawValue
    
    // MARK: - Computed Properties
    
    /// Color scheme based on theme preference
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    // MARK: - Methods
    
    /// Toggle theme with haptic feedback
    func toggleTheme() {
        isDarkMode.toggle()
        if hapticsEnabled {
            HapticService.shared.impact(.light)
        }
    }
}
