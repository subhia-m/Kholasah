import SwiftUI

// MARK: - Model (kept in this file so it can't clash with shared models)

struct PlanTaskItem: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
}

// MARK: - Tasks tab

struct TasksView: View {
    @Binding var tasks: [PlanTaskItem]
    @State private var showingAddSheet = false

    private var doneCount: Int { tasks.filter(\.isDone).count }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                PlanAddButton(label: "Add task") { showingAddSheet = true }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 12)

            PlanCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 22))
                        if !tasks.isEmpty {
                            Text("\(doneCount) of \(tasks.count) done")
                                .font(.system(size: 13))
                                .opacity(0.7)
                        }
                    }
                    .foregroundStyle(PlanTheme.text)
                    .padding(.horizontal, 18)
                    .padding(.top, 16)

                    if tasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showingAddSheet) {
            PlanAddTaskSheet { title in
                withAnimation { tasks.append(PlanTaskItem(title: title)) }
            }
            .presentationDetents([.height(230)])
            .presentationDragIndicator(.visible)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No tasks yet")
                .font(.system(size: 16, weight: .medium))
            Text("Tap + to add your first task.")
                .font(.system(size: 13))
                .opacity(0.6)
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        .frame(maxWidth: .infinity)
    }

    private var taskList: some View {
        List {
            ForEach($tasks) { $task in
                PlanTaskRow(task: $task)
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { tasks.removeAll { $0.id == task.id } }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Row

private struct PlanTaskRow: View {
    @Binding var task: PlanTaskItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { task.isDone.toggle() }
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(PlanTheme.deepClay)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Mark as not done" : "Mark as done")

            Text(task.title)
                .font(.system(size: 16))
                .strikethrough(task.isDone)
                .foregroundStyle(PlanTheme.text.opacity(task.isDone ? 0.45 : 1))

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Add sheet

private struct PlanAddTaskSheet: View {
    let onAdd: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @FocusState private var isFocused: Bool

    private var trimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Task")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            TextField("What do you need to do?", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(add)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add", action: add)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.deepClay))
                    .opacity(trimmed.isEmpty ? 0.4 : 1)
                    .disabled(trimmed.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(PlanTheme.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }

    private func add() {
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
        dismiss()
    }
}

#Preview {
    ZStack {
        PlanTheme.background.ignoresSafeArea()
        TasksView(tasks: .constant([
            PlanTaskItem(title: "Read chapter 1"),
            PlanTaskItem(title: "Build a SwiftUI button", isDone: true)
        ]))
    }
}
