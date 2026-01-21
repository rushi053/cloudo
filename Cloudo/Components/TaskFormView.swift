//
//  TaskFormView.swift
//  Cloudo
//
//  Beautiful task form with colorful inputs
//

import SwiftUI
import CoreData

enum TaskFormMode {
    case add
    case edit(Task)
}

struct TaskFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let mode: TaskFormMode
    
    // Form state
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: Priority = .medium
    @State private var selectedCategory: Category?
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var recurrence: Recurrence = .none
    @State private var selectedColorIndex = 0
    
    // Animation state
    @State private var showContent = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    private var task: Task? {
        if case .edit(let task) = mode { return task }
        return nil
    }
    
    private var formTitle: String {
        isEditing ? "Edit Task" : "New Task"
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                CloudoTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Design.Spacing.lg) {
                        // Color preview card
                        colorPreviewCard
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Title input
                        titleInput
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Notes input
                        notesInput
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Priority selector
                        prioritySelector
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Color selector
                        colorSelector
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Reminder section
                        reminderSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Recurrence (if reminder is set)
                        if hasReminder {
                            recurrenceSelector
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                        
                        // Delete button for edit mode
                        if isEditing {
                            deleteButton
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(Design.Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(CloudoTheme.textSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(formTitle)
                        .font(Design.Typography.headline)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveTask) {
                        Text("Save")
                            .font(Design.Typography.headline)
                            .foregroundColor(canSave ? CloudoTheme.royalBlue : CloudoTheme.textSecondary)
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                loadExistingData()
                withAnimation(Design.Animation.smooth.delay(0.1)) {
                    showContent = true
                }
            }
        }
    }
    
    // MARK: - Color Preview Card
    
    private var colorPreviewCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            Text(title.isEmpty ? "Task Title" : title)
                .font(Design.Typography.title2)
                .foregroundColor(selectedColor.isLight ? CloudoTheme.textOnColor : .white)
                .lineLimit(2)
            
            if !notes.isEmpty {
                Text(notes)
                    .font(Design.Typography.subheadline)
                    .foregroundColor(selectedColor.isLight ? CloudoTheme.textSecondary : .white.opacity(0.7))
                    .lineLimit(2)
            }
            
            HStack {
                // Priority pill
                HStack(spacing: Design.Spacing.xxs) {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    Text(priority.displayName)
                        .font(Design.Typography.caption)
                }
                .padding(.horizontal, Design.Spacing.sm)
                .padding(.vertical, Design.Spacing.xxs)
                .background(
                    Capsule()
                        .stroke((selectedColor.isLight ? CloudoTheme.textOnColor : Color.white).opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(selectedColor.isLight ? CloudoTheme.textOnColor : .white)
                
                Spacer()
                
                // Arrow button
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(selectedColor)
                    .frame(width: 36, height: 36)
                    .background(selectedColor.isLight ? CloudoTheme.jetBlack : .white)
                    .clipShape(Circle())
            }
        }
        .padding(Design.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 140)
        .background(selectedColor)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.xl))
        .animation(Design.Animation.smooth, value: selectedColorIndex)
        .animation(Design.Animation.smooth, value: priority)
    }
    
    private var selectedColor: Color {
        CloudoTheme.cardColors[selectedColorIndex % CloudoTheme.cardColors.count]
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low: return CloudoTheme.lime
        case .medium: return CloudoTheme.peach
        case .high: return CloudoTheme.salmon
        }
    }
    
    // MARK: - Title Input
    
    private var titleInput: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Title")
                .font(Design.Typography.caption)
                .foregroundColor(CloudoTheme.textSecondary)
            
            TextField("What do you need to do?", text: $title)
                .font(Design.Typography.body)
                .padding(Design.Spacing.md)
                .background(CloudoTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
        }
    }
    
    // MARK: - Notes Input
    
    private var notesInput: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Notes")
                .font(Design.Typography.caption)
                .foregroundColor(CloudoTheme.textSecondary)
            
            TextField("Add more details...", text: $notes, axis: .vertical)
                .font(Design.Typography.body)
                .lineLimit(3...6)
                .padding(Design.Spacing.md)
                .background(CloudoTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
        }
    }
    
    // MARK: - Priority Selector
    
    private var prioritySelector: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Priority")
                .font(Design.Typography.caption)
                .foregroundColor(CloudoTheme.textSecondary)
            
            HStack(spacing: Design.Spacing.sm) {
                ForEach(Priority.allCases, id: \.self) { p in
                    Button(action: { 
                        withAnimation(Design.Animation.snappy) {
                            priority = p
                        }
                    }) {
                        HStack(spacing: Design.Spacing.xs) {
                            Circle()
                                .fill(priorityColorFor(p))
                                .frame(width: 10, height: 10)
                            
                            Text(p.displayName)
                                .font(Design.Typography.bodyMedium)
                        }
                        .padding(.horizontal, Design.Spacing.md)
                        .padding(.vertical, Design.Spacing.sm)
                        .background(
                            Capsule()
                                .fill(priority == p ? CloudoTheme.jetBlack : CloudoTheme.secondaryBackground)
                        )
                        .foregroundColor(priority == p ? .white : CloudoTheme.textPrimary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func priorityColorFor(_ p: Priority) -> Color {
        switch p {
        case .low: return CloudoTheme.lime
        case .medium: return CloudoTheme.peach
        case .high: return CloudoTheme.salmon
        }
    }
    
    // MARK: - Color Selector
    
    private var colorSelector: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Card Color")
                .font(Design.Typography.caption)
                .foregroundColor(CloudoTheme.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.sm) {
                    ForEach(0..<CloudoTheme.cardColors.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(Design.Animation.snappy) {
                                selectedColorIndex = index
                            }
                        }) {
                            Circle()
                                .fill(CloudoTheme.cardColors[index])
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(CloudoTheme.jetBlack, lineWidth: selectedColorIndex == index ? 3 : 0)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(CloudoTheme.cardColors[index].isLight ? CloudoTheme.jetBlack : .white)
                                        .opacity(selectedColorIndex == index ? 1 : 0)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, Design.Spacing.xs)
            }
        }
    }
    
    // MARK: - Reminder Section
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            // Toggle
            HStack {
                VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                    Text("Reminder")
                        .font(Design.Typography.bodyMedium)
                        .foregroundColor(CloudoTheme.textPrimary)
                    
                    Text("Get notified at a specific time")
                        .font(Design.Typography.caption)
                        .foregroundColor(CloudoTheme.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $hasReminder)
                    .labelsHidden()
                    .tint(CloudoTheme.jetBlack)
            }
            .padding(Design.Spacing.md)
            .background(CloudoTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            
            // Date picker
            if hasReminder {
                DatePicker(
                    "Reminder Date",
                    selection: $reminderDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(CloudoTheme.royalBlue)
                .padding(Design.Spacing.md)
                .background(CloudoTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            }
        }
    }
    
    // MARK: - Recurrence Selector
    
    private var recurrenceSelector: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text("Repeat")
                .font(Design.Typography.caption)
                .foregroundColor(CloudoTheme.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.xs) {
                    ForEach(Recurrence.allCases, id: \.self) { r in
                        Button(action: {
                            withAnimation(Design.Animation.snappy) {
                                recurrence = r
                            }
                        }) {
                            Text(r.displayName)
                                .font(Design.Typography.caption)
                                .padding(.horizontal, Design.Spacing.md)
                                .padding(.vertical, Design.Spacing.sm)
                                .background(
                                    Capsule()
                                        .fill(recurrence == r ? CloudoTheme.jetBlack : CloudoTheme.secondaryBackground)
                                )
                                .foregroundColor(recurrence == r ? .white : CloudoTheme.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(action: deleteTask) {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete Task")
            }
            .font(Design.Typography.bodyMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(Design.Spacing.md)
            .background(CloudoTheme.salmon)
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
        }
        .buttonStyle(CardButtonStyle())
    }
    
    // MARK: - Actions
    
    private func loadExistingData() {
        guard let task = task else { return }
        
        title = task.title ?? ""
        notes = task.notes ?? ""
        
        if let priorityString = task.priority,
           let p = Priority(rawValue: priorityString) {
            priority = p
        }
        
        if let reminderDate = task.reminderDate {
            hasReminder = true
            self.reminderDate = reminderDate
        }
        
        if let recurrenceString = task.recurrence,
           let r = Recurrence(rawValue: recurrenceString) {
            recurrence = r
        }
        
        selectedCategory = task.category
        
        // Find color index from category or use default
        if let category = task.category,
           let colorHex = category.colorHex,
           let index = CloudoTheme.cardColorHexes.firstIndex(of: colorHex) {
            selectedColorIndex = index
        }
    }
    
    private func saveTask() {
        let taskToSave: Task
        
        if let existingTask = task {
            taskToSave = existingTask
        } else {
            taskToSave = Task(context: viewContext)
            taskToSave.id = UUID()
            taskToSave.createdAt = Date()
        }
        
        taskToSave.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        taskToSave.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        taskToSave.priority = priority.rawValue
        taskToSave.recurrence = recurrence.rawValue
        taskToSave.category = selectedCategory
        
        // Handle reminder
        if hasReminder {
            taskToSave.reminderDate = reminderDate
            
            // Cancel existing notification
            if let existingTask = task {
                NotificationService.shared.cancelNotification(for: existingTask)
            }
            
            // Schedule new notification
            NotificationService.shared.scheduleNotification(for: taskToSave, at: reminderDate)
        } else {
            // Cancel notification if reminder was removed
            if let existingTask = task {
                NotificationService.shared.cancelNotification(for: existingTask)
            }
            taskToSave.reminderDate = nil
        }
        
        // Create or update category with selected color
        if selectedCategory == nil {
            // Find or create a category with the selected color
            let colorHex = CloudoTheme.cardColorHexes[selectedColorIndex]
            
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "colorHex == %@", colorHex)
            
            if let existingCategory = try? viewContext.fetch(fetchRequest).first {
                taskToSave.category = existingCategory
            } else {
                let newCategory = Category(context: viewContext)
                newCategory.id = UUID()
                newCategory.name = "Tasks"
                newCategory.colorHex = colorHex
                taskToSave.category = newCategory
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func deleteTask() {
        guard let task = task else { return }
        
        // Cancel notification
        NotificationService.shared.cancelNotification(for: task)
        
        viewContext.delete(task)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}

// MARK: - Preview

#Preview("Add Task") {
    TaskFormView(mode: .add)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
