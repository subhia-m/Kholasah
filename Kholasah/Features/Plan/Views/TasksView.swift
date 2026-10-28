// MARK:
import SwiftUI

// MARK: - Legacy type
struct PlanTaskItem: Identifiable, Equatable {
   
    var id = UUID()
    var title: String
    var isDone: Bool = false
    var dueDate: Date?
    var durationMinutes: Int?
    var concept: String?
    var explanation: String?
    var keyPoints: [String] = []
    var reviewPrompt: String?
    var reminderMessage: String?
}

// MARK: - Tasks page

struct TasksView: View {

    var courseTitle: String = "Plan"
    @Binding var selection: PlanScreenTab
    var onBack: (() -> Void)? = nil
    var tasks: [StudyTask]
    var onAdd: (String) -> Void
    var onToggle: (StudyTask) -> Void
    var onRename: (StudyTask, String) -> Void          // NEW
    var onDelete: (StudyTask) -> Void                   // NEW

    @State private var showingAddSheet = false
   
    @State private var editingTask: StudyTask?

  
    private var doneCount: Int { tasks.filter(\.isCompleted).count }

    var body: some View {
        PlanPageScaffold(title: courseTitle, selection: $selection, onBack: onBack) {
            content
        }
    }

    private var content: some View {
        
        VStack(spacing: 0) {
           
            PlanCard {
                
                HStack {
                    Spacer()
                    PlanAddButton(label: "Add task") { showingAddSheet = true }
                }
                
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 17)

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
            .padding(.top, 16)
        }
    // NEW: the add sheet uses the shared editor sheet
        .sheet(isPresented: $showingAddSheet) {
            PlanTaskEditorSheet(heading: "New Task", buttonTitle: "Add") { title in
                withAnimation { onAdd(title) }
            }
            .presentationDetents([.height(230)])
            .presentationDragIndicator(.visible)
        }
        // NEW: the edit sheet, opened with the task's current title filled in
        .sheet(item: $editingTask) { task in
            PlanTaskEditorSheet(heading: "Edit Task",
                                buttonTitle: "Save",
                                initialText: task.title) { title in
                withAnimation { onRename(task, title) }
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
            
            ForEach(tasks) { task in
                PlanTaskRow(task: task) {
                    withAnimation(.easeInOut(duration: 0.2)) { onToggle(task) }
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                // NEW: swipe left on a task to delete or edit it
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    
                    Button(role: .destructive) {
                        withAnimation { onDelete(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        editingTask = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(PlanTheme.mauve)
                }
                // NEW: or press and hold
                .contextMenu {
                    Button {
                        editingTask = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        withAnimation { onDelete(task) }
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
   
    let task: StudyTask
   
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(PlanTheme.deepClay)
            }
            .buttonStyle(.plain)
            
            .accessibilityLabel(task.isCompleted ? "Mark as not completed" : "Mark as completed")

            NavigationLink {
                TaskDetailView(task: task)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16))
                        .strikethrough(task.isCompleted)

                    HStack(spacing: 8) {
                        
                        if let dueDate = task.dueDate {
                            Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        }
                        if let durationMinutes = task.durationMinutes {
                            Text("\(durationMinutes) min")
                        }
                    }
                    .font(.caption)
                    .opacity(0.65)
                }
                .foregroundStyle(PlanTheme.text.opacity(task.isCompleted ? 0.45 : 1))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens task details")
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Add / edit sheet (NEW: one sheet used for both adding and editing)

private struct PlanTaskEditorSheet: View {
   
    let heading: String
    
    let buttonTitle: String
   
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
   
    @State private var title: String
    
    @FocusState private var isFocused: Bool

    init(heading: String,
         buttonTitle: String,
         initialText: String = "",
         onSave: @escaping (String) -> Void) {
        self.heading = heading
        self.buttonTitle = buttonTitle
        self.onSave = onSave
        _title = State(initialValue: initialText)
    }

    
    private var trimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(heading)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            
            TextField("What do you need to do?", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(save)
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

                Button(buttonTitle, action: save)
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

    private func save() {
        
        guard !trimmed.isEmpty else { return }
        onSave(trimmed)
        dismiss()
    }
}


#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    NavigationStack {
        CourseFlowView(course: Course(title: "Plan"), showsBackButton: true, startingAt: .tasks)
    }
}
