//
//  CourseFlowView.swift
//  Kholasah
//
//  Created by subhia  on 26/10/2026.
//
import SwiftUI

/// Decides which page is showing (Overview, Plan, Tasks, Reminders) and gives
/// every page the same data. Each page lives in its own file.
///
/// - With a `viewModel`, tasks come from PlanViewModel (shared with the rest of the app).
/// - Without one (previews, or CoursesView not given one yet), tasks are kept locally
///   and are lost when you leave the screen.
/// - With a `course`, only that course's tasks are shown and new tasks belong to it.
///   Without one (the Plan tab), all tasks are shown.
struct CourseFlowView: View {
    var course: Course?
    var viewModel: PlanViewModel?
    var showsBackButton: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var selection: PlanScreenTab
    @State private var localTasks: [StudyTask] = []

    init(course: Course? = nil,
         viewModel: PlanViewModel? = nil,
         showsBackButton: Bool = false,
         startingAt: PlanScreenTab = .overview) {
        self.course = course
        self.viewModel = viewModel
        self.showsBackButton = showsBackButton
        _selection = State(initialValue: startingAt)
    }

    // MARK: Data

    private var title: String { course?.title ?? "Plan" }

    // Reminders have no model or service in the shared code yet, so they live in
    // PlanRemindersStore (one shared instance, kept per course).
    private var store: PlanRemindersStore { .shared }
    private var reminders: [PlanReminderItem] { store.reminders(for: course?.id) }

    private var allTasks: [StudyTask] {
        viewModel?.tasks ?? localTasks
    }

    private var tasks: [StudyTask] {
        guard let course else { return allTasks }
        return allTasks.filter { $0.courseID == course.id }
    }

    private func addTask(_ title: String) {
        if let viewModel {
            viewModel.addTask(title: title, courseID: course?.id)
        } else {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            localTasks.append(StudyTask(courseID: course?.id, title: trimmed))
        }
    }

    // NEW: changes a task's title and leaves everything else about it as it was.
    // It uses PlanViewModel.replaceTaskItems, which your team already built for editing from
    // the Plan screens. That method removes every task missing from the list it receives,
    // so we pass ALL tasks and change only the title of the one being edited.
    private func renameTask(_ task: StudyTask, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let viewModel {
            let items = viewModel.tasks.map {
                PlanTaskItem(id: $0.id,
                             title: $0.id == task.id ? trimmed : $0.title,
                             isDone: $0.isCompleted)
            }
            viewModel.replaceTaskItems(items)
        } else if let index = localTasks.firstIndex(where: { $0.id == task.id }) {
            localTasks[index].title = trimmed
        }
    }

    // NEW: removes a task. Like renaming, it goes through replaceTaskItems, which removes any
    // task missing from the list, so we pass every task EXCEPT the one being deleted.
    // Reminders that were made from this task are removed too, so none are left pointing at it.
    private func deleteTask(_ task: StudyTask) {
        for reminder in store.reminders where reminder.generatedTaskID == task.id {
            store.delete(reminder.id)
        }

        if let viewModel {
            let items = viewModel.tasks
                .filter { $0.id != task.id }
                .map { PlanTaskItem(id: $0.id, title: $0.title, isDone: $0.isCompleted) }
            viewModel.replaceTaskItems(items)
        } else {
            localTasks.removeAll { $0.id == task.id }
        }
    }

    private func toggleTask(_ task: StudyTask) {
        if let viewModel {
            viewModel.toggleTask(task)
        } else if let index = localTasks.firstIndex(where: { $0.id == task.id }) {
            localTasks[index].isCompleted.toggle()
        }
    }

    // MARK: Body

    var body: some View {
        let back: (() -> Void)? = showsBackButton ? { dismiss() } : nil

        Group {
            switch selection {
            case .overview:
                PlanOverviewView(courseTitle: title,
                                 selection: $selection,
                                 onBack: back,
                                 tasks: tasks,
                                 reminders: reminders)
            case .plan:
                PlanView(courseTitle: title,
                         courseID: course?.id,
                         viewModel: viewModel,
                         showsBackButton: showsBackButton,
                         selection: $selection,
                         onBack: back)
            case .tasks:
                TasksView(courseTitle: title,
                          selection: $selection,
                          onBack: back,
                          tasks: tasks,
                          onAdd: addTask,
                          onToggle: toggleTask,
                          onRename: renameTask,          // NEW
                          onDelete: deleteTask)          // NEW
            case .reminders:
                RemindersView(courseTitle: title,
                              selection: $selection,
                              onBack: back,
                              reminders: reminders,
                              onAdd: { title, date in
                                  store.add(title: title, date: date, courseID: course?.id)
                              },
                              onSetEnabled: { reminder, isOn in
                                  store.setEnabled(reminder.id, isOn)
                              },
                              onDelete: { reminder in
                                  store.delete(reminder.id)
                              })
            }
        }
    }
}

#Preview {
    NavigationStack {
        CourseFlowView()
    }
}
