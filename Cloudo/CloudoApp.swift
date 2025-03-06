//
//  CloudoApp.swift
//  Cloudo
//
//  Created by Rushiraj Jadeja on 06/03/25.
//

import SwiftUI

@main
struct CloudoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
