import Foundation
import CoreData
import WidgetKit

class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    static let appGroupIdentifier = "group.com.rushi.Cloudo"
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cloudo")
        
        // Use the shared App Group container
        if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WidgetDataProvider.appGroupIdentifier) {
            let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("Cloudo.sqlite"))
            
            // Enable history tracking for better performance
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error loading persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    func fetchTodaysTasks() -> [TaskViewModel] {
        // Try to fetch from UserDefaults first
        if let sharedDefaults = userDefaults,
           let tasksData = sharedDefaults.data(forKey: "widgetTasks"),
           let tasks = try? JSONDecoder().decode([TaskViewModel].self, from: tasksData),
           !tasks.isEmpty {
            return tasks
        }
        
        // If no tasks were found, return sample tasks
        print("No tasks found in UserDefaults, using sample tasks")
        return getSampleTasks()
    }
    
    // Use UserDefaults with App Group to share data between app and widget
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: WidgetDataProvider.appGroupIdentifier)
    }
    
    // Sample tasks for testing
    private func getSampleTasks() -> [TaskViewModel] {
        return [
            TaskViewModel(id: UUID(), title: "Complete project proposal", priority: 3, completed: false, category: "Work", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Buy groceries", priority: 2, completed: false, category: "Personal", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Call mom", priority: 1, completed: true, category: "Personal", reminderDate: Date())
        ]
    }
} 