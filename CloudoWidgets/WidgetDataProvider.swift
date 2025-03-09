import Foundation
import CoreData
import WidgetKit

class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    static let appGroupIdentifier = "group.com.rushi.Cloudo"
    
    private init() {}
    
    // Use UserDefaults with App Group to share data between app and widget
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: WidgetDataProvider.appGroupIdentifier)
    }
    
    func fetchTodaysTasks() -> [TaskViewModel] {
        // Try to fetch from UserDefaults first
        if let sharedDefaults = userDefaults,
           let tasksData = sharedDefaults.data(forKey: "widgetTasks") {
            do {
                let tasks = try JSONDecoder().decode([TaskViewModel].self, from: tasksData)
                if !tasks.isEmpty {
                    return tasks
                }
            } catch {
                // Silent error handling for better widget performance
            }
        }
        
        // If no tasks were found, return sample tasks
        return getSampleTasks()
    }
    
    // Sample tasks for testing
    private func getSampleTasks() -> [TaskViewModel] {
        return [
            TaskViewModel(id: UUID(), title: "Add tasks in the app", priority: 3, completed: false, category: "Cloudo", reminderDate: nil),
            TaskViewModel(id: UUID(), title: "They will appear here", priority: 2, completed: false, category: "Widget", reminderDate: nil),
            TaskViewModel(id: UUID(), title: "Tap to complete tasks", priority: 1, completed: false, category: "Tips", reminderDate: nil)
        ]
    }
} 