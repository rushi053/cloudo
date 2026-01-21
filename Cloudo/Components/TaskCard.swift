//
//  TaskCard.swift
//  Cloudo
//
//  Reusable task card component with modern design
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
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Design.Spacing.md) {
                // Completion checkbox
                completionButton
                
                // Task content
                VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                    // Title row
                    HStack(spacing: Design.Spacing.sm) {
                        Text(task.title ?? "Untitled")
                            .font(Design.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Priority indicator
                        if task.priorityValue != .none {
                            priorityBadge
                        }
                    }
                    
                    // Metadata row
                    HStack(spacing: Design.Spacing.sm) {
                        // Category
                        if let category = task.category {
                            categoryPill(category)
                        }
                        
                        // Due date
                        if let dueDate = task.shortDueDate {
                            dueDatePill(dueDate)
                        }
                        
                        // Recurring indicator
                        if task.isRecurring {
                            recurringIndicator
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(Design.Spacing.md)
            .background(cardBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .pressable(isPressed: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Subviews
    
    private var completionButton: some View {
        Button(action: handleCompletion) {
            ZStack {
                Circle()
                    .stroke(
                        task.isCompleted ? Color.green : task.priorityValue.fallbackColor,
                        lineWidth: 2
                    )
                    .frame(width: 26, height: 26)
                
                if task.isCompleted || showCompletionAnimation {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(showCompletionAnimation ? 1.0 : 0.5)
                }
            }
            .animation(Design.Animation.bouncy, value: showCompletionAnimation)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priorityBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: task.priorityValue.icon)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(task.priorityValue.fallbackColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(task.priorityValue.fallbackColor.opacity(0.15))
        )
    }
    
    private func categoryPill(_ category: Category) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            
            Text(category.name ?? "")
                .font(Design.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
    
    private func dueDatePill(_ date: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: task.isOverdue ? "exclamationmark.circle.fill" : "clock")
                .font(.system(size: 10))
            
            Text(date)
                .font(Design.Typography.caption)
        }
        .foregroundColor(task.isOverdue ? .red : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(task.isOverdue ? Color.red.opacity(0.1) : Color(.systemGray6))
        )
    }
    
    private var recurringIndicator: some View {
        Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.blue)
            .padding(4)
            .background(
                Circle()
                    .fill(Color.blue.opacity(0.1))
            )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(
                color: task.isOverdue ? Color.red.opacity(0.1) : Design.Shadow.sm.color,
                radius: Design.Shadow.sm.radius,
                y: Design.Shadow.sm.y
            )
            .overlay(
                // Priority accent on left edge
                HStack {
                    if task.priorityValue != .none {
                        Rectangle()
                            .fill(task.priorityValue.fallbackColor)
                            .frame(width: 3)
                    }
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.lg, style: .continuous))
            )
    }
    
    // MARK: - Actions
    
    private func handleCompletion() {
        if appState.hapticsEnabled {
            HapticService.shared.success()
        }
        
        withAnimation(Design.Animation.bouncy) {
            showCompletionAnimation = true
        }
        
        // Delay the actual completion to show animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(Design.Animation.standard) {
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

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context)
    task.title = "Review project proposal"
    task.taskDescription = "Check the Q4 budget"
    task.priority = Priority.high.rawValue
    task.reminderDate = Date()
    
    return TaskCard(task: task, onTap: {}, onComplete: {})
        .padding()
        .background(Color(.systemGroupedBackground))
        .environmentObject(AppState())
}
