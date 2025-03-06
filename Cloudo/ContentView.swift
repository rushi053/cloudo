//
//  ContentView.swift
//  DailyTasks
//
//  Created by Rushiraj Jadeja on 04/03/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAddTask = false
    @State private var selectedTab = 0
    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            if selectedTab == 0 {
                return !task.completed
            } else if selectedTab == 1 {
                return task.completed
            }
            return true
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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab Title
                    HStack {
                        Text(currentTabTitle)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.textColor)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        Spacer()
                    }
                    
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
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTasks) { task in
                                    TaskRow(task: task)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding()
                            
                        }
                    }
                    .padding(.bottom,50)
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
                    Button(action: { 
                        withAnimation {
                            showingAddTask = true
                            HapticManager.shared.mediumTapFeedback()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.textColor)
                            .shadow(color: Theme.primaryPastel.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationViewStyle(.stack) // Forces portrait navigation style
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
