//
//  TaskFormView.swift
//  Cloudo
//
//  Beautiful form for creating and editing tasks
//

import SwiftUI

struct TaskFormView: View {
    
    // MARK: - Properties
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    // Form state
    @State private var title: String
    @State private var description: String
    @State private var selectedPriority: Priority
    @State private var selectedCategory: Category?
    @State private var reminderDate: Date?
    @State private var selectedRecurrence: Recurrence
    
    // UI state
    @State private var showDatePicker = false
    @State private var showCategoryPicker = false
    @State private var tempDate = Date()
    @FocusState private var isTitleFocused: Bool
    
    // Mode
    let task: Task?
    let isEditing: Bool
    
    // MARK: - Initialization
    
    init(task: Task? = nil) {
        self.task = task
        self.isEditing = task != nil
        
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.taskDescription ?? "")
        _selectedPriority = State(initialValue: task?.priorityValue ?? .none)
        _selectedCategory = State(initialValue: task?.category)
        _reminderDate = State(initialValue: task?.reminderDate)
        _selectedRecurrence = State(initialValue: task?.recurrenceValue ?? .none)
        
        if let date = task?.reminderDate {
            _tempDate = State(initialValue: date)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                CloudoTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Design.Spacing.xl) {
                        // Title & Description
                        titleSection
                        
                        // Category
                        categorySection
                        
                        // Priority
                        prioritySection
                        
                        // Reminder
                        reminderSection
                        
                        // Recurrence
                        if reminderDate != nil {
                            recurrenceSection
                        }
                    }
                    .padding(Design.Spacing.lg)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveTask()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty 
                                     ? .secondary 
                                     : CloudoTheme.primary)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
            .sheet(isPresented: $showCategoryPicker) {
                categoryPickerSheet
            }
            .onAppear {
                if !isEditing {
                    isTitleFocused = true
                }
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("WHAT'S THE TASK?")
            
            VStack(spacing: 0) {
                TextField("Task name", text: $title)
                    .font(Design.Typography.body)
                    .fontWeight(.medium)
                    .focused($isTitleFocused)
                    .padding(Design.Spacing.lg)
                
                Divider()
                    .padding(.horizontal, Design.Spacing.lg)
                
                TextField("Add notes...", text: $description, axis: .vertical)
                    .font(Design.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2...5)
                    .padding(Design.Spacing.lg)
            }
            .background(CloudoTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("CATEGORY")
            
            Button(action: { showCategoryPicker = true }) {
                HStack {
                    if let category = selectedCategory {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        
                        Text(category.name ?? "")
                            .font(Design.Typography.body)
                            .foregroundStyle(.primary)
                    } else {
                        Image(systemName: "tag")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                        
                        Text("Select category")
                            .font(Design.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedCategory != nil {
                        Button(action: { selectedCategory = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(Design.Spacing.lg)
                .background(CloudoTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("PRIORITY")
            
            HStack(spacing: Design.Spacing.sm) {
                ForEach(Priority.allCases) { priority in
                    priorityButton(priority)
                }
            }
        }
    }
    
    private func priorityButton(_ priority: Priority) -> some View {
        let isSelected = selectedPriority == priority
        let color = priorityColor(for: priority)
        
        return Button(action: {
            withAnimation(Design.Animation.snappy) {
                selectedPriority = priority
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            VStack(spacing: Design.Spacing.xs) {
                Image(systemName: priority.icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(priority.name)
                    .font(Design.Typography.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Design.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                    .fill(isSelected ? color : CloudoTheme.cardBackground)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .none: return .secondary
        case .low: return CloudoTheme.priorityLow
        case .medium: return CloudoTheme.priorityMedium
        case .high: return CloudoTheme.priorityHigh
        }
    }
    
    // MARK: - Reminder Section
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("REMINDER")
            
            Button(action: {
                tempDate = reminderDate ?? Date().addingTimeInterval(3600) // Default to 1 hour from now
                showDatePicker = true
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(reminderDate != nil ? CloudoTheme.primary.opacity(0.15) : Color(.systemGray6))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: reminderDate == nil ? "bell" : "bell.fill")
                            .font(.system(size: 16))
                            .foregroundColor(reminderDate != nil ? CloudoTheme.primary : .secondary)
                    }
                    
                    if let date = reminderDate {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(date, style: .date)
                                .font(Design.Typography.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text(date, style: .time)
                                .font(Design.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Add reminder")
                            .font(Design.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if reminderDate != nil {
                        Button(action: {
                            reminderDate = nil
                            selectedRecurrence = .none
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(Design.Spacing.lg)
                .background(CloudoTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Recurrence Section
    
    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("REPEAT")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.sm) {
                    ForEach(Recurrence.allCases) { recurrence in
                        recurrenceChip(recurrence)
                    }
                }
            }
        }
    }
    
    private func recurrenceChip(_ recurrence: Recurrence) -> some View {
        let isSelected = selectedRecurrence == recurrence
        
        return Button(action: {
            withAnimation(Design.Animation.snappy) {
                selectedRecurrence = recurrence
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            HStack(spacing: Design.Spacing.xs) {
                Image(systemName: recurrence.icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(recurrence.name)
                    .font(Design.Typography.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? CloudoTheme.primary : CloudoTheme.cardBackground)
            )
            .shadow(color: isSelected ? CloudoTheme.primary.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Date Picker Sheet
    
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $tempDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(CloudoTheme.primary)
                .padding()
                
                Spacer()
            }
            .background(CloudoTheme.background)
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDatePicker = false
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        reminderDate = tempDate
                        showDatePicker = false
                    }
                    .fontWeight(.bold)
                    .foregroundColor(CloudoTheme.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Category Picker Sheet
    
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        showCategoryPicker = false
                    }) {
                        HStack(spacing: Design.Spacing.md) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 16, height: 16)
                            
                            Text(category.name ?? "")
                                .font(Design.Typography.body)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(CloudoTheme.primary)
                            }
                        }
                        .padding(.vertical, Design.Spacing.xs)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCategoryPicker = false
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Design.Typography.caption2)
            .foregroundStyle(.secondary)
            .padding(.leading, Design.Spacing.xs)
    }
    
    // MARK: - Save Action
    
    private func saveTask() {
        let taskToSave: Task
        
        if let existingTask = task {
            taskToSave = existingTask
        } else {
            taskToSave = Task(context: viewContext)
            taskToSave.id = UUID()
            taskToSave.createdAt = Date()
        }
        
        taskToSave.title = title.trimmingCharacters(in: .whitespaces)
        taskToSave.taskDescription = description.isEmpty ? nil : description
        taskToSave.priority = selectedPriority.rawValue
        taskToSave.category = selectedCategory
        taskToSave.reminderDate = reminderDate
        taskToSave.recurrenceType = selectedRecurrence.rawValue
        taskToSave.isRecurring = selectedRecurrence != .none
        
        if !isEditing {
            taskToSave.isCompleted = false
        }
        
        do {
            try viewContext.save()
            
            if let _ = reminderDate, !taskToSave.isCompleted {
                NotificationService.shared.requestAuthorization { granted in
                    if granted {
                        NotificationService.shared.scheduleNotification(for: taskToSave)
                    }
                }
            } else {
                NotificationService.shared.cancelNotification(for: taskToSave)
            }
            
            if appState.hapticsEnabled {
                HapticService.shared.success()
            }
            
            dismiss()
        } catch {
            print("Error saving task: \(error)")
            if appState.hapticsEnabled {
                HapticService.shared.error()
            }
        }
    }
}

// MARK: - Preview

#Preview("New Task") {
    TaskFormView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
