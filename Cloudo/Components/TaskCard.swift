//
//  TaskCard.swift
//  Cloudo
//
//  Large colorful task card inspired by Behance mockups
//

import SwiftUI
import CoreData

struct TaskCard: View {
    let task: Task
    let cardColor: Color
    let onToggle: () -> Void
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private var textColor: Color {
        cardColor.isLight ? CloudoTheme.textOnColor : .white
    }
    
    private var secondaryTextColor: Color {
        cardColor.isLight ? CloudoTheme.textSecondary : .white.opacity(0.8)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                // Top row: Category & completion status
                HStack {
                    if let category = task.category, let name = category.name {
                        Text(name)
                            .font(Design.Typography.caption)
                            .foregroundColor(secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    // Completion checkbox
                    Button(action: onToggle) {
                        ZStack {
                            Circle()
                                .stroke(textColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 28, height: 28)
                            
                            if task.isCompleted {
                                Circle()
                                    .fill(textColor)
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(cardColor)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer(minLength: Design.Spacing.sm)
                
                // Task title - Large and bold
                Text(task.title ?? "Untitled")
                    .font(Design.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                    .strikethrough(task.isCompleted, color: textColor.opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Task notes preview
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(Design.Typography.subheadline)
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: Design.Spacing.xs)
                
                // Bottom row: Date/time info & action button
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Design.Spacing.xxs) {
                        // Due date pill
                        if let dueDate = task.reminderDate {
                            HStack(spacing: Design.Spacing.xs) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text(formatDate(dueDate))
                                    .font(Design.Typography.caption)
                            }
                            .padding(.horizontal, Design.Spacing.sm)
                            .padding(.vertical, Design.Spacing.xxs)
                            .background(
                                Capsule()
                                    .stroke(textColor.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(textColor)
                        }
                        
                        // Priority pill
                        if let priorityString = task.priority,
                           let priority = Priority(rawValue: priorityString),
                           priority != .medium {
                            HStack(spacing: Design.Spacing.xxs) {
                                Circle()
                                    .fill(priorityColor(priority))
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                                    .font(Design.Typography.caption)
                            }
                            .padding(.horizontal, Design.Spacing.sm)
                            .padding(.vertical, Design.Spacing.xxs)
                            .background(
                                Capsule()
                                    .stroke(textColor.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(textColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Arrow button
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(cardColor)
                        .circleButtonStyle(size: 40)
                }
            }
            .padding(Design.Spacing.lg)
            .frame(minHeight: 160)
            .largeCardStyle(color: cardColor)
        }
        .buttonStyle(CardButtonStyle())
        .opacity(task.isCompleted ? 0.7 : 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Tomorrow, \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low: return CloudoTheme.lime
        case .medium: return CloudoTheme.peach
        case .high: return CloudoTheme.salmon
        }
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Design.Animation.snappy, value: configuration.isPressed)
    }
}

// MARK: - Compact Task Card (for completed tasks section)

struct CompactTaskCard: View {
    let task: Task
    let cardColor: Color
    let onToggle: () -> Void
    let onTap: () -> Void
    
    private var textColor: Color {
        cardColor.isLight ? CloudoTheme.textOnColor : .white
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Design.Spacing.md) {
                // Completion checkbox
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(textColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if task.isCompleted {
                            Circle()
                                .fill(textColor)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(cardColor)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Task title
                Text(task.title ?? "Untitled")
                    .font(Design.Typography.bodyMedium)
                    .foregroundColor(textColor)
                    .strikethrough(task.isCompleted, color: textColor.opacity(0.5))
                    .lineLimit(1)
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor.opacity(0.5))
            }
            .padding(Design.Spacing.md)
            .largeCardStyle(color: cardColor.opacity(0.6), cornerRadius: Design.Radius.md)
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Add Task Card (Floating action)

struct AddTaskCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                Text("Add new task")
                    .font(Design.Typography.headline)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(Design.Spacing.lg)
            .largeCardStyle(color: CloudoTheme.jetBlack)
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Design.Spacing.md) {
        TaskCard(
            task: PreviewData.sampleTask,
            cardColor: CloudoTheme.purple,
            onToggle: {},
            onTap: {}
        )
        
        CompactTaskCard(
            task: PreviewData.sampleTask,
            cardColor: CloudoTheme.lime,
            onToggle: {},
            onTap: {}
        )
        
        AddTaskCard(action: {})
    }
    .padding()
    .background(CloudoTheme.smokyWhite)
}

// MARK: - Preview Data

enum PreviewData {
    static var sampleTask: Task {
        let context = PersistenceController.preview.container.viewContext
        let task = Task(context: context)
        task.id = UUID()
        task.title = "Design new app interface"
        task.notes = "Create colorful cards with bold typography"
        task.priority = Priority.high.rawValue
        task.isCompleted = false
        task.createdAt = Date()
        task.reminderDate = Date().addingTimeInterval(3600)
        return task
    }
}
