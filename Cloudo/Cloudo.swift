//
//  CloudoApp.swift
//  Cloudo
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI
import UIKit

@main
struct CloudoApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Lock orientation to portrait at app launch
        OrientationLock.lock(to: .portrait)
        
        // We'll request notification permissions when needed instead of at launch
        // This gives the user context for why we need notifications
        
        // Customize back button appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Set the back button color to match our theme
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.primaryPastel)]
        appearance.backButtonAppearance = backButtonAppearance
        
        // Set the back indicator image color
        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.left")?
                .withTintColor(UIColor(Theme.primaryPastel), renderingMode: .alwaysOriginal),
            transitionMaskImage: UIImage(systemName: "chevron.left")?
                .withTintColor(UIColor(Theme.primaryPastel), renderingMode: .alwaysOriginal)
        )
        
        // Apply the appearance settings
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .modifier(OrientationLockModifier())
        }
    }
}
