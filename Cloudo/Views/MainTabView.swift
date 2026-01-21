//
//  MainTabView.swift
//  Cloudo
//
//  Main tab navigation with custom tab bar
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    
    @State private var selectedTab: Tab = .tasks
    @State private var showAddTask = false
    @EnvironmentObject private var appState: AppState
    
    // MARK: - Tab Definition
    
    enum Tab: Int, CaseIterable {
        case tasks = 0
        case completed = 1
        case settings = 2
        
        var title: String {
            switch self {
            case .tasks: return "Tasks"
            case .completed: return "Done"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .tasks: return "checklist"
            case .completed: return "checkmark.circle"
            case .settings: return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .tasks: return "checklist"
            case .completed: return "checkmark.circle.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                TaskListView(showCompleted: false)
                    .tag(Tab.tasks)
                
                TaskListView(showCompleted: true)
                    .tag(Tab.completed)
                
                SettingsView()
                    .tag(Tab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTask) {
            TaskFormView()
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Tasks tab
            tabButton(for: .tasks)
            
            // Add button
            addButton
            
            // Completed tab
            tabButton(for: .completed)
            
            // Settings tab
            tabButton(for: .settings)
        }
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, Design.Spacing.md)
        .padding(.bottom, Design.Spacing.xl)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            withAnimation(Design.Animation.spring) {
                selectedTab = tab
            }
            if appState.hapticsEnabled {
                HapticService.shared.selection()
            }
        }) {
            VStack(spacing: Design.Spacing.xs) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .symbolEffect(.bounce, value: selectedTab == tab)
                
                Text(tab.title)
                    .font(Design.Typography.caption2)
            }
            .foregroundStyle(selectedTab == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var addButton: some View {
        Button(action: {
            showAddTask = true
            if appState.hapticsEnabled {
                HapticService.shared.impact(.medium)
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .offset(y: -Design.Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
