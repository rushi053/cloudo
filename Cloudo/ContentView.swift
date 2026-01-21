//
//  ContentView.swift
//  Cloudo
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAddTask = false
    @State private var showingCategories = false
    @State private var selectedTab = 0
    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCategory: Category?
    @State private var showingSortOptions = false
    @State private var selectedSortOption: TaskSortOption = .createdNewest
    @State private var showingDataManagement = false
    
    // Add ToastManager
    @StateObject private var toastManager = ToastManager()
    
    // Fetch all tasks with a basic sort
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var allTasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    // Computed property to sort and filter tasks
    private var tasks: [Task] {
        let sortedTasks = allTasks.sorted { task1, task2 in
            switch selectedSortOption {
            case .createdNewest:
                return (task1.createdAt ?? Date()) > (task2.createdAt ?? Date())
            case .createdOldest:
                return (task1.createdAt ?? Date()) < (task2.createdAt ?? Date())
            case .alphabetical:
                return (task1.title ?? "") < (task2.title ?? "")
            case .dueDate:
                // Tasks with reminder dates come first, sorted by date
                if let date1 = task1.reminderDate, let date2 = task2.reminderDate {
                    return date1 < date2
                } else if task1.reminderDate != nil {
                    return true
                } else if task2.reminderDate != nil {
                    return false
                } else {
                    // If neither has a reminder date, sort by creation date (newest first)
                    return (task1.createdAt ?? Date()) > (task2.createdAt ?? Date())
                }
            case .priority:
                // Sort by priority (high to low)
                if task1.priority != task2.priority {
                    return task1.priority > task2.priority
                } else {
                    // If same priority, sort by creation date (newest first)
                    return (task1.createdAt ?? Date()) > (task2.createdAt ?? Date())
                }
            }
        }
        
        return sortedTasks
    }
    
    // Update the sort option
    private func updateSortOption(_ option: TaskSortOption) {
        withAnimation {
            selectedSortOption = option
        }
    }
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            // First filter by completion status
            let matchesCompletionFilter: Bool
            if selectedTab == 0 {
                matchesCompletionFilter = !task.completed
            } else if selectedTab == 1 {
                matchesCompletionFilter = task.completed
            } else {
                matchesCompletionFilter = true
            }
            
            // Then filter by category if one is selected
            let matchesCategoryFilter: Bool
            if let selectedCategory = selectedCategory {
                matchesCategoryFilter = task.category?.id == selectedCategory.id
            } else {
                matchesCategoryFilter = true
            }
            
            return matchesCompletionFilter && matchesCategoryFilter
        }
    }
    
    var currentTabTitle: String {
        switch selectedTab {
        case 0:
            return "Tasks"
        case 1:
            return "Completed"
        case 2:
            return "All Tasks"
        default:
            return ""
        }
    }
    
    // Helper method to get color for sort options
    private func getSortOptionColor(for option: TaskSortOption) -> Color {
        switch option {
        case .createdNewest, .createdOldest:
            return Color(hex: "#74C0E0") // Light blue
        case .alphabetical:
            return Color(hex: "#7AE582") // Pale green
        case .dueDate:
            return Color(hex: "#FFC17A") // Peach
        case .priority:
            return Color(hex: "#FF9AA2") // Pink
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Title and Category Filter
                    VStack(spacing: 16) {
                        // Title and Sort Button
                        HStack {
                            Text(currentTabTitle)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(themeManager.textColor)
                                .padding(.horizontal)
                                .padding(.top, 12)
                            
                            Spacer()
                            
                            // Sort button
                            Menu {
                                ForEach(TaskSortOption.allCases) { option in
                                    Button(action: {
                                        withAnimation {
                                            updateSortOption(option)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: option.systemImage)
                                                .foregroundColor(getSortOptionColor(for: option))
                                                .font(.system(size: 14))
                                            
                                            Text(option.rawValue)
                                                .foregroundColor(themeManager.textColor)
                                            
                                            Spacer()
                                            
                                            if selectedSortOption == option {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(Theme.primaryPastel)
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .padding(.vertical, 6)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: selectedSortOption.systemImage)
                                        .font(.system(size: 14))
                                        .foregroundColor(getSortOptionColor(for: selectedSortOption))
                                    
                                    Text(selectedSortOption.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(themeManager.textColor)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                        .foregroundColor(themeManager.textColor.opacity(0.7))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(themeManager.isDarkMode ? 
                                              Theme.primaryPastel.opacity(0.15) : 
                                              Theme.primaryPastel.opacity(0.1))
                                        .shadow(color: Theme.primaryPastel.opacity(0.1), radius: 2, x: 0, y: 1)
                                )
                                .padding(.trailing, 16)
                                .padding(.top, 12)
                            }
                        }
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // All categories option
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = nil
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Text("All")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedCategory == nil ? 
                                                            (themeManager.isDarkMode ? .white : .black) : 
                                                            themeManager.secondaryColor)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == nil ? 
                                                 Theme.primaryPastel.opacity(themeManager.isDarkMode ? 0.7 : 0.3) : 
                                                 themeManager.secondaryColor.opacity(0.1))
                                            .shadow(color: Theme.primaryPastel.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                                
                                // Individual categories
                                ForEach(categories) { category in
                                    Button(action: {
                                        withAnimation {
                                            if selectedCategory?.id == category.id {
                                                selectedCategory = nil
                                            } else {
                                                selectedCategory = category
                                            }
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(CategoryManager.shared.color(from: category.color))
                                                .frame(width: 8, height: 8)
                                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                                            
                                            Text(category.name ?? "")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedCategory?.id == category.id ? 
                                                               (themeManager.isDarkMode ? .white : .black) : 
                                                               themeManager.secondaryColor)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory?.id == category.id ? 
                                                     CategoryManager.shared.color(from: category.color).opacity(themeManager.isDarkMode ? 0.5 : 0.3) : 
                                                     themeManager.secondaryColor.opacity(0.1))
                                                .shadow(color: Theme.primaryPastel.opacity(0.1), radius: 2, x: 0, y: 1)
                                        )
                                    }
                                }
                                
                                // Add category button
                                Button(action: {
                                    showingCategories = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "tag")
                                            .font(.system(size: 12))
                                        Text("Manage")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(themeManager.secondaryColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .stroke(themeManager.secondaryColor.opacity(0.2), lineWidth: 1)
                                            .background(
                                                Capsule()
                                                    .fill(themeManager.secondaryColor.opacity(0.05))
                                            )
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        }
                        .frame(height: 0)
                        
                        if filteredTasks.isEmpty {
                            VStack {
                                Spacer()
                                    .frame(height: 100)
                                if selectedTab == 1 {
                                    ContentUnavailableView(
                                        "No Completed Tasks",
                                        systemImage: "checkmark.circle",
                                        description: Text("Tasks you complete will appear here")
                                    )
                                    .foregroundStyle(themeManager.secondaryColor)
                                } else if selectedCategory != nil {
                                    ContentUnavailableView(
                                        "No Tasks in This Category",
                                        systemImage: "tag",
                                        description: Text("Add tasks to this category to see them here")
                                    )
                                    .foregroundStyle(themeManager.secondaryColor)
                                } else {
                                    ContentUnavailableView(
                                        "No Tasks",
                                        systemImage: "list.bullet.circle",
                                        description: Text("Add some tasks to get started")
                                    )
                                    .foregroundStyle(themeManager.secondaryColor)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredTasks) { task in
                                    TaskRow(task: task)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.bottom, 50)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                    .overlay(
                        Group {
                            if !filteredTasks.isEmpty && scrollOffset < -50 {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 2.5)
                                            .fill(Theme.textSecondary.opacity(0.3))
                                            .frame(width: 4, height: 40)
                                            .padding(.trailing, 8)
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation.width
                            }
                            .onEnded { gesture in
                                let threshold: CGFloat = 50
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if gesture.translation.width > threshold {
                                        // Swipe right
                                        if selectedTab > 0 {
                                            selectedTab -= 1
                                        }
                                    } else if gesture.translation.width < -threshold {
                                        // Swipe left
                                        if selectedTab < TabItem.allCases.count - 1 {
                                            selectedTab += 1
                                        }
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
                }
                
                CustomTabBar(selectedTab: $selectedTab)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { 
                            withAnimation {
                                showingAddTask = true
                                HapticManager.shared.successFeedback()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(themeManager.textColor)
                                .shadow(color: Theme.primaryPastel.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80) // Position above tab bar
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        themeManager.toggleTheme()
                    }) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.textColor)
                            .shadow(color: Theme.primaryPastel.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Cloudo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.primaryPastel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { 
                            withAnimation {
                                showingDataManagement = true
                                HapticManager.shared.successFeedback()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.textColor)
                                .shadow(color: Theme.primaryPastel.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(themeManager.sheetBackgroundColor)
                    .presentationCornerRadius(16)
            }
            .sheet(isPresented: $showingCategories) {
                CategoriesView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(themeManager.sheetBackgroundColor)
                    .presentationCornerRadius(16)
            }
            .sheet(isPresented: $showingDataManagement) {
                DataManagementView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(themeManager.sheetBackgroundColor)
                    .presentationCornerRadius(16)
            }
            .onAppear {
                // Create default categories if needed
                CategoryManager.shared.createDefaultCategoriesIfNeeded(context: viewContext)
            }
        }
        .navigationViewStyle(.stack) // Forces portrait navigation style
        .toast(with: toastManager) // Apply the toast modifier
        .environmentObject(toastManager) // Provide the ToastManager to child views
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
