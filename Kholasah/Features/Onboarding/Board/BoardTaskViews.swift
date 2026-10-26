import SwiftUI

struct BoardTaskList: View {
    let tasks: [StudyTask]
    let toggle: (StudyTask) -> Void
    let details: (StudyTask) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if tasks.isEmpty {
                Text("No tasks for this day")
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 110)
            }
            ForEach(tasks) { task in
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Button { toggle(task) } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle" : "circle")
                                .font(.title3)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(task.isCompleted ? "Mark \(task.title) incomplete" : "Complete \(task.title)")
                        Button { details(task) } label: {
                            HStack(spacing: 8) {
                                Text(task.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "alarm")
                                Text(task.durationMinutes.map { "\($0) min" } ?? "— min")
                                    .font(.subheadline)
                                Image(systemName: "chevron.right")
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .accessibilityHint("Opens task details")
                    }
                    if task.id != tasks.last?.id { Divider() }
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .boardCard()
    }
}

struct BoardAddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var minutes = "25"
    @State var date: Date
    let onSave: (String, Date, Int) -> Void

    private var valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(minutes) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task name", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Duration in minutes", text: $minutes)
                    .keyboardType(.numberPad)
                PrimaryButton(title: "Save") {
                    guard valid, let duration = Int(minutes) else { return }
                    onSave(title, date, duration)
                    dismiss()
                }
                .disabled(!valid)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
        }
        .tint(AppColors.primary)
    }
}

struct BoardTaskDetailView: View {
    let viewModel: BoardViewModel
    let taskID: StudyTask.ID
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if let task = viewModel.repository.tasks.first(where: { $0.id == taskID }) {
                    LabeledContent("Name", value: task.title)
                    if let date = task.dueDate {
                        LabeledContent("Date", value: date.formatted(date: .long, time: .omitted))
                    }
                    LabeledContent("Duration", value: task.durationMinutes.map { "\($0) min" } ?? "Not set")
                    LabeledContent("Status", value: task.isCompleted ? "Completed" : "Not completed")
                    Button(task.isCompleted ? "Mark incomplete" : "Mark completed") {
                        viewModel.toggle(task)
                    }
                }
            }
            .navigationTitle("Task Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
        }
        .tint(AppColors.primary)
    }
}
