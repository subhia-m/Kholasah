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
    @State private var date: Date
    @FocusState private var focusedField: Field?
    @State private var selectedDetent: PresentationDetent = .medium
    let onSave: (String, Date, Int) -> Void

    private enum Field: Hashable {
        case name
        case duration
    }

    init(date: Date, onSave: @escaping (String, Date, Int) -> Void) {
        _date = State(initialValue: date)
        self.onSave = onSave
    }

    private var valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(minutes) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("Enter task name", text: $title)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 44)
                            .focused($focusedField, equals: .name)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                            .accessibilityLabel("Task name")
                    }
                    .padding(.vertical, 12)

                    Divider()

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .frame(minHeight: 52)
                        .padding(.vertical, 4)
                        .simultaneousGesture(TapGesture().onEnded { focusedField = nil })

                    Divider()

                    LabeledContent("Duration") {
                        HStack(spacing: 6) {
                            TextField("Minutes", text: $minutes)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .frame(minWidth: 44, maxWidth: 88, minHeight: 44)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .duration)
                                .accessibilityLabel("Duration in minutes")
                            Text("min")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minHeight: 52)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(20)
            }
            .background {
                AppColors.background
                    .ignoresSafeArea()
            }
            .onTapGesture { focusedField = nil }
            .font(AppTypography.body)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        focusedField = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard valid, let duration = Int(minutes) else { return }
                        focusedField = nil
                        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), date, duration)
                        dismiss()
                    }
                    .disabled(!valid)
                }
            }
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(AppColors.primary)
        .presentationBackground(AppColors.background)
        .presentationDetents([.medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .onChange(of: focusedField) { _, field in
            if field != nil {
                selectedDetent = .large
            }
        }
    }
}

#Preview("New Task Sheet") {
    BoardAddTaskView(date: .now) { _, _, _ in }
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
