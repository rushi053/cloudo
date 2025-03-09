import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cloudo")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
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
