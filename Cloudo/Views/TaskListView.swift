import SwiftUI

struct TaskListView: View {
    let tasks: [Task]
    let selectedTab: Int
    
    var body: some View {
        ScrollView {
            if tasks.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    if selectedTab == 1 {
                        ContentUnavailableView(
                            "No Completed Tasks",
                            systemImage: "checkmark.circle",
                            description: Text("Tasks you complete will appear here")
                        )
                        .foregroundStyle(Theme.textSecondary)
                    } else {
                        ContentUnavailableView(
                            "No Tasks",
                            systemImage: "list.bullet.circle",
                            description: Text("Add some tasks to get started")
                        )
                        .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskRow(task: task)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
        }
        .background(Theme.backgroundPastel)
    }
}

#Preview {
    TaskListView(tasks: [], selectedTab: 0)
} 
