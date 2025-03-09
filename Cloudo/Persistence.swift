import CoreData
import WidgetKit
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    static let appGroupIdentifier = "group.com.rushi.Cloudo"

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cloudo")
        
        // Set up shared container for App Group to enable widget access
        if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PersistenceController.appGroupIdentifier) {
            let storeDescription = NSPersistentStoreDescription(url: storeURL.appendingPathComponent("Cloudo.sqlite"))
            
            // Enable history tracking for widgets
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // In a production app, you might want to handle this more gracefully
                print("Persistent store loading error: \(error), \(error.userInfo)")
            }
        })
        
        // Configure the view context for better performance and automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Set up to refresh widgets when data changes
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: .main) { _ in
            // Refresh widgets when Core Data changes
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample categories
        let sampleCategories = [
            ("Work", "#FF9AA2"),      // Enhanced Pastel Pink
            ("Personal", "#74C0E0"),  // Enhanced Light Blue
            ("Shopping", "#7AE582"),  // Enhanced Pale Green
            ("Health", "#FFC17A")     // Enhanced Peach
        ]
        
        var categories: [Category] = []
        
        for (name, color) in sampleCategories {
            let newCategory = Category(context: viewContext)
            newCategory.id = UUID()
            newCategory.name = name
            newCategory.color = color
            categories.append(newCategory)
        }
        
        // Create sample tasks
        let sampleTasks = [
            ("Complete project", "Finish the presentation", true, 0),
            ("Buy groceries", "Milk, eggs, bread", false, 2),
            ("Call doctor", "", true, 3),
            ("Read book", "", false, 1)
        ]
        
        for (title, description, hasDescription, categoryIndex) in sampleTasks {
            let newTask = Task(context: viewContext)
            newTask.id = UUID()
            newTask.title = title
            newTask.taskDescription = hasDescription ? description : nil
            newTask.completed = false
            newTask.createdAt = Date()
            newTask.category = categories[categoryIndex]
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // Save tasks to UserDefaults for widget access
    func saveTasksForWidget() {
        let context = container.viewContext
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
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            // Convert tasks to TaskViewModel
            let taskViewModels = tasks.map { task -> [String: Any] in
                return [
                    "id": task.id?.uuidString ?? UUID().uuidString,
                    "title": task.title ?? "Untitled Task",
                    "priority": task.priority,
                    "completed": task.completed,
                    "category": task.category?.name ?? "",
                    "reminderDate": task.reminderDate as Any
                ]
            }
            
            // Save to UserDefaults
            if let sharedDefaults = UserDefaults(suiteName: PersistenceController.appGroupIdentifier) {
                sharedDefaults.set(taskViewModels, forKey: "widgetTasks")
                sharedDefaults.synchronize()
            }
            
            // Refresh widgets
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error saving tasks for widget: \(error)")
        }
    }

    // Save tasks to UserDefaults for widget access
    func saveTasksForWidget() {
        let context = container.viewContext
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
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            // Convert tasks to TaskViewModel objects
            let taskViewModels = tasks.map { task -> TaskViewModel in
                return TaskViewModel(
                    id: task.id ?? UUID(),
                    title: task.title ?? "Untitled Task",
                    priority: Int(task.priority),
                    completed: task.completed,
                    category: task.category?.name ?? "",
                    reminderDate: task.reminderDate
                )
            }
            
            // Encode to JSON data
            if let encodedData = try? JSONEncoder().encode(taskViewModels) {
                // Save to UserDefaults
                if let sharedDefaults = UserDefaults(suiteName: PersistenceController.appGroupIdentifier) {
                    sharedDefaults.set(encodedData, forKey: "widgetTasks")
                    sharedDefaults.synchronize()
                    print("Saved \(taskViewModels.count) tasks to UserDefaults for widget")
                } else {
                    print("Failed to access shared UserDefaults")
                }
            } else {
                print("Failed to encode tasks for widget")
            }
            
            // Refresh widgets
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error saving tasks for widget: \(error)")
        }
    }
} 
