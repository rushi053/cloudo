//
//  CloudoApp.swift
//  Cloudo
//
//  Main application entry point
//

import SwiftUI

@main
struct CloudoApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Configure appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(CloudoTheme.background)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(CloudoTheme.textPrimary),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(CloudoTheme.textPrimary),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // Configure sheet presentation
        if #available(iOS 16.0, *) {
            // Sheet detents are configured per-sheet in iOS 16+
        }
    }
}
