import CoreData
import WidgetKit

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
} 
