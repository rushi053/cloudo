import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var reminderDate: Date?
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
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
                    Text("New Task")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.sheetTextColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveTask()
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
    
    private func saveTask() {
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = taskDescription.isEmpty ? nil : taskDescription
        newTask.reminderDate = reminderDate
        newTask.createdAt = Date()
        newTask.completed = false
        
        do {
            try viewContext.save()
            HapticManager.shared.successFeedback()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    AddTaskView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 
