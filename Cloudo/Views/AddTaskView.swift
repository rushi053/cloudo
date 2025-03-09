import SwiftUI
import UserNotifications

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var title = ""
    @State private var taskDescription = ""
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
                                        
                                        if let reminderDate = reminderDate {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(reminderDate, style: .date)
                                                    .font(.system(size: 14))
                                                Text(reminderDate, style: .time)
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
                    Text("New Task")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.sheetTextColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        createTask()
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
            .presentationBackground(themeManager.sheetBackgroundColor)
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
            .presentationBackground(themeManager.sheetBackgroundColor)
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
            .presentationBackground(themeManager.sheetBackgroundColor)
        }
    }
    
    private func createTask() {
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = taskDescription.isEmpty ? nil : taskDescription
        newTask.createdAt = Date()
        newTask.completed = false
        newTask.reminderDate = reminderDate
        newTask.category = selectedCategory
        newTask.priority = Int16(selectedPriority.rawValue)
        
        // Set recurrence properties
        newTask.recurrenceType = Int16(selectedRecurrenceType.rawValue)
        newTask.isRecurring = selectedRecurrenceType != .none
        
        do {
            try viewContext.save()
            
            // Schedule notification if needed
            if let reminderDate = reminderDate {
                // Request notification permissions if this is a task with a reminder
                NotificationManager.shared.requestAuthorization { granted in
                    if granted {
                        NotificationManager.shared.scheduleNotification(for: newTask)
                        print("Notification permission granted and reminder scheduled")
                    } else {
                        print("Notification permission denied, reminder not scheduled")
                    }
                }
            }
            
            HapticManager.shared.successFeedback()
            dismiss()
        } catch {
            print("Error creating task: \(error)")
        }
    }
}

#Preview {
    AddTaskView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 
