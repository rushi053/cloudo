//
//  OnboardingView.swift
//  Cloudo
//
//  Playful onboarding with colorful geometric shapes
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateShapes = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to\nCloudo",
            subtitle: "Your beautiful task manager",
            shapes: [
                ShapeData(type: .circle, color: CloudoTheme.royalBlue, size: 120, offset: CGPoint(x: -60, y: -80)),
                ShapeData(type: .triangle, color: CloudoTheme.lime, size: 80, offset: CGPoint(x: 70, y: -40), rotation: 15),
                ShapeData(type: .cloud, color: CloudoTheme.purple, size: 60, offset: CGPoint(x: -50, y: 60)),
                ShapeData(type: .rectangle, color: CloudoTheme.salmon, size: 50, offset: CGPoint(x: 80, y: 80), rotation: -15)
            ]
        ),
        OnboardingPage(
            title: "Organize with\nstyle",
            subtitle: "Colorful cards make tasks fun",
            shapes: [
                ShapeData(type: .rectangle, color: CloudoTheme.purple, size: 100, offset: CGPoint(x: -70, y: -60), rotation: 10),
                ShapeData(type: .circle, color: CloudoTheme.salmon, size: 70, offset: CGPoint(x: 80, y: -30)),
                ShapeData(type: .triangle, color: CloudoTheme.royalBlue, size: 60, offset: CGPoint(x: -20, y: 80), rotation: -20),
                ShapeData(type: .cloud, color: CloudoTheme.lime, size: 50, offset: CGPoint(x: 60, y: 70))
            ]
        ),
        OnboardingPage(
            title: "Never miss\na deadline",
            subtitle: "Smart reminders keep you on track",
            shapes: [
                ShapeData(type: .cloud, color: CloudoTheme.royalBlue, size: 90, offset: CGPoint(x: -80, y: -50)),
                ShapeData(type: .rectangle, color: CloudoTheme.lime, size: 70, offset: CGPoint(x: 60, y: -70), rotation: 25),
                ShapeData(type: .circle, color: CloudoTheme.purple, size: 80, offset: CGPoint(x: 70, y: 50)),
                ShapeData(type: .triangle, color: CloudoTheme.salmon, size: 55, offset: CGPoint(x: -60, y: 80), rotation: -10)
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            CloudoTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(for: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom section
                VStack(spacing: Design.Spacing.xl) {
                    // Page indicators
                    HStack(spacing: Design.Spacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? CloudoTheme.jetBlack : CloudoTheme.jetBlack.opacity(0.2))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(Design.Animation.smooth, value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(Design.Animation.smooth) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(Design.Animation.smooth) {
                                hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(Design.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Design.Spacing.md)
                            .background(CloudoTheme.jetBlack)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation(Design.Animation.smooth) {
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text("Skip")
                                .font(Design.Typography.bodyMedium)
                                .foregroundColor(CloudoTheme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, Design.Spacing.xl)
                .padding(.bottom, Design.Spacing.xxxl)
            }
        }
        .onAppear {
            withAnimation(Design.Animation.smooth.delay(0.3)) {
                animateShapes = true
            }
        }
    }
    
    // MARK: - Page View
    
    private func pageView(for page: OnboardingPage) -> some View {
        VStack(spacing: Design.Spacing.xxl) {
            Spacer()
            
            // Shapes area
            ZStack {
                ForEach(Array(page.shapes.enumerated()), id: \.offset) { index, shape in
                    shapeView(for: shape)
                        .opacity(animateShapes ? 1 : 0)
                        .offset(
                            x: animateShapes ? shape.offset.x : shape.offset.x * 0.5,
                            y: animateShapes ? shape.offset.y : shape.offset.y * 0.5
                        )
                        .animation(
                            Design.Animation.bouncy.delay(Double(index) * 0.1),
                            value: animateShapes
                        )
                }
            }
            .frame(height: 250)
            
            // Text content
            VStack(spacing: Design.Spacing.md) {
                Text(page.title)
                    .font(Design.Typography.largeTitle)
                    .foregroundColor(CloudoTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(Design.Typography.body)
                    .foregroundColor(CloudoTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Design.Spacing.xl)
            
            Spacer()
            Spacer()
        }
    }
    
    @ViewBuilder
    private func shapeView(for shape: ShapeData) -> some View {
        Group {
            switch shape.type {
            case .circle:
                Circle()
                    .fill(shape.color)
            case .triangle:
                Triangle()
                    .fill(shape.color)
            case .rectangle:
                RoundedRectangle(cornerRadius: Design.Radius.sm)
                    .fill(shape.color)
            case .cloud:
                CloudShape()
                    .fill(shape.color)
            }
        }
        .frame(width: shape.size, height: shape.size)
        .rotationEffect(.degrees(shape.rotation))
    }
}

// MARK: - Data Models

struct OnboardingPage {
    let title: String
    let subtitle: String
    let shapes: [ShapeData]
}

struct ShapeData {
    enum ShapeType {
        case circle, triangle, rectangle, cloud
    }
    
    let type: ShapeType
    let color: Color
    let size: CGFloat
    let offset: CGPoint
    var rotation: Double = 0
}

// MARK: - Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Design.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
