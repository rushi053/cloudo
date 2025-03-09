//
//  CloudoApp.swift
//  Cloudo
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI
import UIKit
import WidgetKit
import CoreData

@main
struct CloudoApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var urlHandler = URLHandler()
    
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
        
        // Save tasks for widget on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PersistenceController.shared.saveTasksForWidget()
            print("Saved tasks for widget on app launch")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .modifier(OrientationLockModifier())
                .environmentObject(urlHandler)
                .onOpenURL { url in
                    urlHandler.handleURL(url, context: persistenceController.container.viewContext)
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                    // Update widget data when Core Data changes
                    PersistenceController.shared.saveTasksForWidget()
                    print("Updated widget data due to Core Data changes")
                }
        }
    }
}

// URL Handler for widget interactions
class URLHandler: ObservableObject {
    @Published var lastCompletedTaskId: UUID?
    
    func handleURL(_ url: URL, context: NSManagedObjectContext) {
        guard url.scheme == "cloudo" else { return }
        
        switch url.host {
        case "complete-task":
            if let taskIdString = url.pathComponents.last, 
               let taskId = UUID(uuidString: taskIdString) {
                completeTask(with: taskId, context: context)
            }
        default:
            break
        }
    }
    
    private func completeTask(with id: UUID, context: NSManagedObjectContext) {
        // Create the fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Execute the fetch request
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let task = results.first {
                // Update the task
                task.setValue(true, forKey: "completed")
                
                // Handle recurring tasks if needed
                if let isRecurring = task.value(forKey: "isRecurring") as? Bool, isRecurring {
                    // Use the NotificationManager without casting to Task
                    if let taskId = task.value(forKey: "id") as? UUID {
                        NotificationManager.shared.handleTaskCompletion(taskId: taskId)
                    }
                }
                
                // Save the context
                try context.save()
                lastCompletedTaskId = id
                
                // Refresh widgets
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Error completing task: \(error)")
        }
    }
}
