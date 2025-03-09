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
        // Try to fetch from Core Data first
        do {
            let context = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
            
            // Get today's date range
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Fetch tasks that are due today or have no due date and are not completed
            let predicate = NSPredicate(format: "(reminderDate >= %@ AND reminderDate < %@) OR (reminderDate == nil AND completed == NO)", today as NSDate, tomorrow as NSDate)
            fetchRequest.predicate = predicate
            
            // Sort by priority (high to low) and then by title
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "priority", ascending: false),
                NSSortDescriptor(key: "title", ascending: true)
            ]
            
            let tasks = try context.fetch(fetchRequest)
            
            // If we successfully fetched tasks, return them
            if !tasks.isEmpty {
                return tasks.map { task in
                    TaskViewModel(
                        id: task.value(forKey: "id") as? UUID ?? UUID(),
                        title: task.value(forKey: "title") as? String ?? "Untitled Task",
                        priority: Int(task.value(forKey: "priority") as? Int16 ?? 0),
                        completed: task.value(forKey: "completed") as? Bool ?? false,
                        category: (task.value(forKey: "category") as? NSManagedObject)?.value(forKey: "name") as? String ?? "",
                        reminderDate: task.value(forKey: "reminderDate") as? Date
                    )
                }
            } else {
                // If no tasks were found, return sample tasks
                print("No tasks found in Core Data, using sample tasks")
                return getSampleTasks()
            }
        } catch {
            // If there was an error, log it and return sample tasks
            print("Error fetching tasks from Core Data: \(error)")
            return getSampleTasks()
        }
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