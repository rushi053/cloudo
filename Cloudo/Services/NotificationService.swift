//
//  NotificationService.swift
//  Cloudo
//
//  Local notification management - privacy-focused
//

import Foundation
import UserNotifications
import CoreData

/// Singleton service for managing local notifications
final class NotificationService: NSObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationService()
    
    // MARK: - Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        setupNotificationCategories()
    }
    
    // MARK: - Setup
    
    private func setupNotificationCategories() {
        // Define actions for notifications
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 1 Hour",
            options: []
        )
        
        // Create category
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([taskCategory])
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification auth error: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Schedule a notification for a task at a specific date
    func scheduleNotification(for task: Task, at date: Date) {
        guard let taskId = task.id?.uuidString,
              !task.isCompleted else { return }
        
        // Don't schedule in the past
        guard date > Date() else {
            print("Skipping notification for past date")
            return
        }
        
        // Cancel existing first
        cancelNotification(for: task)
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Task Reminder"
        
        if let notes = task.notes, !notes.isEmpty {
            content.body = notes
        } else {
            content.body = "Don't forget to complete this task"
        }
        
        // Add priority emoji
        if let priorityString = task.priority,
           let priority = Priority(rawValue: priorityString) {
            switch priority {
            case .high:
                content.title = "🔴 \(task.title ?? "Task")"
            case .medium:
                content.title = "🟡 \(task.title ?? "Task")"
            case .low:
                content.title = "🟢 \(task.title ?? "Task")"
            }
        }
        
        // Add recurrence info
        if let recurrenceString = task.recurrence,
           let recurrence = Recurrence(rawValue: recurrenceString),
           recurrence != .none {
            content.subtitle = "🔄 \(recurrence.displayName)"
        }
        
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": taskId]
        
        // Create trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: taskId,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Scheduled notification for: \(task.title ?? "Unknown") at \(date)")
            }
        }
    }
    
    /// Schedule notification using task's reminder date
    func scheduleNotification(for task: Task) {
        guard let reminderDate = task.reminderDate else { return }
        scheduleNotification(for: task, at: reminderDate)
    }
    
    // MARK: - Cancellation
    
    /// Cancel notification for a task
    func cancelNotification(for task: Task) {
        guard let taskId = task.id?.uuidString else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [taskId])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [taskId])
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        updateBadgeCount(to: 0)
    }
    
    // MARK: - Badge Management
    
    /// Update app badge count
    func updateBadgeCount(to count: Int) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(count) { error in
                if let error = error {
                    print("Badge error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    /// Reschedule all pending notifications on app launch
    func rescheduleAllNotifications(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "reminderDate != nil AND isCompleted == NO"
        )
        
        do {
            let tasks = try context.fetch(fetchRequest)
            var count = 0
            
            for task in tasks {
                if let date = task.reminderDate, date > Date() {
                    scheduleNotification(for: task, at: date)
                    count += 1
                }
            }
            
            print("Rescheduled \(count) notifications")
        } catch {
            print("Error rescheduling: \(error)")
        }
    }
    
    // MARK: - Debug
    
    /// Get pending notifications for debugging
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let taskId = userInfo["taskId"] as? String {
            // Handle action
            switch response.actionIdentifier {
            case "COMPLETE_ACTION":
                NotificationCenter.default.post(
                    name: .taskNotificationCompleted,
                    object: nil,
                    userInfo: ["taskId": taskId]
                )
            case "SNOOZE_ACTION":
                // Snooze for 1 hour
                let snoozeDate = Date().addingTimeInterval(3600)
                NotificationCenter.default.post(
                    name: .taskNotificationSnoozed,
                    object: nil,
                    userInfo: ["taskId": taskId, "snoozeDate": snoozeDate]
                )
            default:
                NotificationCenter.default.post(
                    name: .taskNotificationTapped,
                    object: nil,
                    userInfo: ["taskId": taskId]
                )
            }
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let taskNotificationTapped = Notification.Name("taskNotificationTapped")
    static let taskNotificationCompleted = Notification.Name("taskNotificationCompleted")
    static let taskNotificationSnoozed = Notification.Name("taskNotificationSnoozed")
}
