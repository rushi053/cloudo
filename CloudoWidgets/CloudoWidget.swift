import WidgetKit
import SwiftUI
import CoreData

// Model for task data in the widget
struct TaskViewModel: Identifiable, Codable {
    let id: UUID
    let title: String
    let priority: Int
    let completed: Bool
    let category: String
    let reminderDate: Date?
}

// Timeline entry for the widget
struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskViewModel]
}

// Timeline provider for the widget
struct CloudoWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), tasks: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        // For previews and snapshots, use sample data
        if context.isPreview {
            let entry = TaskEntry(date: Date(), tasks: getSampleTasks())
            completion(entry)
        } else {
            // For actual widgets, use real data
            let tasks = WidgetDataProvider.shared.fetchTodaysTasks()
            let entry = TaskEntry(date: Date(), tasks: tasks)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        var entries: [TaskEntry] = []
        
        let currentDate = Date()
        
        // Fetch real tasks from Core Data
        let tasks = WidgetDataProvider.shared.fetchTodaysTasks()
        
        let entry = TaskEntry(date: currentDate, tasks: tasks)
        entries.append(entry)
        
        // Update every 30 minutes or when the widget is next visible
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    // Sample tasks for preview and snapshot
    private func getSampleTasks() -> [TaskViewModel] {
        return [
            TaskViewModel(id: UUID(), title: "Complete project proposal", priority: 3, completed: false, category: "Work", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Buy groceries", priority: 2, completed: false, category: "Personal", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Call mom", priority: 1, completed: true, category: "Personal", reminderDate: Date())
        ]
    }
}

// Task row view for the widget
struct TaskRowView: View {
    var task: TaskViewModel
    
    var body: some View {
        Link(destination: URL(string: "cloudo://complete-task/\(task.id)")!) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.completed ? .green : .gray)
                
                // Task title with category pill
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 14, weight: task.priority == 3 ? .medium : .regular))
                        .lineLimit(1)
                        .strikethrough(task.completed)
                        .foregroundColor(task.completed ? .gray : .primary)
                    
                    if !task.category.isEmpty {
                        Text(task.category)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(categoryColor(for: task.category).opacity(0.15))
                            )
                            .foregroundColor(categoryColor(for: task.category))
                    }
                }
                
                Spacer()
                
                // Priority indicator
                if task.priority > 0 {
                    Circle()
                        .fill(priorityColor(for: task.priority))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func priorityColor(for priority: Int) -> Color {
        switch priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .yellow
        default: return .clear
        }
    }
    
    func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "work": return .blue
        case "personal": return .purple
        case "shopping": return .green
        case "health": return .pink
        case "cloudo": return .blue
        case "widget": return .orange
        case "tips": return .green
        default: return .gray
        }
    }
}

// Widget entry view
struct CloudoWidgetEntryView: View {
    var entry: TaskEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label {
                    Text("Today's Tasks")
                        .font(.headline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "list.bullet.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if !entry.tasks.isEmpty {
                    HStack(spacing: 4) {
                        Text("\(entry.tasks.filter { !$0.completed }.count)")
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                        Text("left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            .padding(.bottom, 4)
            
            taskList
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
    
    @ViewBuilder
    var taskList: some View {
        switch family {
        case .systemSmall:
            if let task = entry.tasks.first(where: { !$0.completed }) {
                TaskRowView(task: task)
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("All done!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        case .systemMedium:
            if !entry.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(entry.tasks.prefix(3)) { task in
                        TaskRowView(task: task)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    Text("No tasks for today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Add tasks in the app")
                        .font(.caption2)
                        .foregroundColor(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .systemLarge:
            if !entry.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(entry.tasks.prefix(7)) { task in
                        TaskRowView(task: task)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                    Text("No tasks for today")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text("Add tasks in the app to see them here")
                        .font(.caption)
                        .foregroundColor(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        @unknown default:
            Text("Unsupported widget size")
        }
    }
}

// Widget definition
struct CloudoWidget: Widget {
    let kind: String = "CloudoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CloudoWidgetProvider()) { entry in
            CloudoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("View and complete your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview provider
struct CloudoWidget_Previews: PreviewProvider {
    static var previews: some View {
        CloudoWidgetEntryView(entry: TaskEntry(date: Date(), tasks: [
            TaskViewModel(id: UUID(), title: "Complete project proposal", priority: 3, completed: false, category: "Work", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Buy groceries", priority: 2, completed: false, category: "Personal", reminderDate: Date()),
            TaskViewModel(id: UUID(), title: "Call mom", priority: 1, completed: true, category: "Personal", reminderDate: Date())
        ]))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
} 