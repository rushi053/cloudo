import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isExpanded = false
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Task Content
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isExpanded.toggle() } }) {
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            task.completed.toggle()
                        }
                    }) {
                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(task.completed ? Theme.primaryPastel : themeManager.secondaryColor)
                            .contentShape(Rectangle())
                    }
                    .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title ?? "")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(task.completed ? themeManager.secondaryColor : themeManager.textColor)
                            .strikethrough(task.completed)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            if let description = task.taskDescription, !description.isEmpty {
                                Text(description)
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.secondaryColor)
                                    .lineLimit(1)
                            }
                            
                            if let description = task.taskDescription, !description.isEmpty, let _ = task.reminderDate {
                                Text("•")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.secondaryColor)
                            }
                            
                            if let reminder = task.reminderDate {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                    Text(reminder, style: .time)
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(themeManager.secondaryColor)
                            }
                            
                            if (task.taskDescription == nil || task.taskDescription!.isEmpty) && task.reminderDate == nil {
                                Color.clear
                                    .frame(height: 16)
                            }
                        }
                        .frame(height: 16)
                    }
                    
                    Spacer()
                    
                    if let reminder = task.reminderDate {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                task.reminderDate = nil
                            }
                        }) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.secondaryColor)
                                .contentShape(Rectangle())
                        }
                        .frame(width: 24, height: 24)
                    } else {
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.secondaryColor)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            // Expanded Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                
                HStack(spacing: 20) {
                    Button(action: { 
                        showingEditSheet = true
                        HapticManager.shared.mediumTapFeedback()
                    }) {
                        Label("Edit", systemImage: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.primaryPastel)
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .frame(height: isExpanded ? 120 : 68)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.isDarkMode ? Theme.backgroundPastel.opacity(0.1) : Color.white)
                .shadow(color: Theme.primaryPastel.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity)
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(task: task)
                .presentationDetents([.medium])
        }
    }
    
    private func deleteTask() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewContext.delete(task)
            try? viewContext.save()
        }
    }
}

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var task: Task
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var title: String
    @State private var taskDescription: String
    @State private var reminderDate: Date?
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _reminderDate = State(initialValue: task.reminderDate)
        if let reminder = task.reminderDate {
            _selectedDate = State(initialValue: reminder)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.sheetBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Title Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TASK DETAILS")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                TextField("", text: $title)
                                    .font(.system(size: 16))
                                    .placeholder(when: title.isEmpty) {
                                        Text("Task Title")
                                            .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                    }
                                    .foregroundColor(themeManager.sheetTextColor)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.sheetTextColor.opacity(0.1))
                                    )
                                
                                TextField("", text: $taskDescription)
                                    .font(.system(size: 16))
                                    .placeholder(when: taskDescription.isEmpty) {
                                        Text("Description (Optional)")
                                            .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                    }
                                    .foregroundColor(themeManager.sheetTextColor)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.sheetTextColor.opacity(0.1))
                                    )
                            }
                            
                            // Reminder Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("REMINDER")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                Button(action: { showingDatePicker = true }) {
                                    HStack {
                                        Image(systemName: reminderDate == nil ? "bell.badge" : "bell.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(themeManager.sheetTextColor.opacity(0.7))
                                        
                                        if let reminder = reminderDate {
                                            Text(reminder, style: .time)
                                                .foregroundColor(themeManager.sheetTextColor)
                                        } else {
                                            Text("Set Reminder")
                                                .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        if reminderDate != nil {
                                            Button(action: { 
                                                withAnimation {
                                                    self.reminderDate = nil
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.7))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(themeManager.sheetTextColor.opacity(0.1))
                                    )
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.sheetTextColor)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Edit Task")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.sheetTextColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(title.isEmpty ? themeManager.sheetTextColor.opacity(0.5) : Theme.primaryPastel)
                    .disabled(title.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                ZStack {
                    themeManager.sheetBackgroundColor
                        .ignoresSafeArea()
                    
                    VStack {
                        DatePicker("Select Time",
                                  selection: $selectedDate,
                                  displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            .environment(\.colorScheme, themeManager.isDarkMode ? .light : .dark)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingDatePicker = false
                        }
                        .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Set Time")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Set") {
                            reminderDate = selectedDate
                            showingDatePicker = false
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.primaryPastel)
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
    }
    
    private func saveChanges() {
        task.title = title
        task.taskDescription = taskDescription.isEmpty ? nil : taskDescription
        task.reminderDate = reminderDate
        
        do {
            try viewContext.save()
            HapticManager.shared.successFeedback()
            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.title = "Sample Task"
    task.taskDescription = "This is a description"
    task.completed = false
    task.reminderDate = Date()
    return TaskRow(task: task)
        .padding()
        .background(Theme.backgroundPastel)
} 