import Foundation

// Model for task data in the widget
struct TaskViewModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let priority: Int
    let completed: Bool
    let category: String
    let reminderDate: Date?
} 