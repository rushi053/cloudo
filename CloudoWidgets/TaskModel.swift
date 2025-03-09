import Foundation
import CoreData

// This file contains model definitions for the widget to use
// These match the Core Data model but are defined here to avoid compilation issues

// Task model for the widget
@objc(WidgetTask)
public class WidgetTask: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var completed: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var category: WidgetCategory?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var recurrenceType: Int16
    @NSManaged public var lastCompletedDate: Date?
}

extension WidgetTask {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WidgetTask> {
        return NSFetchRequest<WidgetTask>(entityName: "Task")
    }
}

// Category model for the widget
@objc(WidgetCategory)
public class WidgetCategory: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var tasks: NSSet?
}

extension WidgetCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WidgetCategory> {
        return NSFetchRequest<WidgetCategory>(entityName: "Category")
    }
} 