//
//  DailyTasksApp.swift
//  DailyTasks
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI

@main
struct CloudoApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Lock orientation to portrait at app launch
        OrientationLock.lock(to: .portrait)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .modifier(OrientationLockModifier())
        }
    }
}
