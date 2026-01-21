//
//  TaskListView.swift
//  Cloudo
//
//  Main task list view with filtering and sorting
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
    @State private var showSortMenu = false
    
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
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { task in
                let titleMatch = task.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let descMatch = task.taskDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                return titleMatch || descMatch
            }
        }
        
        // Sort
        result = sortTasks(result)
        
        return result
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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category filter
                    if !categories.isEmpty {
                        categoryFilter
                    }
                    
                    // Task list
                    if filteredTasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .navigationTitle(showCompleted ? "Completed" : "Tasks")
            .searchable(text: $searchText, prompt: "Search tasks...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenuButton
                }
            }
            .sheet(item: $showTaskDetail) { task in
                TaskFormView(task: task)
            }
        }
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Design.Spacing.sm) {
                // All categories pill
                categoryPill(nil, name: "All")
                
                // Individual categories
                ForEach(categories) { category in
                    categoryPill(category, name: category.name ?? "")
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.vertical, Design.Spacing.md)
        }
        .background(Color(.systemBackground))
    }
    
    private func categoryPill(_ category: Category?, name: String) -> some View {
        let isSelected = (category == nil && selectedCategory == nil) ||
                        (category?.id == selectedCategory?.id)
        
        return Button(action: {
            withAnimation(Design.Animation.quick) {
                selectedCategory = category
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            HStack(spacing: Design.Spacing.xs) {
                if let category = category {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                }
                
                Text(name)
                    .font(Design.Typography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Task List
    
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: Design.Spacing.md) {
                ForEach(filteredTasks, id: \.objectID) { task in
                    TaskCard(
                        task: task,
                        onTap: { showTaskDetail = task },
                        onComplete: { }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.vertical, Design.Spacing.md)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Design.Spacing.lg) {
            Spacer()
            
            Image(systemName: showCompleted ? "checkmark.circle" : "checklist")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: Design.Spacing.sm) {
                Text(showCompleted ? "No completed tasks" : "No tasks yet")
                    .font(Design.Typography.title3)
                    .foregroundStyle(.primary)
                
                Text(showCompleted 
                     ? "Tasks you complete will appear here"
                     : "Tap the + button to add your first task")
                    .font(Design.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Design.Spacing.xl)
    }
    
    // MARK: - Sort Menu
    
    private var sortMenuButton: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button(action: {
                    selectedSort = option
                }) {
                    HStack {
                        Image(systemName: option.icon)
                        Text(option.rawValue)
                        
                        if selectedSort == option {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 16, weight: .medium))
        }
    }
    
    // MARK: - Actions
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            NotificationService.shared.cancelNotification(for: task)
            viewContext.delete(task)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TaskListView(showCompleted: false)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
