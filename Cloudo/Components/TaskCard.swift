//
//  TaskCard.swift
//  Cloudo
//
//  Beautiful, modern task card with delightful interactions
//

import SwiftUI

struct TaskCard: View {
    
    // MARK: - Properties
    
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState: AppState
    
    let onTap: () -> Void
    let onComplete: () -> Void
    
    @State private var isPressed = false
    @State private var showCompletionAnimation = false
    @State private var checkScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Design.Spacing.md) {
                // Completion checkbox
                completionButton
                
                // Task content
                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                    // Title
                    Text(task.title ?? "Untitled")
                        .font(Design.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .lineLimit(2)
                    
                    // Metadata row
                    HStack(spacing: Design.Spacing.sm) {
                        // Category
                        if let category = task.category {
                            CategoryChip(category: category, isCompact: true)
                        }
                        
                        // Due date
                        if let dueDate = task.shortDueDate {
                            DueDateChip(
                                date: dueDate,
                                isOverdue: task.isOverdue,
                                isRecurring: task.isRecurring
                            )
                        }
                        
                        Spacer()
                    }
                }
                
                // Priority indicator
                if task.priorityValue != .none {
                    priorityIndicator
                }
            }
            .padding(Design.Spacing.lg)
            .background(cardBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(TaskCardButtonStyle())
    }
    
    // MARK: - Completion Button
    
    private var completionButton: some View {
        Button(action: handleCompletion) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        task.isCompleted 
                            ? CloudoTheme.mint 
                            : priorityColor.opacity(0.4),
                        lineWidth: 2.5
                    )
                    .frame(width: 28, height: 28)
                
                // Filled state
                if task.isCompleted || showCompletionAnimation {
                    Circle()
                        .fill(CloudoTheme.mintGradient)
                        .frame(width: 28, height: 28)
                        .scaleEffect(checkScale)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(checkScale)
                }
            }
            .animation(Design.Animation.bouncy, value: showCompletionAnimation)
            .animation(Design.Animation.bouncy, value: checkScale)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Priority Indicator
    
    private var priorityIndicator: some View {
        VStack(spacing: 2) {
            Image(systemName: task.priorityValue.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(priorityColor)
            
            if task.priorityValue == .high {
                // Pulsing dot for high priority
                Circle()
                    .fill(CloudoTheme.coral)
                    .frame(width: 4, height: 4)
                    .modifier(PulseModifier())
            }
        }
        .frame(width: 28)
    }
    
    // MARK: - Card Background
    
    private var cardBackground: some View {
        ZStack(alignment: .leading) {
            // Main background
            RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous)
                .fill(CloudoTheme.cardBackground)
            
            // Priority accent bar
            if task.priorityValue != .none && !task.isCompleted {
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(priorityGradient)
                        .frame(width: 4)
                        .padding(.vertical, Design.Spacing.sm)
                    Spacer()
                }
            }
        }
        .shadow(color: shadowColor, radius: 10, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    
    private var priorityColor: Color {
        switch task.priorityValue {
        case .none: return .secondary
        case .low: return CloudoTheme.priorityLow
        case .medium: return CloudoTheme.priorityMedium
        case .high: return CloudoTheme.priorityHigh
        }
    }
    
    private var priorityGradient: LinearGradient {
        switch task.priorityValue {
        case .none: return LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
        case .low: return CloudoTheme.mintGradient
        case .medium: return CloudoTheme.sunshineGradient
        case .high: return CloudoTheme.coralGradient
        }
    }
    
    private var shadowColor: Color {
        if task.isOverdue {
            return CloudoTheme.coral.opacity(0.15)
        } else if task.priorityValue == .high && !task.isCompleted {
            return CloudoTheme.coral.opacity(0.1)
        }
        return Color.black.opacity(0.06)
    }
    
    // MARK: - Actions
    
    private func handleCompletion() {
        if appState.hapticsEnabled {
            HapticService.shared.success()
        }
        
        // Animate
        withAnimation(Design.Animation.bouncy) {
            showCompletionAnimation = true
            checkScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Design.Animation.bouncy) {
                checkScale = 1.0
            }
        }
        
        // Delay the actual completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(Design.Animation.smooth) {
                if task.isRecurring && !task.isCompleted {
                    NotificationService.shared.handleTaskCompletion(
                        task: task,
                        context: viewContext
                    )
                } else {
                    task.toggleCompletion()
                    
                    if task.isCompleted {
                        NotificationService.shared.cancelNotification(for: task)
                    } else if task.reminderDate != nil {
                        NotificationService.shared.scheduleNotification(for: task)
                    }
                    
                    try? viewContext.save()
                }
                
                showCompletionAnimation = false
                onComplete()
            }
        }
    }
}

// MARK: - Task Card Button Style

struct TaskCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Design.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: Category
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: Design.Spacing.xs) {
            Circle()
                .fill(category.color)
                .frame(width: isCompact ? 8 : 10, height: isCompact ? 8 : 10)
            
            Text(category.name ?? "")
                .font(isCompact ? Design.Typography.caption : Design.Typography.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Design.Spacing.sm)
        .padding(.vertical, Design.Spacing.xs)
        .background(
            Capsule()
                .fill(category.color.opacity(0.12))
        )
    }
}

// MARK: - Due Date Chip

struct DueDateChip: View {
    let date: String
    let isOverdue: Bool
    let isRecurring: Bool
    
    var body: some View {
        HStack(spacing: Design.Spacing.xs) {
            Image(systemName: isRecurring ? "arrow.trianglehead.2.counterclockwise.rotate.90" : "clock")
                .font(.system(size: 10, weight: .semibold))
            
            Text(date)
                .font(Design.Typography.caption)
        }
        .foregroundColor(isOverdue ? .white : (isRecurring ? CloudoTheme.primary : .secondary))
        .padding(.horizontal, Design.Spacing.sm)
        .padding(.vertical, Design.Spacing.xs)
        .background(
            Capsule()
                .fill(isOverdue ? CloudoTheme.coral : (isRecurring ? CloudoTheme.primary.opacity(0.12) : Color(.systemGray6)))
        )
    }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.5 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.title = "Review project proposal"
    task.taskDescription = "Check the Q4 budget"
    task.priority = Priority.high.rawValue
    task.reminderDate = Date()
    
    let category = Category(context: context)
    category.name = "Work"
    category.colorHex = "#FF6B6B"
    task.category = category
    
    return VStack(spacing: 16) {
        TaskCard(task: task, onTap: {}, onComplete: {})
        
        TaskCard(task: {
            let t = Task(context: context)
            t.title = "Buy groceries"
            t.priority = Priority.low.rawValue
            return t
        }(), onTap: {}, onComplete: {})
    }
    .padding()
    .background(CloudoTheme.background)
    .environmentObject(AppState())
}
