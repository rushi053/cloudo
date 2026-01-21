//
//  SettingsView.swift
//  Cloudo
//
//  Settings view with colorful card-based design
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var haptics: HapticService
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("defaultReminderTime") private var defaultReminderTime = 9
    
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            CloudoTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                    // Header
                    headerView
                    
                    // Settings sections
                    notificationsSection
                    preferencesSection
                    dataSection
                    aboutSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, Design.Spacing.md)
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your tasks and categories. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            aboutSheet
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Settings")
                .font(Design.Typography.largeTitle)
                .foregroundColor(CloudoTheme.textPrimary)
            
            Text("Customize your experience")
                .font(Design.Typography.body)
                .foregroundColor(CloudoTheme.textSecondary)
        }
        .padding(.horizontal, Design.Spacing.lg)
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            sectionHeader("Notifications", icon: "bell.fill", color: CloudoTheme.salmon)
            
            VStack(spacing: Design.Spacing.sm) {
                // Enable notifications toggle
                settingsToggleCard(
                    title: "Enable Reminders",
                    subtitle: "Get notified about your tasks",
                    isOn: $notificationsEnabled,
                    color: CloudoTheme.salmon.opacity(0.15)
                )
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        NotificationService.shared.requestAuthorization { _ in }
                    }
                }
                
                // Default reminder time
                settingsCard(color: CloudoTheme.salmon.opacity(0.15)) {
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("Default Reminder")
                            .font(Design.Typography.bodyMedium)
                            .foregroundColor(CloudoTheme.textPrimary)
                        
                        Text("Time for new task reminders")
                            .font(Design.Typography.caption)
                            .foregroundColor(CloudoTheme.textSecondary)
                        
                        // Time picker buttons
                        HStack(spacing: Design.Spacing.xs) {
                            ForEach([7, 9, 12, 18], id: \.self) { hour in
                                Button(action: {
                                    defaultReminderTime = hour
                                    haptics.selection()
                                }) {
                                    Text(formatHour(hour))
                                        .font(Design.Typography.caption)
                                        .padding(.horizontal, Design.Spacing.sm)
                                        .padding(.vertical, Design.Spacing.xs)
                                        .background(
                                            Capsule()
                                                .fill(defaultReminderTime == hour ? CloudoTheme.jetBlack : Color.clear)
                                        )
                                        .foregroundColor(defaultReminderTime == hour ? .white : CloudoTheme.textPrimary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            sectionHeader("Preferences", icon: "slider.horizontal.3", color: CloudoTheme.purple)
            
            VStack(spacing: Design.Spacing.sm) {
                settingsToggleCard(
                    title: "Haptic Feedback",
                    subtitle: "Feel subtle vibrations for actions",
                    isOn: $hapticFeedbackEnabled,
                    color: CloudoTheme.purple.opacity(0.15)
                )
                .onChange(of: hapticFeedbackEnabled) { _, newValue in
                    haptics.isEnabled = newValue
                    if newValue {
                        haptics.success()
                    }
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            sectionHeader("Data", icon: "externaldrive.fill", color: CloudoTheme.lime)
            
            VStack(spacing: Design.Spacing.sm) {
                // Data info card
                settingsCard(color: CloudoTheme.lime.opacity(0.2)) {
                    HStack {
                        VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                            Text("Local Storage")
                                .font(Design.Typography.bodyMedium)
                                .foregroundColor(CloudoTheme.textPrimary)
                            
                            Text("All your data stays on your device")
                                .font(Design.Typography.caption)
                                .foregroundColor(CloudoTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 28))
                            .foregroundColor(CloudoTheme.textSecondary)
                    }
                }
                
                // Reset button
                Button(action: {
                    haptics.warning()
                    showingResetAlert = true
                }) {
                    settingsCard(color: CloudoTheme.salmon.opacity(0.2)) {
                        HStack {
                            VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                                Text("Reset All Data")
                                    .font(Design.Typography.bodyMedium)
                                    .foregroundColor(CloudoTheme.salmon)
                                
                                Text("Delete all tasks and categories")
                                    .font(Design.Typography.caption)
                                    .foregroundColor(CloudoTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(CloudoTheme.salmon)
                        }
                    }
                }
                .buttonStyle(CardButtonStyle())
            }
            .padding(.horizontal, Design.Spacing.lg)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            sectionHeader("About", icon: "info.circle.fill", color: CloudoTheme.royalBlue)
            
            Button(action: { showingAbout = true }) {
                settingsCard(color: CloudoTheme.royalBlue.opacity(0.15)) {
                    HStack {
                        VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                            Text("Cloudo")
                                .font(Design.Typography.bodyMedium)
                                .foregroundColor(CloudoTheme.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(Design.Typography.caption)
                                .foregroundColor(CloudoTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CloudoTheme.textSecondary)
                    }
                }
            }
            .buttonStyle(CardButtonStyle())
            .padding(.horizontal, Design.Spacing.lg)
        }
    }
    
    // MARK: - About Sheet
    
    private var aboutSheet: some View {
        ZStack {
            CloudoTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: Design.Spacing.xxl) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { showingAbout = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(CloudoTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(CloudoTheme.secondaryBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Design.Spacing.lg)
                
                Spacer()
                
                // Logo and shapes
                ZStack {
                    Circle()
                        .fill(CloudoTheme.royalBlue)
                        .frame(width: 60, height: 60)
                        .offset(x: -50, y: -30)
                    
                    Triangle()
                        .fill(CloudoTheme.lime)
                        .frame(width: 45, height: 45)
                        .rotationEffect(.degrees(20))
                        .offset(x: 50, y: -20)
                    
                    CloudShape()
                        .fill(CloudoTheme.purple)
                        .frame(width: 40, height: 40)
                        .offset(x: -30, y: 40)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(CloudoTheme.salmon)
                        .frame(width: 35, height: 35)
                        .rotationEffect(.degrees(-10))
                        .offset(x: 40, y: 45)
                }
                .frame(height: 100)
                
                VStack(spacing: Design.Spacing.sm) {
                    Text("Cloudo")
                        .font(Design.Typography.largeTitle)
                        .foregroundColor(CloudoTheme.textPrimary)
                    
                    Text("Version 1.0.0")
                        .font(Design.Typography.body)
                        .foregroundColor(CloudoTheme.textSecondary)
                }
                
                // Features
                VStack(spacing: Design.Spacing.md) {
                    featureRow(icon: "checkmark.circle.fill", text: "Beautiful task management", color: CloudoTheme.purple)
                    featureRow(icon: "bell.fill", text: "Smart notifications", color: CloudoTheme.salmon)
                    featureRow(icon: "lock.shield.fill", text: "100% private & local", color: CloudoTheme.lime)
                    featureRow(icon: "sparkles", text: "Delightful animations", color: CloudoTheme.royalBlue)
                }
                .padding(.horizontal, Design.Spacing.xl)
                
                Spacer()
                
                Text("Made with ♥ for productivity")
                    .font(Design.Typography.caption)
                    .foregroundColor(CloudoTheme.textSecondary)
                    .padding(.bottom, Design.Spacing.xxl)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: Design.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(title)
                .font(Design.Typography.title3)
                .foregroundColor(CloudoTheme.textPrimary)
        }
        .padding(.horizontal, Design.Spacing.lg)
    }
    
    private func settingsCard<Content: View>(color: Color, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Design.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg))
    }
    
    private func settingsToggleCard(title: String, subtitle: String, isOn: Binding<Bool>, color: Color) -> some View {
        settingsCard(color: color) {
            HStack {
                VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                    Text(title)
                        .font(Design.Typography.bodyMedium)
                        .foregroundColor(CloudoTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(Design.Typography.caption)
                        .foregroundColor(CloudoTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(CloudoTheme.jetBlack)
            }
        }
    }
    
    private func featureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Design.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(text)
                .font(Design.Typography.body)
                .foregroundColor(CloudoTheme.textPrimary)
            
            Spacer()
        }
        .padding(Design.Spacing.md)
        .background(CloudoTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
    }
    
    // MARK: - Helpers
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return formatter.string(from: date)
    }
    
    private func resetAllData() {
        // Delete all tasks
        let taskFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let taskDelete = NSBatchDeleteRequest(fetchRequest: taskFetch)
        
        // Delete all categories
        let categoryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let categoryDelete = NSBatchDeleteRequest(fetchRequest: categoryFetch)
        
        do {
            try viewContext.execute(taskDelete)
            try viewContext.execute(categoryDelete)
            try viewContext.save()
            
            // Cancel all notifications
            NotificationService.shared.cancelAllNotifications()
            
            haptics.success()
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HapticService())
}
