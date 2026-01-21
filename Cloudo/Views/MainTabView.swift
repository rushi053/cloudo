//
//  MainTabView.swift
//  Cloudo
//
//  Custom tab bar with dark aesthetic
//

import SwiftUI

enum Tab: String, CaseIterable {
    case tasks = "Tasks"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .tasks: return "checkmark.circle"
        case .settings: return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .tasks: return "checkmark.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .tasks
    @StateObject private var haptics = HapticService()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .tasks:
                    TaskListView()
                        .environmentObject(haptics)
                case .settings:
                    SettingsView()
                        .environmentObject(haptics)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Design.Spacing.xl)
        .padding(.vertical, Design.Spacing.md)
        .background(
            Capsule()
                .fill(CloudoTheme.tabBarBackground)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 5)
        )
        .padding(.horizontal, Design.Spacing.xxl)
        .padding(.bottom, Design.Spacing.sm)
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            withAnimation(Design.Animation.snappy) {
                selectedTab = tab
                haptics.selection()
            }
        }) {
            VStack(spacing: Design.Spacing.xxs) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                
                Text(tab.rawValue)
                    .font(Design.Typography.caption2)
            }
            .foregroundColor(selectedTab == tab ? CloudoTheme.tabBarActive : CloudoTheme.tabBarInactive)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Design.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
