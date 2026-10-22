import SwiftUI

struct TasksView: View {
    let viewModel: PlanViewModel
    @State private var newTaskTitle = ""

    var body: some View {
        List {
            Section("New Task") {
                HStack {
                    TextField("Task title", text: $newTaskTitle)
                    Button("Add") {
                        viewModel.addTask(title: newTaskTitle, courseID: nil)
                        newTaskTitle = ""
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section("Tasks") {
                if viewModel.tasks.isEmpty {
                    Text("No tasks yet.")
                        .foregroundStyle(AppColors.secondaryText)
                } else {
                    ForEach(viewModel.tasks) { task in
                        TaskCard(
                            title: task.title,
                            isCompleted: task.isCompleted
                        ) {
                            viewModel.toggleTask(task)
                        }
                    }
                }
            }
        }
        .navigationTitle("Tasks")
    }
}
