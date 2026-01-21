//
//  TaskListView.swift
//  Cloudo
//
//  Main task list view with colorful cards
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var haptics: HapticService
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.reminderDate, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
        ],
        animation: .default
    )
    private var tasks: FetchedResults<Task>
    
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    @State private var searchText = ""
    @State private var selectedSortOption: SortOption = .dueDate
    @State private var showCompletedTasks = true
    @State private var greeting = ""
    
    private var pendingTasks: [Task] {
        tasks.filter { !$0.isCompleted }
            .filter { searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }
    
    private var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
            .filter { searchText.isEmpty || ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }
    
    var body: some View {
        ZStack {
            // Background
            CloudoTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                    // Header
                    headerView
                    
                    // Search bar
                    searchBar
                    
                    // Task stats
                    if !tasks.isEmpty {
                        statsCard
                    }
                    
                    // Pending tasks
                    if !pendingTasks.isEmpty {
                        taskSection(
                            title: "Tasks",
                            count: pendingTasks.count,
                            tasks: pendingTasks
                        )
                    }
                    
                    // Add task button
                    AddTaskCard(action: { showingAddTask = true })
                        .padding(.horizontal, Design.Spacing.lg)
                    
                    // Completed tasks
                    if !completedTasks.isEmpty && showCompletedTasks {
                        completedSection
                    }
                    
                    // Empty state
                    if tasks.isEmpty {
                        emptyStateView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, Design.Spacing.md)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            TaskFormView(mode: .add)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $selectedTask) { task in
            TaskFormView(mode: .edit(task))
                .environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            updateGreeting()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(greeting)
                .font(Design.Typography.largeTitle)
                .foregroundColor(CloudoTheme.textPrimary)
            
            HStack(spacing: Design.Spacing.sm) {
                // Task count pill
                HStack(spacing: Design.Spacing.xxs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text("\(completedTasks.count) done")
                        .font(Design.Typography.caption)
                }
                .padding(.horizontal, Design.Spacing.sm)
                .padding(.vertical, Design.Spacing.xs)
                .background(CloudoTheme.purple)
                .clipShape(Capsule())
                .foregroundColor(CloudoTheme.textOnColor)
                
                // Pending pill
                HStack(spacing: Design.Spacing.xxs) {
                    Circle()
                        .fill(CloudoTheme.salmon)
                        .frame(width: 8, height: 8)
                    Text("\(pendingTasks.count) pending")
                        .font(Design.Typography.caption)
                }
                .padding(.horizontal, Design.Spacing.sm)
                .padding(.vertical, Design.Spacing.xs)
                .background(CloudoTheme.lime)
                .clipShape(Capsule())
                .foregroundColor(CloudoTheme.textOnColor)
            }
        }
        .padding(.horizontal, Design.Spacing.lg)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Design.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(CloudoTheme.textSecondary)
            
            TextField("Search tasks...", text: $searchText)
                .font(Design.Typography.body)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(CloudoTheme.textSecondary)
                }
            }
            
            // Sort button
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: { selectedSortOption = option }) {
                        Label(option.displayName, systemImage: selectedSortOption == option ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundColor(CloudoTheme.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(CloudoTheme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
            }
        }
        .padding(.horizontal, Design.Spacing.md)
        .padding(.vertical, Design.Spacing.sm)
        .background(CloudoTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
        .padding(.horizontal, Design.Spacing.lg)
    }
    
    // MARK: - Stats Card
    
    private var statsCard: some View {
        let completionRate = tasks.isEmpty ? 0 : Double(completedTasks.count) / Double(tasks.count)
        
        return VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Text("Progress")
                    .font(Design.Typography.subheadline)
                    .foregroundColor(CloudoTheme.textSecondary)
                
                Spacer()
                
                Text("\(Int(completionRate * 100))%")
                    .font(Design.Typography.title3)
                    .foregroundColor(CloudoTheme.textOnColor)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CloudoTheme.textOnColor.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CloudoTheme.textOnColor)
                        .frame(width: geometry.size.width * completionRate, height: 8)
                        .animation(Design.Animation.smooth, value: completionRate)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(pendingTasks.count) tasks remaining")
                    .font(Design.Typography.caption)
                    .foregroundColor(CloudoTheme.textSecondary)
                
                Spacer()
                
                if let nextTask = pendingTasks.first, let date = nextTask.reminderDate {
                    HStack(spacing: Design.Spacing.xxs) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("Next: \(formatRelativeDate(date))")
                            .font(Design.Typography.caption)
                    }
                    .foregroundColor(CloudoTheme.textSecondary)
                }
            }
        }
        .padding(Design.Spacing.lg)
        .largeCardStyle(color: CloudoTheme.purple)
        .padding(.horizontal, Design.Spacing.lg)
    }
    
    // MARK: - Task Section
    
    private func taskSection(title: String, count: Int, tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Text(title)
                    .font(Design.Typography.title3)
                    .foregroundColor(CloudoTheme.textPrimary)
                
                Text("(\(count))")
                    .font(Design.Typography.subheadline)
                    .foregroundColor(CloudoTheme.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, Design.Spacing.lg)
            
            LazyVStack(spacing: Design.Spacing.md) {
                ForEach(Array(tasks.enumerated()), id: \.element.objectID) { index, task in
                    TaskCard(
                        task: task,
                        cardColor: cardColor(for: index, task: task),
                        onToggle: { toggleTask(task) },
                        onTap: { selectedTask = task }
                    )
                    .padding(.horizontal, Design.Spacing.lg)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }
        }
    }
    
    // MARK: - Completed Section
    
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            Button(action: { 
                withAnimation(Design.Animation.smooth) {
                    showCompletedTasks.toggle()
                }
            }) {
                HStack {
                    Text("Completed")
                        .font(Design.Typography.title3)
                        .foregroundColor(CloudoTheme.textPrimary)
                    
                    Text("(\(completedTasks.count))")
                        .font(Design.Typography.subheadline)
                        .foregroundColor(CloudoTheme.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: showCompletedTasks ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(CloudoTheme.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, Design.Spacing.lg)
            
            if showCompletedTasks {
                LazyVStack(spacing: Design.Spacing.sm) {
                    ForEach(Array(completedTasks.enumerated()), id: \.element.objectID) { index, task in
                        CompactTaskCard(
                            task: task,
                            cardColor: cardColor(for: index, task: task),
                            onToggle: { toggleTask(task) },
                            onTap: { selectedTask = task }
                        )
                        .padding(.horizontal, Design.Spacing.lg)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Design.Spacing.lg) {
            // Decorative shapes
            ZStack {
                Circle()
                    .fill(CloudoTheme.royalBlue)
                    .frame(width: 80, height: 80)
                    .offset(x: -40, y: -20)
                
                Triangle()
                    .fill(CloudoTheme.lime)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(15))
                    .offset(x: 30, y: 0)
                
                CloudShape()
                    .fill(CloudoTheme.purple)
                    .frame(width: 50, height: 50)
                    .offset(x: -20, y: 40)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(CloudoTheme.salmon)
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 50, y: 50)
            }
            .frame(height: 120)
            
            VStack(spacing: Design.Spacing.sm) {
                Text("No tasks yet!")
                    .font(Design.Typography.title2)
                    .foregroundColor(CloudoTheme.textPrimary)
                
                Text("Tap the button below to create\nyour first task")
                    .font(Design.Typography.body)
                    .foregroundColor(CloudoTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Design.Spacing.xxl)
    }
    
    // MARK: - Helpers
    
    private func cardColor(for index: Int, task: Task) -> Color {
        // Use category color if available
        if let category = task.category,
           let colorHex = category.colorHex {
            return Color(hex: colorHex)
        }
        // Otherwise cycle through colors
        return CloudoTheme.cardColors[index % CloudoTheme.cardColors.count]
    }
    
    private func toggleTask(_ task: Task) {
        withAnimation(Design.Animation.bouncy) {
            task.isCompleted.toggle()
            
            if task.isCompleted {
                haptics.success()
                
                // Handle recurring tasks
                if let recurrenceString = task.recurrence,
                   let recurrence = Recurrence(rawValue: recurrenceString),
                   recurrence != .none {
                    createNextRecurringTask(from: task, recurrence: recurrence)
                }
            } else {
                haptics.selection()
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving: \(error)")
            }
        }
    }
    
    private func createNextRecurringTask(from task: Task, recurrence: Recurrence) {
        guard let currentDate = task.reminderDate else { return }
        
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = task.title
        newTask.notes = task.notes
        newTask.priority = task.priority
        newTask.category = task.category
        newTask.recurrence = task.recurrence
        newTask.isCompleted = false
        newTask.createdAt = Date()
        
        // Calculate next date
        let calendar = Calendar.current
        var nextDate: Date?
        
        switch recurrence {
        case .none:
            break
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate)
        case .weekly:
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: currentDate)
        case .yearly:
            nextDate = calendar.date(byAdding: .year, value: 1, to: currentDate)
        }
        
        newTask.reminderDate = nextDate
        
        // Schedule notification
        if let date = nextDate {
            NotificationService.shared.scheduleNotification(
                for: newTask,
                at: date
            )
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good morning"
        case 12..<17:
            greeting = "Good afternoon"
        default:
            greeting = "Good evening"
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Decorative Shapes

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Four-leaf clover shape like in the mockup
        path.addEllipse(in: CGRect(x: w * 0.2, y: 0, width: w * 0.6, height: h * 0.5))
        path.addEllipse(in: CGRect(x: w * 0.2, y: h * 0.5, width: w * 0.6, height: h * 0.5))
        path.addEllipse(in: CGRect(x: 0, y: h * 0.2, width: w * 0.5, height: h * 0.6))
        path.addEllipse(in: CGRect(x: w * 0.5, y: h * 0.2, width: w * 0.5, height: h * 0.6))
        
        return path
    }
}

// MARK: - Preview

#Preview {
    TaskListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HapticService())
}
