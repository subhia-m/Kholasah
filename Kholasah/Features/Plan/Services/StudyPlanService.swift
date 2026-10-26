import Foundation

@MainActor
final class StudyPlanService {
    private let courseRepository: any CourseRepository
    private let taskRepository: any TaskRepository
    private let planRepository: any StudyPlanRepository

    init(
        courseRepository: any CourseRepository,
        taskRepository: any TaskRepository,
        planRepository: any StudyPlanRepository
    ) {
        self.courseRepository = courseRepository
        self.taskRepository = taskRepository
        self.planRepository = planRepository
    }

    var courses: [Course] {
        courseRepository.courses
    }

    var tasks: [StudyTask] {
        taskRepository.tasks
    }

    var plans: [StudyPlan] {
        planRepository.plans
    }

    func addTask(title: String, courseID: Course.ID?) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else { return }
        taskRepository.add(StudyTask(courseID: courseID, title: normalizedTitle))
    }

    // Preserve Board dates and durations when editing through the existing Plan UI.
    func replaceTaskItems(_ items: [PlanTaskItem]) {
        let ids = Set(items.map(\.id))
        for task in tasks where !ids.contains(task.id) {
            taskRepository.remove(id: task.id)
        }
        for item in items {
            if var task = tasks.first(where: { $0.id == item.id }) {
                task.title = item.title
                task.isCompleted = item.isDone
                taskRepository.update(task)
            } else {
                taskRepository.add(StudyTask(id: item.id, title: item.title,
                                            isCompleted: item.isDone, dueDate: .now, durationMinutes: 25))
            }
        }
    }

    func toggleTask(_ task: StudyTask) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        taskRepository.update(updatedTask)
    }
}
