import Foundation
import UserNotifications
import WidgetKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permissions
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Schedule a notification for a task
    func scheduleNotification(for task: Task) {
        guard let taskId = task.id?.uuidString,
              let reminderDate = task.reminderDate,
              !task.completed else {
            return
        }
        
        // Cancel any existing notifications for this task
        cancelNotification(for: task)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Task reminder"
        content.sound = .default
        
        // Add recurrence info to subtitle if task is recurring
        if task.isRecurring {
            if let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)) {
                content.subtitle = recurrenceType.description(for: reminderDate)
            }
        }
        
        // Create trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Cancel notification for a task
    func cancelNotification(for task: Task) {
        guard let taskId = task.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
    }
    
    // Handle task completion and reschedule if recurring
    func handleTaskCompletion(task: Task) {
        // Cancel the current notification
        cancelNotification(for: task)
        
        // If task is recurring, schedule the next occurrence
        if task.isRecurring, let reminderDate = task.reminderDate {
            // Get the recurrence type
            guard let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)),
                  recurrenceType != .none else {
                return
            }
            
            // Calculate the next occurrence date
            if let nextDate = recurrenceType.nextDate(from: reminderDate) {
                // Update the task with the new reminder date
                task.reminderDate = nextDate
                task.lastCompletedDate = Date()
                task.completed = false
                
                // Schedule notification for the next occurrence
                scheduleNotification(for: task)
            }
        }
    }
    
    // Handle task completion by taskId (for widget interactions)
    func handleTaskCompletion(taskId: UUID) {
        // Cancel the current notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId.uuidString])
        
        // Note: For widget interactions, we can't reschedule recurring tasks here
        // This will be handled when the app syncs with Core Data
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // Get all pending notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
} 