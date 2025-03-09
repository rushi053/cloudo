import WidgetKit
import SwiftUI
import CoreData

// Model for task data in the widget
struct TaskViewModel: Identifiable {
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
            HStack {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completed ? .green : .gray)
                
                Text(task.title)
                    .lineLimit(1)
                    .strikethrough(task.completed)
                    .foregroundColor(task.completed ? .gray : .primary)
                
                Spacer()
                
                // Priority indicator
                if task.priority > 0 {
                    Circle()
                        .fill(priorityColor(for: task.priority))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    func priorityColor(for priority: Int) -> Color {
        switch priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .yellow
        default: return .clear
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
                Text("Today's Tasks")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(entry.tasks.filter { !$0.completed }.count) left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            taskList
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    @ViewBuilder
    var taskList: some View {
        switch family {
        case .systemSmall:
            if let task = entry.tasks.first(where: { !$0.completed }) {
                TaskRowView(task: task)
            } else {
                Text("All done!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .systemMedium:
            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.tasks.prefix(3)) { task in
                    TaskRowView(task: task)
                }
            }
        case .systemLarge:
            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.tasks.prefix(7)) { task in
                    TaskRowView(task: task)
                }
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