import Foundation
import UserNotifications
import CoreData

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
              let reminderDate = task.reminderDate else {
            return
        }
        
        // Cancel any existing notifications for this task
        cancelNotification(for: task)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Task reminder"
        if let soundURL = Bundle.main.url(forResource: "notification_sound", withExtension: "aif") {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundURL.lastPathComponent))
        } else {
            print("Could not find notification sound file")
            content.sound = .default
        }
        
        // Add recurrence info to subtitle if task is recurring
        if task.isRecurring {
            if let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)) {
                content.subtitle = recurrenceType.description(for: reminderDate)
            }
        }

        // Handle one-time notifications
        if !task.isRecurring {
            // For non-recurring tasks, schedule a single notification at the exact date
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
                repeats: false
            )
            
            let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Successfully scheduled notification for task: \(task.title ?? "") at \(reminderDate)")
                }
            }
            return
        }
        
        // Handle recurring notifications - use a direct date trigger for the next occurrence
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling recurring notification: \(error)")
            } else {
                print("Successfully scheduled recurring notification for task: \(task.title ?? "") at \(reminderDate)")
            }
        }
    }
    
    // Cancel notification for a task
    func cancelNotification(for task: Task) {
        guard let taskId = task.id?.uuidString else { return }
        
        // Cancel both the main notification and the initial notification for recurring tasks
        let identifiersToRemove = [taskId, "\(taskId)_initial"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
    
    // Handle task completion and reschedule if recurring
    func handleTaskCompletion(task: Task) {
        // For non-recurring tasks, just cancel the notification
        if !task.isRecurring {
            cancelNotification(for: task)
            return
        }
        
        // For recurring tasks, calculate and set next reminder date
        if let reminderDate = task.reminderDate,
           let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)),
           recurrenceType != .none,
           let nextDate = recurrenceType.nextDate(from: reminderDate) {
            
            // Cancel existing notification
            cancelNotification(for: task)
            
            // Update task with new reminder date
            task.reminderDate = nextDate
            task.lastCompletedDate = Date()
            task.completed = false
            
            // Schedule notification for the next occurrence
            scheduleNotification(for: task)
            
            print("Scheduled next occurrence for recurring task: \(task.title ?? "") at \(nextDate)")
            
            // Save the context to persist the changes
            if let context = task.managedObjectContext {
                do {
                    try context.save()
                } catch {
                    print("Error saving context after updating recurring task: \(error)")
                }
            }
        }
    }
    
    // Handle task completion by taskId
    func handleTaskCompletion(taskId: UUID) {
        // First, let's get the task from Core Data
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            if let task = tasks.first {
                // Now that we have the task, handle it properly
                handleTaskCompletion(task: task)
            } else {
                // If task not found, just cancel notifications for this ID
                let identifiersToRemove = [taskId.uuidString, "\(taskId.uuidString)_initial"]
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                print("Task not found for ID: \(taskId)")
            }
        } catch {
            print("Error fetching task for completion: \(error)")
        }
    }
    
    // Get all pending notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // Check and update missed recurring tasks
    func checkAndUpdateMissedRecurringTasks(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRecurring == YES AND completed == NO")
        
        do {
            let recurringTasks = try context.fetch(fetchRequest)
            let now = Date()
            
            for task in recurringTasks {
                if let reminderDate = task.reminderDate,
                   let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)),
                   recurrenceType != .none {
                    
                    // If the reminder date is in the past
                    if reminderDate < now {
                        var currentDate = reminderDate
                        var nextDate: Date?
                        
                        // Loop through all missed occurrences until we find one in the future
                        while currentDate < now, let calculatedNextDate = recurrenceType.nextDate(from: currentDate) {
                            nextDate = calculatedNextDate
                            currentDate = calculatedNextDate
                        }
                        
                        // If we found a future date, update the task
                        if let validNextDate = nextDate {
                            print("Task '\(task.title ?? "")' missed occurrence(s). Updating from \(reminderDate) to \(validNextDate)")
                            
                            // Update the task with the next occurrence date
                            task.reminderDate = validNextDate
                            
                            // Schedule notification for the next occurrence
                            scheduleNotification(for: task)
                        }
                    }
                }
            }
            
            try context.save()
        } catch {
            print("Error checking missed recurring tasks: \(error)")
        }
    }
} 