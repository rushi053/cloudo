//
//  TaskListView.swift
//  Cloudo
//
//  Beautiful task list with modern header and filtering
//

import SwiftUI
import CoreData

struct TaskListView: View {
    
    // MARK: - Properties
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState: AppState
    
    let showCompleted: Bool
    
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedSort: SortOption = .dateCreated
    @State private var showTaskDetail: Task?
    
    // MARK: - Fetch Request
    
    @FetchRequest private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>
    
    // MARK: - Initialization
    
    init(showCompleted: Bool) {
        self.showCompleted = showCompleted
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: showCompleted))
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.priority, ascending: false),
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)
        ]
        
        _tasks = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    // MARK: - Computed Properties
    
    private var filteredTasks: [Task] {
        var result = Array(tasks)
        
        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }
        
        if !searchText.isEmpty {
            result = result.filter { task in
                let titleMatch = task.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let descMatch = task.taskDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                return titleMatch || descMatch
            }
        }
        
        return sortTasks(result)
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch selectedSort {
        case .dateCreated:
            return tasks.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .dueDate:
            return tasks.sorted { task1, task2 in
                guard let date1 = task1.reminderDate else { return false }
                guard let date2 = task2.reminderDate else { return true }
                return date1 < date2
            }
        case .priority:
            return tasks.sorted { $0.priority > $1.priority }
        case .alphabetical:
            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
        }
    }
    
    private var taskCount: Int {
        filteredTasks.count
    }
    
    private var overdueCount: Int {
        filteredTasks.filter { $0.isOverdue }.count
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            CloudoTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search bar
                searchBar
                    .padding(.horizontal, Design.Spacing.lg)
                    .padding(.bottom, Design.Spacing.md)
                
                // Category filter
                if !categories.isEmpty {
                    categoryFilter
                        .padding(.bottom, Design.Spacing.md)
                }
                
                // Task list or empty state
                if filteredTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
        }
        .sheet(item: $showTaskDetail) { task in
            TaskFormView(task: task)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                // Greeting or title
                Text(showCompleted ? "Completed" : greeting)
                    .font(Design.Typography.title)
                    .foregroundStyle(.primary)
                
                // Subtitle with count
                if !showCompleted && taskCount > 0 {
                    Text("\(taskCount) task\(taskCount == 1 ? "" : "s") remaining")
                        .font(Design.Typography.subheadline)
                        .foregroundStyle(.secondary)
                } else if showCompleted {
                    Text("Great work! 🎉")
                        .font(Design.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Sort button
            sortMenu
        }
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, Design.Spacing.lg)
        .padding(.bottom, Design.Spacing.md)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤"
        case 17..<21: return "Good evening 🌅"
        default: return "Good night 🌙"
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Design.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search tasks...", text: $searchText)
                .font(Design.Typography.body)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(Design.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                .fill(CloudoTheme.cardBackground)
        )
    }
    
    // MARK: - Sort Menu
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button(action: { selectedSort = option }) {
                    HStack {
                        Image(systemName: option.icon)
                        Text(option.rawValue)
                        if selectedSort == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: Design.Spacing.xs) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12, weight: .semibold))
                
                Text(selectedSort.rawValue)
                    .font(Design.Typography.caption)
            }
            .foregroundColor(CloudoTheme.primary)
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.sm)
            .background(
                Capsule()
                    .fill(CloudoTheme.primary.opacity(0.1))
            )
        }
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Design.Spacing.sm) {
                categoryPill(nil, name: "All", color: CloudoTheme.primary)
                
                ForEach(categories) { category in
                    categoryPill(category, name: category.name ?? "", color: category.color)
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
        }
    }
    
    private func categoryPill(_ category: Category?, name: String, color: Color) -> some View {
        let isSelected = (category == nil && selectedCategory == nil) ||
                        (category?.id == selectedCategory?.id)
        
        return Button(action: {
            withAnimation(Design.Animation.snappy) {
                selectedCategory = category
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            HStack(spacing: Design.Spacing.xs) {
                if category != nil {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
                
                Text(name)
                    .font(Design.Typography.footnote)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? color : CloudoTheme.cardBackground)
            )
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Task List
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: Design.Spacing.md) {
                // Overdue section
                if !showCompleted && overdueCount > 0 {
                    overdueHeader
                }
                
                ForEach(filteredTasks, id: \.objectID) { task in
                    TaskCard(
                        task: task,
                        onTap: { showTaskDetail = task },
                        onComplete: { }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, 140) // Space for tab bar + FAB
        }
    }
    
    private var overdueHeader: some View {
        HStack(spacing: Design.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(CloudoTheme.coral)
            
            Text("\(overdueCount) overdue")
                .font(Design.Typography.footnote)
                .fontWeight(.semibold)
                .foregroundColor(CloudoTheme.coral)
            
            Spacer()
        }
        .padding(.vertical, Design.Spacing.sm)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Design.Spacing.xl) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(CloudoTheme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: showCompleted ? "checkmark.seal.fill" : "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(CloudoTheme.primaryGradient)
            }
            
            VStack(spacing: Design.Spacing.sm) {
                Text(showCompleted ? "No completed tasks yet" : "All caught up!")
                    .font(Design.Typography.title3)
                    .foregroundStyle(.primary)
                
                Text(showCompleted 
                     ? "Tasks you complete will show up here"
                     : "Tap the + button to add a new task")
                    .font(Design.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Design.Spacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    TaskListView(showCompleted: false)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
