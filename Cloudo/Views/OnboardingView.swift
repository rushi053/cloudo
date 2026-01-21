//
//  OnboardingView.swift
//  Cloudo
//
//  First-time user onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "checklist",
            title: "Welcome to Cloudo",
            subtitle: "Your simple, beautiful task manager",
            description: "Stay organized and get things done with ease.",
            color: .blue
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy First",
            subtitle: "Your data stays on your device",
            description: "No accounts, no cloud sync, no tracking. Your tasks are yours alone.",
            color: .green
        ),
        OnboardingPage(
            icon: "bell.fill",
            title: "Smart Reminders",
            subtitle: "Never miss a task",
            description: "Set reminders and recurring tasks to stay on top of your to-dos.",
            color: .orange
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(Design.Animation.smooth, value: currentPage)
                
                // Bottom section
                bottomSection
            }
        }
        .onAppear {
            withAnimation(Design.Animation.smooth.delay(0.3)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                pages[currentPage].color.opacity(0.1),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
        .animation(Design.Animation.smooth, value: currentPage)
    }
    
    // MARK: - Page View
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: Design.Spacing.xxl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(page.color)
                    .symbolEffect(.bounce, value: currentPage)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            // Text content
            VStack(spacing: Design.Spacing.md) {
                Text(page.title)
                    .font(Design.Typography.largeTitle)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(Design.Typography.title3)
                    .foregroundStyle(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(Design.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Design.Spacing.xxl)
            }
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: Design.Spacing.xl) {
            // Page indicators
            HStack(spacing: Design.Spacing.sm) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? pages[currentPage].color : Color(.systemGray4))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(Design.Animation.spring, value: currentPage)
                }
            }
            
            // Buttons
            HStack(spacing: Design.Spacing.md) {
                if currentPage > 0 {
                    Button(action: previousPage) {
                        Text("Back")
                            .font(Design.Typography.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Design.Spacing.md)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: nextPage) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(Design.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Design.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .fill(pages[currentPage].color)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, Design.Spacing.xl)
        }
        .padding(.bottom, Design.Spacing.xxxl)
    }
    
    // MARK: - Actions
    
    private func nextPage() {
        if appState.hapticsEnabled {
            HapticService.shared.impact(.light)
        }
        
        if currentPage < pages.count - 1 {
            withAnimation(Design.Animation.spring) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func previousPage() {
        if appState.hapticsEnabled {
            HapticService.shared.impact(.light)
        }
        
        withAnimation(Design.Animation.spring) {
            currentPage -= 1
        }
    }
    
    private func completeOnboarding() {
        // Create default categories
        Category.createDefaultsIfNeeded(in: viewContext)
        
        // Request notification permissions
        NotificationService.shared.requestAuthorization { granted in
            appState.notificationsEnabled = granted
        }
        
        // Mark onboarding as complete
        withAnimation(Design.Animation.smooth) {
            appState.hasCompletedOnboarding = true
        }
        
        if appState.hapticsEnabled {
            HapticService.shared.success()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
