//
//  PersistenceController.swift
//  Cloudo
//
//  Core Data persistence controller
//  All data is stored locally - no cloud sync for privacy
//

import CoreData

/// Manages Core Data stack and persistence
struct PersistenceController {
    
    // MARK: - Singleton
    
    static let shared = PersistenceController()
    
    // MARK: - Properties
    
    /// The persistent container
    let container: NSPersistentContainer
    
    // MARK: - Initialization
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cloudo")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Log error but don't crash in production
                print("Core Data error: \(error), \(error.userInfo)")
                
                #if DEBUG
                fatalError("Core Data failed to load: \(error.localizedDescription)")
                #endif
            }
        }
        
        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Performance optimization
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    // MARK: - Preview
    
    /// Preview instance with sample data
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample categories
        let categories = createSampleCategories(in: context)
        
        // Create sample tasks
        createSampleTasks(in: context, categories: categories)
        
        do {
            try context.save()
        } catch {
            print("Preview save error: \(error)")
        }
        
        return controller
    }()
    
    // MARK: - Sample Data
    
    private static func createSampleCategories(in context: NSManagedObjectContext) -> [Category] {
        let categoryData: [(String, String)] = [
            ("Work", "#D9B8F3"),
            ("Personal", "#DFF37D"),
            ("Shopping", "#B8E6D4"),
            ("Health", "#EE5E37"),
            ("Learning", "#4558C8")
        ]
        
        return categoryData.map { name, color in
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.colorHex = color
            category.createdAt = Date()
            return category
        }
    }
    
    private static func createSampleTasks(in context: NSManagedObjectContext, categories: [Category]) {
        let taskData: [(String, String?, Priority, Bool, Int)] = [
            ("Review project proposal", "Check the Q4 budget allocations", .high, false, 0),
            ("Buy groceries", "Milk, eggs, bread, vegetables", .low, false, 2),
            ("Morning workout", "30 min cardio + stretching", .medium, true, 3),
            ("Read SwiftUI book", "Chapter 5: Advanced Animations", .low, false, 4),
            ("Call mom", nil, .medium, false, 1),
        ]
        
        for (index, data) in taskData.enumerated() {
            let task = Task(context: context)
            task.id = UUID()
            task.title = data.0
            task.notes = data.1
            task.priority = data.2.rawValue
            task.isCompleted = false
            task.createdAt = Date().addingTimeInterval(Double(-index * 3600))
            task.category = categories[data.4]
            
            // Add reminder for some tasks
            if data.3 {
                task.reminderDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                task.recurrence = Recurrence.daily.rawValue
            }
        }
    }
    
    // MARK: - Save Context
    
    /// Save the view context if there are changes
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}
