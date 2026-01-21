//
//  NotificationService.swift
//  Cloudo
//
//  Robust notification management with persistence and reliability
//  Privacy-focused: All data stays on device
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
    
    /// Custom notification sound (optional)
    private let notificationSound: UNNotificationSound = {
        // Use custom sound if available, otherwise default
        if Bundle.main.path(forResource: "notification_sound", ofType: "aif") != nil {
            return UNNotificationSound(named: UNNotificationSoundName("notification_sound.aif"))
        }
        return .default
    }()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Authorization
    
    /// Request notification permissions from the user
    /// - Parameter completion: Callback with authorization result
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Check current authorization status
    /// - Parameter completion: Callback with current status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Schedule a notification for a task
    /// - Parameter task: The task to schedule notification for
    func scheduleNotification(for task: Task) {
        guard let taskId = task.id?.uuidString,
              let reminderDate = task.reminderDate,
              !task.isCompleted else {
            return
        }
        
        // Don't schedule notifications in the past
        guard reminderDate > Date() else {
            print("Skipping notification for past date: \(reminderDate)")
            return
        }
        
        // Cancel existing notification first
        cancelNotification(for: taskId)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Task Reminder"
        
        if let description = task.taskDescription, !description.isEmpty {
            content.body = description
        } else {
            content.body = "Time to complete your task"
        }
        
        // Add recurrence info if applicable
        if task.isRecurring, let recurrence = Recurrence(rawValue: task.recurrenceType) {
            content.subtitle = "🔄 \(recurrence.shortName)"
        }
        
        // Add priority indicator
        if let priority = Priority(rawValue: task.priority), priority != .none {
            content.title = "\(priority.name) Priority: \(task.title ?? "Task")"
        }
        
        content.sound = notificationSound
        content.badge = 1
        
        // Add category and task ID for handling
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": taskId]
        
        // Create trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create and add request
        let request = UNNotificationRequest(
            identifier: taskId,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for task: \(task.title ?? "Unknown") at \(reminderDate)")
            }
        }
    }
    
    /// Cancel notification for a specific task
    /// - Parameter taskId: The task's UUID string
    func cancelNotification(for taskId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [taskId])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [taskId])
    }
    
    /// Cancel notification for a task object
    /// - Parameter task: The task to cancel notification for
    func cancelNotification(for task: Task) {
        guard let taskId = task.id?.uuidString else { return }
        cancelNotification(for: taskId)
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        updateBadgeCount(to: 0)
    }
    
    // MARK: - Recurring Tasks
    
    /// Handle task completion for recurring tasks
    /// - Parameters:
    ///   - task: The completed task
    ///   - context: Core Data context for saving
    func handleTaskCompletion(task: Task, context: NSManagedObjectContext) {
        // Cancel current notification
        cancelNotification(for: task)
        
        // If recurring, schedule next occurrence
        guard task.isRecurring,
              let recurrence = Recurrence(rawValue: task.recurrenceType),
              recurrence != .none,
              let currentDate = task.reminderDate,
              let nextDate = recurrence.nextDate(from: currentDate) else {
            return
        }
        
        // Update task with next date
        task.reminderDate = nextDate
        task.isCompleted = false
        task.lastCompletedDate = Date()
        
        // Save and reschedule
        do {
            try context.save()
            scheduleNotification(for: task)
            print("Rescheduled recurring task for: \(nextDate)")
        } catch {
            print("Error saving recurring task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Persistence & Reliability
    
    /// Reschedule all notifications - call on app launch
    /// - Parameter context: Core Data context
    func rescheduleAllNotifications(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "reminderDate != nil AND isCompleted == NO"
        )
        
        do {
            let tasks = try context.fetch(fetchRequest)
            var upcomingCount = 0
            
            for task in tasks {
                if let reminderDate = task.reminderDate, reminderDate > Date() {
                    scheduleNotification(for: task)
                    upcomingCount += 1
                }
            }
            
            print("Rescheduled \(upcomingCount) notifications")
        } catch {
            print("Error fetching tasks for rescheduling: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Badge Management
    
    /// Update the app badge count
    /// - Parameter count: The badge number to display
    func updateBadgeCount(to count: Int) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(count) { error in
                if let error = error {
                    print("Error setting badge count: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Calculate and update badge based on overdue tasks
    /// - Parameter context: Core Data context
    func updateBadgeForOverdueTasks(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "reminderDate < %@ AND isCompleted == NO",
            Date() as NSDate
        )
        
        do {
            let count = try context.count(for: fetchRequest)
            updateBadgeCount(to: count)
        } catch {
            print("Error counting overdue tasks: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utility
    
    /// Get all pending notifications (for debugging)
    /// - Parameter completion: Callback with pending requests
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
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let taskId = userInfo["taskId"] as? String {
            // Post notification for the app to handle navigation
            NotificationCenter.default.post(
                name: .taskNotificationTapped,
                object: nil,
                userInfo: ["taskId": taskId]
            )
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let taskNotificationTapped = Notification.Name("taskNotificationTapped")
}
