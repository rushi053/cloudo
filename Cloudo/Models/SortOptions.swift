import Foundation

enum TaskSortOption: String, CaseIterable, Identifiable {
    case createdNewest = "Newest First"
    case createdOldest = "Oldest First"
    case alphabetical = "A to Z"
    case dueDate = "Due Date"
    case priority = "Priority"
    
    var id: String { self.rawValue }
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .createdNewest:
            return [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        case .createdOldest:
            return [NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)]
        case .alphabetical:
            return [NSSortDescriptor(keyPath: \Task.title, ascending: true)]
        case .dueDate:
            // Sort by reminder date, with tasks without reminders at the end
            return [
                NSSortDescriptor(keyPath: \Task.reminderDate, ascending: true),
                NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
            ]
        case .priority:
            // Sort by priority (high to low), then by creation date (newest first)
            return [
                NSSortDescriptor(keyPath: \Task.priority, ascending: false),
                NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
            ]
        }
    }
    
    var systemImage: String {
        switch self {
        case .createdNewest:
            return "arrow.down.circle"
        case .createdOldest:
            return "arrow.up.circle"
        case .alphabetical:
            return "textformat.abc"
        case .dueDate:
            return "calendar"
        case .priority:
            return "exclamationmark.circle"
        }
    }
} 