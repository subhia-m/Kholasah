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

    @discardableResult
    func saveGeneratedPlan(
        _ draft: GeneratedStudyPlanDraft,
        courseID: Course.ID?,
        durationDays: Int,
        dailyMinutes: Int,
        preferredStudyTime: Date = .now,
        startDate: Date = .now
    ) -> StudyPlan {
        var taskIDs: [StudyTask.ID] = []
        let calendar = Calendar.current
        let planDayCount = max(durationDays, 1)
        let time = calendar.dateComponents([.hour, .minute], from: preferredStudyTime)
        let firstCandidate = calendar.date(
            bySettingHour: time.hour ?? 18,
            minute: time.minute ?? 0,
            second: 0,
            of: startDate
        ) ?? startDate
        let firstStudyDate = firstCandidate > startDate
            ? firstCandidate
            : calendar.date(byAdding: .day, value: 1, to: firstCandidate) ?? firstCandidate

        for (dayOffset, item) in draft.tasks.prefix(planDayCount).enumerated() {
            let duration = min(max(item.estimatedMinutes, 15), max(dailyMinutes, 15))
            let dueDate = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: firstStudyDate
            ) ?? firstStudyDate
            let task = StudyTask(
                courseID: courseID,
                title: item.title,
                dueDate: dueDate,
                durationMinutes: duration,
                concept: item.concept,
                explanation: item.explanation,
                keyPoints: item.keyPoints,
                reviewPrompt: item.reviewPrompt,
                reminderMessage: item.reminderMessage
            )
            taskRepository.add(task)
            taskIDs.append(task.id)
        }

        let plan = StudyPlan(title: draft.title, taskIDs: taskIDs)
        planRepository.save(plan)
        return plan
    }
}
