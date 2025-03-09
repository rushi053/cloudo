import Foundation
import CoreData
import WidgetKit

// Define a Task class for the widget to use
@objc(Task)
public class Task: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var category: Category?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var recurrenceType: Int16
    @NSManaged public var lastCompletedDate: Date?
}

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
}

@objc(Category)
public class Category: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var tasks: NSSet?
}

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
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
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
                        id: task.id ?? UUID(),
                        title: task.title ?? "Untitled Task",
                        priority: Int(task.priority),
                        completed: task.completed,
                        category: task.category?.name ?? "",
                        reminderDate: task.reminderDate
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