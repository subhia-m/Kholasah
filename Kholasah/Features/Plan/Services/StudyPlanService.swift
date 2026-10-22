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

    func toggleTask(_ task: StudyTask) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        taskRepository.update(updatedTask)
    }
}
