//
//  OnboardingView.swift
//  Cloudo
//
//  Beautiful onboarding experience
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
            icon: "checkmark.circle.fill",
            title: "Welcome to\nCloudo",
            subtitle: "Your tasks, beautifully organized",
            description: "Stay productive and never miss a deadline.",
            gradient: CloudoTheme.primaryGradient
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy\nFirst",
            subtitle: "Your data stays on your device",
            description: "No accounts, no cloud sync, no tracking.\nYour tasks are yours alone.",
            gradient: CloudoTheme.mintGradient
        ),
        OnboardingPage(
            icon: "bell.fill",
            title: "Smart\nReminders",
            subtitle: "Never miss a task",
            description: "Set reminders and recurring tasks\nto stay on top of your to-dos.",
            gradient: CloudoTheme.coralGradient
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Animated background
            backgroundView
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: completeOnboarding) {
                            Text("Skip")
                                .font(Design.Typography.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.xl)
                .padding(.top, Design.Spacing.lg)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom section
                bottomSection
            }
        }
        .onAppear {
            withAnimation(Design.Animation.smooth.delay(0.2)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        ZStack {
            CloudoTheme.background
                .ignoresSafeArea()
            
            // Gradient orbs
            GeometryReader { geometry in
                Circle()
                    .fill(CloudoTheme.primary.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: -100 + CGFloat(currentPage) * 50,
                        y: -50
                    )
                
                Circle()
                    .fill(CloudoTheme.coral.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(
                        x: geometry.size.width - 100 - CGFloat(currentPage) * 30,
                        y: geometry.size.height * 0.4
                    )
                
                Circle()
                    .fill(CloudoTheme.mint.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: 50 + CGFloat(currentPage) * 40,
                        y: geometry.size.height * 0.7
                    )
            }
            .animation(Design.Animation.smooth, value: currentPage)
        }
    }
    
    // MARK: - Page View
    
    private func pageView(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: Design.Spacing.xxl) {
            Spacer()
            
            // Icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(page.gradient)
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(0.5)
                
                // Main circle
                Circle()
                    .fill(page.gradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating && currentPage == index ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            // Text content
            VStack(spacing: Design.Spacing.lg) {
                Text(page.title)
                    .font(Design.Typography.largeTitle)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Text(page.subtitle)
                    .font(Design.Typography.title3)
                    .foregroundColor(CloudoTheme.primary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(Design.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, Design.Spacing.xl)
            .offset(y: isAnimating ? 0 : 30)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: Design.Spacing.xxl) {
            // Page indicators
            HStack(spacing: Design.Spacing.sm) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? CloudoTheme.primary : Color(.systemGray4))
                        .frame(width: index == currentPage ? 28 : 8, height: 8)
                }
            }
            .animation(Design.Animation.spring, value: currentPage)
            
            // Button
            Button(action: nextPage) {
                HStack(spacing: Design.Spacing.sm) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(Design.Typography.headline)
                    
                    Image(systemName: currentPage == pages.count - 1 ? "arrow.right" : "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Design.Spacing.lg)
                .background(CloudoTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                .shadow(color: CloudoTheme.primary.opacity(0.4), radius: 16, x: 0, y: 8)
            }
            .padding(.horizontal, Design.Spacing.xl)
        }
        .padding(.bottom, Design.Spacing.huge)
    }
    
    // MARK: - Actions
    
    private func nextPage() {
        if appState.hapticsEnabled {
            HapticService.shared.impact(.medium)
        }
        
        if currentPage < pages.count - 1 {
            withAnimation(Design.Animation.spring) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        // Create default categories
        Category.createDefaultsIfNeeded(in: viewContext)
        
        // Request notification permissions
        NotificationService.shared.requestAuthorization { granted in
            appState.notificationsEnabled = granted
        }
        
        // Complete onboarding with animation
        if appState.hapticsEnabled {
            HapticService.shared.success()
        }
        
        withAnimation(Design.Animation.smooth) {
            appState.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let gradient: LinearGradient
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
