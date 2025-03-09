import SwiftUI
import UserNotifications

struct TaskRow: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isExpanded = false
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var pulseEffect = false
    
    // Add environment object for the toast manager
    @EnvironmentObject private var toastManager: ToastManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Task Content
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isExpanded.toggle() } }) {
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if task.isRecurring && !task.completed {
                                // For recurring tasks, show a toast message
                                if let reminderDate = task.reminderDate,
                                   let recurrenceType = RecurrenceType(rawValue: Int(task.recurrenceType)),
                                   let nextDate = recurrenceType.nextDate(from: reminderDate) {
                                    // Use the toast manager instead of local state
                                    toastManager.showToast(
                                        title: "Task will recur",
                                        message: "Next: \(dateFormatter.string(from: nextDate))",
                                        icon: "arrow.triangle.2.circlepath",
                                        iconColor: Theme.primaryPastel
                                    )
                                }
                            }
                            
                            task.completed.toggle()
                            
                            if task.completed && task.isRecurring {
                                // Handle recurring task completion
                                NotificationManager.shared.handleTaskCompletion(task: task)
                                HapticManager.shared.successFeedback()
                            } else {
                                HapticManager.shared.successFeedback()
                            }
                        }
                    }) {
                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(task.completed ? Theme.primaryPastel : themeManager.secondaryColor)
                            .contentShape(Rectangle())
                    }
                    .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Title row with priority indicator
                        HStack(alignment: .center, spacing: 8) {
                            // Priority indicator (if not none)
                            if task.priority != 0 {
                                let priority = TaskPriority(rawValue: Int(task.priority)) ?? .none
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        // Add pulsing effect for high priority tasks
                                        priority == .high ? 
                                            Circle()
                                                .stroke(priority.color.opacity(0.5), lineWidth: 2)
                                                .scaleEffect(pulseEffect ? 1.8 : 1.5)
                                                .opacity(pulseEffect ? 0.4 : 0.6)
                                            : nil
                                    )
                            }
                            
                            Text(task.title ?? "")
                                .font(.system(size: 16, weight: task.priority == 3 ? .semibold : .medium))
                                .foregroundColor(task.completed ? themeManager.secondaryColor : themeManager.textColor)
                                .strikethrough(task.completed)
                                .lineLimit(1)
                            
                            // Recurring indicator
                            if task.isRecurring {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.primaryPastel)
                            }
                        }
                        
                        // Metadata row (category, description, reminder)
                        HStack(spacing: 8) {
                            // Category pill if available
                            if let category = task.category {
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(CategoryManager.shared.color(from: category.color))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(category.name ?? "")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(themeManager.secondaryColor)
                                }
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(CategoryManager.shared.color(from: category.color).opacity(themeManager.isDarkMode ? 0.15 : 0.1))
                                )
                            }
                            
                            // Description snippet if available
                            if let description = task.taskDescription, !description.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.alignleft")
                                        .font(.system(size: 10))
                                    Text(description)
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                }
                                .foregroundColor(themeManager.secondaryColor)
                            }
                            
                            // Reminder time if available
                            if let reminderDate = task.reminderDate {
                                HStack(spacing: 4) {
                                    Image(systemName: task.isRecurring ? "arrow.triangle.2.circlepath" : "clock")
                                        .font(.system(size: 10))
                                    Text(reminderDate, style: .time)
                                        .font(.system(size: 12))
                                    if task.isRecurring {
                                        Text("•")
                                            .font(.system(size: 10))
                                            .foregroundColor(Theme.primaryPastel)
                                        Text(RecurrenceType(rawValue: Int(task.recurrenceType))?.shortName ?? "")
                                            .font(.system(size: 10))
                                            .foregroundColor(Theme.primaryPastel)
                                    }
                                }
                                .foregroundColor(themeManager.isDarkMode ? 
                                    themeManager.secondaryColor.opacity(0.6) : 
                                    themeManager.secondaryColor.opacity(0.7))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(task.isRecurring ? 
                                              Theme.primaryPastel.opacity(0.1) : 
                                              themeManager.secondaryColor.opacity(0.1))
                                )
                            }
                            
                            // Spacer to push content to the left
                            Spacer()
                        }
                        .frame(height: 20)
                    }
                    
                    Spacer()
                    
                    // Right side controls - moved bell icon to be separate from chevron
                    HStack(spacing: 12) {
                        // Reminder cancel button if reminder exists
                        if task.reminderDate != nil {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    task.reminderDate = nil
                                }
                            }) {
                                Image(systemName: "bell.slash.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.secondaryColor)
                                    .contentShape(Rectangle())
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        // Expand/collapse indicator
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.secondaryColor)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .frame(width: 14)
                    }
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
                            .foregroundColor(Color(hex: "#FF9AA2")) // Using the pink color for consistency
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .frame(height: isExpanded ? 120 : 72) // Slightly taller for better spacing
        .background(
            ZStack {
                // Main background
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.isDarkMode ? Theme.backgroundPastel.opacity(0.1) : Color.white)
                    .shadow(color: task.priority == 3 && !task.completed ? 
                            TaskPriority.high.color.opacity(0.2) : 
                            Theme.primaryPastel.opacity(0.1), 
                           radius: task.priority == 3 && !task.completed ? 10 : 8, 
                           x: 0, y: 2)
                
                // Priority indicator as a left border overlay
                if task.priority != 0 {
                    let priority = TaskPriority(rawValue: Int(task.priority)) ?? .none
                    
                    // Very simple priority indicator
                    HStack(spacing: 0) {
                        // Left edge priority indicator
                        Rectangle()
                            .fill(priority.color)
                            .frame(width: 4)
                        
                        Spacer()
                    }
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
            }
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(themeManager.sheetBackgroundColor)
                .presentationCornerRadius(16)
        }
        .onAppear {
            // Start the pulse animation for high-priority tasks
            if task.priority == 3 && !task.completed {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseEffect = true
                }
            }
        }
    }
    
    // Date formatter for the toast message
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func deleteTask() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // Cancel any pending notifications for this task before deleting it
            if let taskId = task.id?.uuidString {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
            }
            
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
    @State private var selectedCategory: Category?
    @State private var showingCategoryPicker = false
    @State private var selectedPriority: TaskPriority = .none
    @State private var selectedRecurrenceType: RecurrenceType = .none
    @State private var showingRecurrencePicker = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _reminderDate = State(initialValue: task.reminderDate)
        _selectedCategory = State(initialValue: task.category)
        _selectedPriority = State(initialValue: TaskPriority(rawValue: Int(task.priority)) ?? .none)
        _selectedRecurrenceType = State(initialValue: RecurrenceType(rawValue: Int(task.recurrenceType)) ?? .none)
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
                            
                            // Category Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CATEGORY")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                Button(action: { showingCategoryPicker = true }) {
                                    HStack {
                                        if let category = selectedCategory {
                                            HStack(spacing: 8) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(CategoryManager.shared.color(from: category.color))
                                                    .frame(width: 16, height: 16)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                                
                                                Text(category.name ?? "")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(themeManager.sheetTextColor)
                                            }
                                        } else {
                                            Text("Select Category (Optional)")
                                                .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedCategory != nil {
                                            Button(action: { 
                                                withAnimation {
                                                    selectedCategory = nil
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.7))
                                            }
                                        } else {
                                            Image(systemName: "tag")
                                                .font(.system(size: 14))
                                                .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
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
                            
                            // Priority Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("PRIORITY")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.8))
                                    .padding(.leading, 4)
                                
                                HStack(spacing: 8) {
                                    ForEach(TaskPriority.allCases) { priority in
                                        Button(action: {
                                            withAnimation {
                                                selectedPriority = priority
                                            }
                                        }) {
                                            VStack(spacing: 4) {
                                                Circle()
                                                    .fill(priority.color)
                                                    .frame(width: 16, height: 16)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(themeManager.sheetTextColor, lineWidth: selectedPriority == priority ? 2 : 0)
                                                    )
                                                
                                                Text(priority.name)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(themeManager.sheetTextColor)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedPriority == priority ? 
                                                          priority.color.opacity(themeManager.isDarkMode ? 0.2 : 0.1) : 
                                                          Color.clear)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
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
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(reminder, style: .date)
                                                    .font(.system(size: 14))
                                                Text(reminder, style: .time)
                                                    .font(.system(size: 12))
                                            }
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
                                                    self.selectedRecurrenceType = .none
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
                                
                                // Recurrence options (only show if reminder is set)
                                if reminderDate != nil {
                                    Button(action: { showingRecurrencePicker = true }) {
                                        HStack {
                                            Image(systemName: selectedRecurrenceType == .none ? "repeat" : selectedRecurrenceType.systemImage)
                                                .font(.system(size: 18))
                                                .foregroundColor(themeManager.sheetTextColor.opacity(0.7))
                                            
                                            if selectedRecurrenceType == .none {
                                                Text("Add Recurrence")
                                                    .foregroundColor(themeManager.sheetTextColor.opacity(0.5))
                                            } else {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(selectedRecurrenceType.name)
                                                        .font(.system(size: 14))
                                                    if let reminder = reminderDate {
                                                        Text(selectedRecurrenceType.description(for: reminder))
                                                            .font(.system(size: 12))
                                                    }
                                                }
                                                .foregroundColor(themeManager.sheetTextColor)
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedRecurrenceType != .none {
                                                Button(action: { 
                                                    withAnimation {
                                                        self.selectedRecurrenceType = .none
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
                                    .disabled(reminderDate == nil)
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
                    
                    VStack(spacing: 20) {
                        DatePicker("Select Date",
                                  selection: $selectedDate,
                                  in: Date()...,
                                  displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            
                        DatePicker("Select Time",
                                  selection: $selectedDate,
                                  displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            
                        Spacer()
                    }
                    .environment(\.colorScheme, themeManager.isDarkMode ? .light : .dark)
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
                        Text("Set Reminder")
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
            .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $showingCategoryPicker) {
            NavigationView {
                ZStack {
                    themeManager.sheetBackgroundColor
                        .ignoresSafeArea()
                    
                    VStack {
                        if categories.isEmpty {
                            ContentUnavailableView(
                                "No Categories",
                                systemImage: "tag",
                                description: Text("Add categories in settings")
                            )
                            .foregroundStyle(themeManager.sheetTextColor)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(categories) { category in
                                    Button(action: {
                                        selectedCategory = category
                                        showingCategoryPicker = false
                                    }) {
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(CategoryManager.shared.color(from: category.color))
                                                .frame(width: 16, height: 16)
                                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                            
                                            Text(category.name ?? "")
                                                .foregroundColor(themeManager.sheetTextColor)
                                            
                                            Spacer()
                                            
                                            if selectedCategory?.id == category.id {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(Theme.primaryPastel)
                                            }
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                    }
                                    
                                    Divider()
                                        .padding(.leading, 44)
                                        .background(themeManager.secondaryColor.opacity(0.1))
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingCategoryPicker = false
                        }
                        .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Select Category")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CategoriesView()) {
                            Image(systemName: "plus")
                                .foregroundColor(themeManager.sheetTextColor)
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingRecurrencePicker) {
            NavigationView {
                ZStack {
                    themeManager.sheetBackgroundColor
                        .ignoresSafeArea()
                    
                    VStack {
                        List {
                            ForEach(RecurrenceType.allCases) { recurrenceType in
                                Button(action: {
                                    selectedRecurrenceType = recurrenceType
                                    showingRecurrencePicker = false
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: recurrenceType.systemImage)
                                            .foregroundColor(Theme.primaryPastel)
                                            .frame(width: 24, height: 24)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(recurrenceType.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(themeManager.sheetTextColor)
                                            
                                            if recurrenceType != .none, let reminder = reminderDate {
                                                Text(recurrenceType.description(for: reminder))
                                                    .font(.system(size: 12))
                                                    .foregroundColor(themeManager.sheetTextColor)
                                            } else if recurrenceType == .none {
                                                // Add empty text to maintain consistent height
                                                Text(" ")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.clear)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedRecurrenceType == recurrenceType {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(Theme.primaryPastel)
                                        }
                                    }
                                }
                                .listRowBackground(themeManager.sheetBackgroundColor)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingRecurrencePicker = false
                        }
                        .foregroundColor(themeManager.sheetTextColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Recurrence")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.sheetTextColor)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func saveChanges() {
        task.title = title
        task.taskDescription = taskDescription.isEmpty ? nil : taskDescription
        task.reminderDate = reminderDate
        task.category = selectedCategory
        task.priority = Int16(selectedPriority.rawValue)
        
        // Set recurrence properties
        task.recurrenceType = Int16(selectedRecurrenceType.rawValue)
        task.isRecurring = selectedRecurrenceType != .none
        
        do {
            try viewContext.save()
            
            // Handle notifications
            if reminderDate != nil && !task.completed {
                // Request notification permissions if adding a reminder
                NotificationManager.shared.requestAuthorization { granted in
                    if granted {
                        NotificationManager.shared.scheduleNotification(for: task)
                        print("Notification permission granted and reminder scheduled")
                    } else {
                        print("Notification permission denied, reminder not scheduled")
                    }
                }
            } else {
                NotificationManager.shared.cancelNotification(for: task)
            }
            
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
        .environmentObject(ToastManager())
} 
