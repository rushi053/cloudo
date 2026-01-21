//
//  Task+Extensions.swift
//  Cloudo
//
//  Extensions for the Task Core Data entity
//

import Foundation
import CoreData

extension Task {
    
    // MARK: - Computed Properties
    
    /// Priority enum value
    var priorityValue: Priority {
        guard let priorityString = priority else { return .medium }
        return Priority(rawValue: priorityString) ?? .medium
    }
    
    /// Recurrence enum value
    var recurrenceValue: Recurrence {
        guard let recurrenceString = recurrence else { return .none }
        return Recurrence(rawValue: recurrenceString) ?? .none
    }
    
    /// Whether the task is overdue
    var isOverdue: Bool {
        guard let reminderDate = reminderDate, !isCompleted else {
            return false
        }
        return reminderDate < Date()
    }
    
    /// Whether the task is due today
    var isDueToday: Bool {
        guard let reminderDate = reminderDate else { return false }
        return Calendar.current.isDateInToday(reminderDate)
    }
    
    /// Whether the task is due this week
    var isDueThisWeek: Bool {
        guard let reminderDate = reminderDate else { return false }
        return Calendar.current.isDate(reminderDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Formatted due date string
    var formattedDueDate: String? {
        guard let reminderDate = reminderDate else { return nil }
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(reminderDate) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInTomorrow(reminderDate) {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        } else if calendar.isDate(reminderDate, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        }
        
        return formatter.string(from: reminderDate)
    }
    
    /// Short formatted due date
    var shortDueDate: String? {
        guard let reminderDate = reminderDate else { return nil }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(reminderDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: reminderDate)
        } else if calendar.isDateInTomorrow(reminderDate) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: reminderDate)
        }
    }
    
    // MARK: - Fetch Requests
    
    /// Fetch request for all incomplete tasks
    static func incompleteTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.reminderDate, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
        ]
        return request
    }
    
    /// Fetch request for completed tasks
    static func completedTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.completedAt, ascending: false)
        ]
        return request
    }
    
    /// Fetch request for tasks due today
    static func tasksDueToday() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(
            format: "reminderDate >= %@ AND reminderDate < %@ AND isCompleted == NO",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.reminderDate, ascending: true)
        ]
        return request
    }
    
    /// Fetch request for overdue tasks
    static func overdueTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(
            format: "reminderDate < %@ AND isCompleted == NO",
            Date() as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.reminderDate, ascending: true)
        ]
        return request
    }
    
    /// Fetch request for tasks in a category
    static func tasks(in category: Category) -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
        ]
        return request
    }
    
    // MARK: - Factory Methods
    
    /// Create a new task with default values
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        notes: String? = nil,
        priority: Priority = .medium,
        category: Category? = nil,
        reminderDate: Date? = nil,
        recurrence: Recurrence = .none
    ) -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        task.notes = notes
        task.priority = priority.rawValue
        task.category = category
        task.reminderDate = reminderDate
        task.recurrence = recurrence.rawValue
        task.isCompleted = false
        task.createdAt = Date()
        return task
    }
    
    // MARK: - Actions
    
    /// Toggle completion status
    func toggleCompletion() {
        isCompleted.toggle()
        
        if isCompleted {
            completedAt = Date()
        } else {
            completedAt = nil
        }
    }
}
