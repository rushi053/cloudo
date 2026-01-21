//
//  Category+Extensions.swift
//  Cloudo
//
//  Extensions for the Category Core Data entity
//

import SwiftUI
import CoreData

extension Category {
    
    // MARK: - Computed Properties
    
    /// SwiftUI Color from hex string
    var color: Color {
        guard let hex = colorHex else {
            return CloudoTheme.categoryColors[0]
        }
        return Color(hex: hex)
    }
    
    /// Number of incomplete tasks in this category
    var incompleteTaskCount: Int {
        guard let tasks = tasks as? Set<Task> else { return 0 }
        return tasks.filter { !$0.isCompleted }.count
    }
    
    /// Number of completed tasks in this category
    var completedTaskCount: Int {
        guard let tasks = tasks as? Set<Task> else { return 0 }
        return tasks.filter { $0.isCompleted }.count
    }
    
    /// Total number of tasks in this category
    var totalTaskCount: Int {
        tasks?.count ?? 0
    }
    
    // MARK: - Fetch Requests
    
    /// Fetch request for all categories sorted by name
    static func allCategories() -> NSFetchRequest<Category> {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        return request
    }
    
    /// Fetch request for categories with incomplete tasks
    static func categoriesWithIncompleteTasks() -> NSFetchRequest<Category> {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "ANY tasks.isCompleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        return request
    }
    
    // MARK: - Factory Methods
    
    /// Create a new category
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        colorHex: String
    ) -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.colorHex = colorHex
        category.createdAt = Date()
        return category
    }
    
    /// Create default categories if none exist
    static func createDefaultsIfNeeded(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            guard count == 0 else { return }
            
            let defaults: [(String, String)] = [
                ("Personal", "#80CCE6"),
                ("Work", "#FF9999"),
                ("Shopping", "#99E699"),
                ("Health", "#FFD699"),
                ("Finance", "#B399E6")
            ]
            
            for (name, color) in defaults {
                _ = Category.create(in: context, name: name, colorHex: color)
            }
            
            try context.save()
        } catch {
            print("Error creating default categories: \(error)")
        }
    }
}
