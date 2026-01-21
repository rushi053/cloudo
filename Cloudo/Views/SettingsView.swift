//
//  SettingsView.swift
//  Cloudo
//
//  Beautiful settings screen
//

import SwiftUI
import CoreData

struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showCategoriesSheet = false
    @State private var showDeleteAllAlert = false
    @State private var showAboutSheet = false
    @State private var notificationStatus: String = "Checking..."
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            CloudoTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Design.Spacing.xl) {
                    // Header
                    headerView
                    
                    // Settings sections
                    VStack(spacing: Design.Spacing.lg) {
                        appearanceSection
                        notificationsSection
                        categoriesSection
                        dataSection
                        aboutSection
                    }
                    .padding(.horizontal, Design.Spacing.lg)
                    
                    // Footer
                    footerView
                        .padding(.top, Design.Spacing.xl)
                }
                .padding(.bottom, 140)
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
        .sheet(isPresented: $showCategoriesSheet) {
            CategoriesSheet()
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutSheet()
        }
        .alert("Delete All Tasks", isPresented: $showDeleteAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllTasks()
            }
        } message: {
            Text("This will permanently delete all tasks. This action cannot be undone.")
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Settings")
                .font(Design.Typography.title)
                .foregroundStyle(.primary)
            
            Text("Customize your experience")
                .font(Design.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, Design.Spacing.lg)
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("APPEARANCE")
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: appState.isDarkMode ? "moon.fill" : "sun.max.fill",
                    iconColor: appState.isDarkMode ? CloudoTheme.lavender : CloudoTheme.sunshine,
                    title: "Dark Mode"
                ) {
                    Toggle("", isOn: $appState.isDarkMode)
                        .tint(CloudoTheme.primary)
                        .labelsHidden()
                }
                
                Divider()
                    .padding(.leading, 52)
                
                settingsRow(
                    icon: "hand.tap.fill",
                    iconColor: CloudoTheme.coral,
                    title: "Haptic Feedback"
                ) {
                    Toggle("", isOn: $appState.hapticsEnabled)
                        .tint(CloudoTheme.primary)
                        .labelsHidden()
                }
            }
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("NOTIFICATIONS")
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    iconColor: CloudoTheme.mint,
                    title: "Notifications"
                ) {
                    Text(notificationStatus)
                        .font(Design.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .padding(.leading, 52)
                
                Button(action: openNotificationSettings) {
                    settingsRow(
                        icon: "gear",
                        iconColor: .secondary,
                        title: "Open System Settings"
                    ) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("CATEGORIES")
            
            Button(action: { showCategoriesSheet = true }) {
                settingsRow(
                    icon: "tag.fill",
                    iconColor: CloudoTheme.primary,
                    title: "Manage Categories"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("DATA & PRIVACY")
            
            VStack(spacing: 0) {
                // Privacy info
                HStack(spacing: Design.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(CloudoTheme.mint.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(CloudoTheme.mint)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your data is private")
                            .font(Design.Typography.callout)
                            .fontWeight(.medium)
                        
                        Text("Everything stays on your device")
                            .font(Design.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(Design.Spacing.lg)
                
                Divider()
                    .padding(.leading, 52)
                
                Button(action: { showDeleteAllAlert = true }) {
                    settingsRow(
                        icon: "trash.fill",
                        iconColor: CloudoTheme.coral,
                        title: "Delete All Tasks"
                    ) {
                        EmptyView()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("ABOUT")
            
            Button(action: { showAboutSheet = true }) {
                HStack(spacing: Design.Spacing.md) {
                    // App icon representation
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(CloudoTheme.primaryGradient)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cloudo")
                            .font(Design.Typography.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Version 1.0")
                            .font(Design.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(Design.Spacing.lg)
            }
            .buttonStyle(PlainButtonStyle())
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: Design.Spacing.sm) {
            Text("Made with ❤️")
                .font(Design.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Design.Typography.caption2)
            .foregroundStyle(.secondary)
            .padding(.leading, Design.Spacing.xs)
    }
    
    private func settingsRow<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(Design.Typography.callout)
                .foregroundStyle(.primary)
            
            Spacer()
            
            trailing()
        }
        .padding(Design.Spacing.lg)
    }
    
    // MARK: - Actions
    
    private func checkNotificationStatus() {
        NotificationService.shared.checkAuthorizationStatus { status in
            switch status {
            case .authorized: notificationStatus = "Enabled"
            case .denied: notificationStatus = "Disabled"
            case .notDetermined: notificationStatus = "Not Set"
            default: notificationStatus = "Unknown"
            }
        }
    }
    
    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func deleteAllTasks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            NotificationService.shared.cancelAllNotifications()
            
            if appState.hapticsEnabled {
                HapticService.shared.success()
            }
        } catch {
            print("Error deleting all tasks: \(error)")
        }
    }
}

// MARK: - Categories Sheet

struct CategoriesSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    @State private var newCategoryName = ""
    @State private var newCategoryColor = CloudoTheme.categoryColorHexes[0]
    
    var body: some View {
        NavigationStack {
            ZStack {
                CloudoTheme.background
                    .ignoresSafeArea()
                
                if categories.isEmpty {
                    emptyState
                } else {
                    categoryList
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        editingCategory = nil
                        newCategoryName = ""
                        newCategoryColor = CloudoTheme.categoryColorHexes.randomElement() ?? CloudoTheme.categoryColorHexes[0]
                        showAddCategory = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(CloudoTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Design.Spacing.lg) {
            Image(systemName: "tag")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text("No categories yet")
                .font(Design.Typography.title3)
            
            Text("Tap + to create your first category")
                .font(Design.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var categoryList: some View {
        ScrollView {
            LazyVStack(spacing: Design.Spacing.sm) {
                ForEach(categories) { category in
                    categoryRow(category)
                }
            }
            .padding(Design.Spacing.lg)
        }
    }
    
    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: Design.Spacing.md) {
            Circle()
                .fill(category.color)
                .frame(width: 16, height: 16)
            
            Text(category.name ?? "")
                .font(Design.Typography.callout)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(category.totalTaskCount)")
                .font(Design.Typography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Design.Spacing.sm)
                .padding(.vertical, Design.Spacing.xs)
                .background(Capsule().fill(Color(.systemGray6)))
            
            Button(action: {
                editingCategory = category
                newCategoryName = category.name ?? ""
                newCategoryColor = category.colorHex ?? CloudoTheme.categoryColorHexes[0]
                showAddCategory = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                deleteCategory(category)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(CloudoTheme.coral)
            }
        }
        .padding(Design.Spacing.lg)
        .background(CloudoTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
    }
    
    private var addCategorySheet: some View {
        NavigationStack {
            ZStack {
                CloudoTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: Design.Spacing.xl) {
                    // Name field
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("NAME")
                            .font(Design.Typography.caption2)
                            .foregroundStyle(.secondary)
                        
                        TextField("Category name", text: $newCategoryName)
                            .font(Design.Typography.body)
                            .padding(Design.Spacing.lg)
                            .background(CloudoTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                    }
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("COLOR")
                            .font(Design.Typography.caption2)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Design.Spacing.md) {
                            ForEach(CloudoTheme.categoryColorHexes, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: hex == newCategoryColor ? 3 : 0)
                                            .padding(2)
                                    )
                                    .shadow(color: hex == newCategoryColor ? Color(hex: hex).opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                                    .onTapGesture {
                                        newCategoryColor = hex
                                        if appState.hapticsEnabled {
                                            HapticService.shared.selection()
                                        }
                                    }
                            }
                        }
                        .padding(Design.Spacing.lg)
                        .background(CloudoTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                        Text("PREVIEW")
                            .font(Design.Typography.caption2)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: Design.Spacing.sm) {
                            Circle()
                                .fill(Color(hex: newCategoryColor))
                                .frame(width: 12, height: 12)
                            
                            Text(newCategoryName.isEmpty ? "Category Name" : newCategoryName)
                                .font(Design.Typography.callout)
                                .fontWeight(.medium)
                        }
                        .padding(Design.Spacing.lg)
                        .background(CloudoTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                    }
                    
                    Spacer()
                }
                .padding(Design.Spacing.lg)
            }
            .navigationTitle(editingCategory == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddCategory = false }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(newCategoryName.isEmpty ? .secondary : CloudoTheme.primary)
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveCategory() {
        let category = editingCategory ?? Category(context: viewContext)
        
        if editingCategory == nil {
            category.id = UUID()
            category.createdAt = Date()
        }
        
        category.name = newCategoryName.trimmingCharacters(in: .whitespaces)
        category.colorHex = newCategoryColor
        
        do {
            try viewContext.save()
            showAddCategory = false
            
            if appState.hapticsEnabled {
                HapticService.shared.success()
            }
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    private func deleteCategory(_ category: Category) {
        viewContext.delete(category)
        
        do {
            try viewContext.save()
            if appState.hapticsEnabled {
                HapticService.shared.success()
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
}

// MARK: - About Sheet

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                CloudoTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Design.Spacing.xxl) {
                        // App header
                        VStack(spacing: Design.Spacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(CloudoTheme.primaryGradient)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: CloudoTheme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: Design.Spacing.xs) {
                                Text("Cloudo")
                                    .font(Design.Typography.title)
                                
                                Text("Version 1.0")
                                    .font(Design.Typography.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, Design.Spacing.xxl)
                        
                        // Features
                        VStack(spacing: Design.Spacing.md) {
                            featureCard(
                                icon: "lock.shield.fill",
                                color: CloudoTheme.mint,
                                title: "Privacy First",
                                description: "All data stays on your device"
                            )
                            
                            featureCard(
                                icon: "bolt.fill",
                                color: CloudoTheme.sunshine,
                                title: "Fast & Light",
                                description: "Built for performance"
                            )
                            
                            featureCard(
                                icon: "bell.fill",
                                color: CloudoTheme.coral,
                                title: "Smart Reminders",
                                description: "Never miss a task"
                            )
                            
                            featureCard(
                                icon: "arrow.triangle.2.circlepath",
                                color: CloudoTheme.primary,
                                title: "Recurring Tasks",
                                description: "Automate your routines"
                            )
                        }
                        .padding(.horizontal, Design.Spacing.lg)
                        
                        // Footer
                        Text("Made with ❤️")
                            .font(Design.Typography.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, Design.Spacing.xl)
                            .padding(.bottom, Design.Spacing.xxl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func featureCard(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Design.Typography.callout)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(Design.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(Design.Spacing.lg)
        .background(CloudoTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
