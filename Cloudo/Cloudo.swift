//
//  CloudoApp.swift
//  Cloudo
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI
import UIKit
import CoreData
import BackgroundTasks

@main
struct CloudoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @StateObject var onboardingManager = OnboardingManager.shared
    
    init() {
        // Lock orientation to portrait at app launch
        OrientationLock.lock(to: .portrait)
        
        // We'll request notification permissions when needed instead of at launch
        // This gives the user context for why we need notifications
        
        // Customize back button appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Set the back button color to match our theme
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.primaryPastel)]
        appearance.backButtonAppearance = backButtonAppearance
        
        // Set the back indicator image color
        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.left")?
                .withTintColor(UIColor(Theme.primaryPastel), renderingMode: .alwaysOriginal),
            transitionMaskImage: UIImage(systemName: "chevron.left")?
                .withTintColor(UIColor(Theme.primaryPastel), renderingMode: .alwaysOriginal)
        )
        
        // Apply the appearance settings
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Test App Group access
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PersistenceController.appGroupIdentifier) {
            print("Successfully accessed App Group container at: \(containerURL)")
            
            // Test UserDefaults access
            let sharedDefaults = UserDefaults(suiteName: PersistenceController.appGroupIdentifier)
            sharedDefaults?.set("test_value", forKey: "test_key")
            sharedDefaults?.synchronize()
            
            if let testValue = sharedDefaults?.string(forKey: "test_key"), testValue == "test_value" {
                print("Successfully wrote and read from shared UserDefaults")
            } else {
                print("Failed to write/read from shared UserDefaults")
            }
        } else {
            print("Failed to access App Group container. Check entitlements and provisioning profile.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if onboardingManager.hasCompletedOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .modifier(OrientationLockModifier())
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        // Check for missed recurring tasks when app becomes active
                        NotificationManager.shared.checkAndUpdateMissedRecurringTasks(context: persistenceController.container.viewContext)
                    }
                    .task {
                        // Check for missed recurring tasks on app launch
                        NotificationManager.shared.checkAndUpdateMissedRecurringTasks(context: persistenceController.container.viewContext)
                    }
            } else {
                WelcomeAnimationView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Register background tasks
        registerBackgroundTasks()
        
        // We'll request notification permissions during onboarding instead of at app launch
        // This gives the user context for why we need notifications
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundProcessing()
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.cloudo.refreshTasks", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleBackgroundProcessing() {
        let request = BGAppRefreshTaskRequest(identifier: "com.cloudo.refreshTasks")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled successfully")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Create a task to ensure that the background task gets time to complete
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            let context = PersistenceController.shared.container.viewContext
            NotificationManager.shared.checkAndUpdateMissedRecurringTasks(context: context)
        }
        
        // Set up the completion handler for the task
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            // Schedule the next background refresh
            self.scheduleBackgroundProcessing()
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        queue.addOperation(operation)
    }
}
