//
//  SettingsView.swift
//  Cloudo
//
//  App settings and preferences
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
        NavigationStack {
            List {
                // Appearance Section
                appearanceSection
                
                // Notifications Section
                notificationsSection
                
                // Categories Section
                categoriesSection
                
                // Data Section
                dataSection
                
                // About Section
                aboutSection
            }
            .navigationTitle("Settings")
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
    }
    
    // MARK: - Sections
    
    private var appearanceSection: some View {
        Section {
            Toggle(isOn: $appState.isDarkMode) {
                Label("Dark Mode", systemImage: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            .tint(.blue)
            
            Toggle(isOn: $appState.hapticsEnabled) {
                Label("Haptic Feedback", systemImage: "hand.tap.fill")
            }
            .tint(.blue)
        } header: {
            Text("Appearance")
        } footer: {
            Text("Customize how the app looks and feels.")
        }
    }
    
    private var notificationsSection: some View {
        Section {
            HStack {
                Label("Notifications", systemImage: "bell.fill")
                
                Spacer()
                
                Text(notificationStatus)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: openNotificationSettings) {
                Label("Open Settings", systemImage: "gear")
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Manage notification permissions in System Settings.")
        }
    }
    
    private var categoriesSection: some View {
        Section {
            Button(action: { showCategoriesSheet = true }) {
                HStack {
                    Label("Manage Categories", systemImage: "tag.fill")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("Categories")
        }
    }
    
    private var dataSection: some View {
        Section {
            Button(role: .destructive, action: { showDeleteAllAlert = true }) {
                Label("Delete All Tasks", systemImage: "trash.fill")
            }
        } header: {
            Text("Data")
        } footer: {
            Text("All your data is stored locally on your device. Nothing is sent to any server.")
        }
    }
    
    private var aboutSection: some View {
        Section {
            Button(action: { showAboutSheet = true }) {
                HStack {
                    Label("About Cloudo", systemImage: "info.circle.fill")
                    
                    Spacer()
                    
                    Text("v1.0")
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("About")
        }
    }
    
    // MARK: - Actions
    
    private func checkNotificationStatus() {
        NotificationService.shared.checkAuthorizationStatus { status in
            switch status {
            case .authorized:
                notificationStatus = "Enabled"
            case .denied:
                notificationStatus = "Disabled"
            case .notDetermined:
                notificationStatus = "Not Set"
            case .provisional:
                notificationStatus = "Provisional"
            case .ephemeral:
                notificationStatus = "Ephemeral"
            @unknown default:
                notificationStatus = "Unknown"
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
            List {
                ForEach(categories) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        
                        Text(category.name ?? "")
                        
                        Spacer()
                        
                        Text("\(category.totalTaskCount) tasks")
                            .foregroundStyle(.secondary)
                            .font(Design.Typography.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCategory = category
                        newCategoryName = category.name ?? ""
                        newCategoryColor = category.colorHex ?? CloudoTheme.categoryColorHexes[0]
                        showAddCategory = true
                    }
                }
                .onDelete(perform: deleteCategories)
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
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
        }
    }
    
    private var addCategorySheet: some View {
        NavigationStack {
            Form {
                TextField("Category Name", text: $newCategoryName)
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(CloudoTheme.categoryColorHexes, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: hex == newCategoryColor ? 3 : 0)
                                )
                                .onTapGesture {
                                    newCategoryColor = hex
                                }
                        }
                    }
                    .padding(.vertical, Design.Spacing.sm)
                }
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
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(categories[index])
        }
        
        do {
            try viewContext.save()
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
            ScrollView {
                VStack(spacing: Design.Spacing.xxl) {
                    // App Icon & Name
                    VStack(spacing: Design.Spacing.md) {
                        Image(systemName: "checklist")
                            .font(.system(size: 64))
                            .foregroundColor(Color.blue)
                        
                        Text("Cloudo")
                            .font(Design.Typography.largeTitle)
                        
                        Text("Version 1.0")
                            .font(Design.Typography.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, Design.Spacing.xxl)
                    
                    // Features
                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                        featureRow(icon: "lock.shield.fill", title: "Privacy First", description: "All data stays on your device")
                        featureRow(icon: "bolt.fill", title: "Fast & Light", description: "Built for performance")
                        featureRow(icon: "bell.fill", title: "Smart Reminders", description: "Never miss a task")
                        featureRow(icon: "arrow.triangle.2.circlepath", title: "Recurring Tasks", description: "Automate your routines")
                    }
                    .padding(.horizontal, Design.Spacing.lg)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: Design.Spacing.sm) {
                        Text("Made with ❤️")
                            .font(Design.Typography.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, Design.Spacing.xxl)
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
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Design.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Design.Typography.headline)
                
                Text(description)
                    .font(Design.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(Design.Spacing.md)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
