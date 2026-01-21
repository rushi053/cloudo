//
//  MainTabView.swift
//  Cloudo
//
//  Modern tab navigation with beautiful floating action button
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Properties
    
    @State private var selectedTab: Tab = .tasks
    @State private var showAddTask = false
    @State private var addButtonRotation: Double = 0
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
            case .tasks: return "list.bullet.rectangle"
            case .completed: return "checkmark.circle"
            case .settings: return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .tasks: return "list.bullet.rectangle.fill"
            case .completed: return "checkmark.circle.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            CloudoTheme.background
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Tab content
                TabView(selection: $selectedTab) {
                    TaskListView(showCompleted: false)
                        .tag(Tab.tasks)
                    
                    TaskListView(showCompleted: true)
                        .tag(Tab.completed)
                    
                    SettingsView()
                        .tag(Tab.settings)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // Custom Tab Bar overlay
            VStack {
                Spacer()
                customTabBar
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingAddButton
                        .padding(.trailing, Design.Spacing.xl)
                        .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTask) {
            TaskFormView()
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, Design.Spacing.md)
        .padding(.bottom, Design.Spacing.xxl)
        .background(
            CloudoTheme.cardBackground
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: -5)
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
                ZStack {
                    // Background pill for selected state
                    if selectedTab == tab {
                        Capsule()
                            .fill(CloudoTheme.primary.opacity(0.15))
                            .frame(width: 56, height: 32)
                    }
                    
                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(selectedTab == tab ? CloudoTheme.primary : .secondary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                .frame(height: 32)
                
                Text(tab.title)
                    .font(Design.Typography.caption2)
                    .foregroundColor(selectedTab == tab ? CloudoTheme.primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button(action: {
            withAnimation(Design.Animation.bouncy) {
                addButtonRotation += 90
            }
            showAddTask = true
            if appState.hapticsEnabled {
                HapticService.shared.impact(.medium)
            }
        }) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(CloudoTheme.primaryGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: CloudoTheme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                
                // Icon
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(addButtonRotation))
            }
        }
        .buttonStyle(FABButtonStyle())
    }
}

// MARK: - FAB Button Style

struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(Design.Animation.snappy, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppState())
}
