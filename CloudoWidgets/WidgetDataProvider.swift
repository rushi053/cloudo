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
        if let sharedDefaults = userDefaults {
            print("Found shared UserDefaults with identifier: \(WidgetDataProvider.appGroupIdentifier)")
            
            if let tasksData = sharedDefaults.data(forKey: "widgetTasks") {
                print("Found tasks data in UserDefaults")
                
                do {
                    let tasks = try JSONDecoder().decode([TaskViewModel].self, from: tasksData)
                    if !tasks.isEmpty {
                        print("Successfully decoded \(tasks.count) tasks from UserDefaults")
                        return tasks
                    } else {
                        print("Decoded tasks array is empty")
                    }
                } catch {
                    print("Error decoding tasks from UserDefaults: \(error)")
                }
            } else {
                print("No tasks data found in UserDefaults with key 'widgetTasks'")
                
                // Debug: print all keys in UserDefaults
                for key in sharedDefaults.dictionaryRepresentation().keys {
                    print("UserDefaults key: \(key)")
                }
            }
        } else {
            print("Failed to access shared UserDefaults with identifier: \(WidgetDataProvider.appGroupIdentifier)")
        }
        
        // If no tasks were found, return sample tasks
        print("Using sample tasks instead")
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