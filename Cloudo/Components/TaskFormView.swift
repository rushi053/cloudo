//
//  TaskFormView.swift
//  Cloudo
//
//  Reusable form for creating and editing tasks
//  Used by both AddTaskSheet and EditTaskSheet
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
    
    // Mode
    let task: Task?
    let isEditing: Bool
    
    // MARK: - Initialization
    
    init(task: Task? = nil) {
        self.task = task
        self.isEditing = task != nil
        
        // Initialize state from task or defaults
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
                    
                    // Recurrence (only if reminder is set)
                    if reminderDate != nil {
                        recurrenceSection
                    }
                }
                .padding(Design.Spacing.lg)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
            .sheet(isPresented: $showCategoryPicker) {
                categoryPickerSheet
            }
        }
    }
    
    // MARK: - Sections
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("TASK")
            
            VStack(spacing: 0) {
                TextField("What do you need to do?", text: $title)
                    .font(Design.Typography.body)
                    .padding(Design.Spacing.md)
                
                Divider()
                    .padding(.leading, Design.Spacing.md)
                
                TextField("Notes (optional)", text: $description, axis: .vertical)
                    .font(Design.Typography.body)
                    .lineLimit(3...6)
                    .padding(Design.Spacing.md)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
        }
    }
    
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
                            .foregroundStyle(.primary)
                    } else {
                        Image(systemName: "tag")
                            .foregroundStyle(.secondary)
                        
                        Text("Select category")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedCategory != nil {
                        Button(action: { selectedCategory = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .font(Design.Typography.body)
                .padding(Design.Spacing.md)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
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
        Button(action: {
            withAnimation(Design.Animation.quick) {
                selectedPriority = priority
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            VStack(spacing: Design.Spacing.xs) {
                Image(systemName: priority.icon)
                    .font(.system(size: 18))
                    .foregroundColor(selectedPriority == priority ? .white : priority.fallbackColor)
                
                Text(priority.name)
                    .font(Design.Typography.caption)
                    .foregroundColor(selectedPriority == priority ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Design.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.md)
                    .fill(selectedPriority == priority ? priority.fallbackColor : Color(.systemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            sectionHeader("REMINDER")
            
            Button(action: {
                tempDate = reminderDate ?? Date()
                showDatePicker = true
            }) {
                HStack {
                    Image(systemName: reminderDate == nil ? "bell" : "bell.fill")
                        .foregroundStyle(reminderDate == nil ? .secondary : .blue)
                    
                    if let date = reminderDate {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(date, style: .date)
                                .foregroundStyle(.primary)
                            Text(date, style: .time)
                                .font(Design.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Add reminder")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if reminderDate != nil {
                        Button(action: {
                            reminderDate = nil
                            selectedRecurrence = .none
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .font(Design.Typography.body)
                .padding(Design.Spacing.md)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
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
        Button(action: {
            withAnimation(Design.Animation.quick) {
                selectedRecurrence = recurrence
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            HStack(spacing: Design.Spacing.xs) {
                Image(systemName: recurrence.icon)
                    .font(.system(size: 12))
                
                Text(recurrence.name)
                    .font(Design.Typography.caption)
            }
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.sm)
            .background(
                Capsule()
                    .fill(selectedRecurrence == recurrence ? Color.blue : Color(.systemBackground))
            )
            .foregroundColor(selectedRecurrence == recurrence ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Sheets
    
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: Design.Spacing.lg) {
                DatePicker(
                    "Select date and time",
                    selection: $tempDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        reminderDate = tempDate
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        showCategoryPicker = false
                    }) {
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 12, height: 12)
                            
                            Text(category.name ?? "")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCategoryPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Design.Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.leading, Design.Spacing.xs)
    }
    
    // MARK: - Actions
    
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
            
            // Handle notifications
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

#Preview("Edit Task") {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.title = "Sample Task"
    task.priority = 2
    
    return TaskFormView(task: task)
        .environment(\.managedObjectContext, context)
        .environmentObject(AppState())
}
