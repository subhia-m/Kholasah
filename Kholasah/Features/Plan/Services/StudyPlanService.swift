// MARK: - شرح الملف
// يربط المقررات والمهام والخطط؛ يحول مسودة الخطة إلى مهام فعلية ذات مواعيد ويحفظ معرّفاتها في الخطة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
final class StudyPlanService {
    // مستودع بيانات المقررات.
    private let courseRepository: any CourseRepository
    // مستودع بيانات المهام المشترك.
    private let taskRepository: any TaskRepository
    // مستودع بيانات الخطط.
    private let planRepository: any StudyPlanRepository

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(
        courseRepository: any CourseRepository,
        taskRepository: any TaskRepository,
        planRepository: any StudyPlanRepository
    ) {
        self.courseRepository = courseRepository
        self.taskRepository = taskRepository
        self.planRepository = planRepository
    }

    // المقررات المتاحة من مصدر البيانات.
    var courses: [Course] {
        courseRepository.courses
    }

    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask] {
        taskRepository.tasks
    }

    // الخطط المتاحة من مصدر البيانات.
    var plans: [StudyPlan] {
        planRepository.plans
    }

    // يضيف مهمة جديدة بعد التحقق من عنوانها في مسار الإضافة.
    func addTask(title: String, courseID: Course.ID?) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard !normalizedTitle.isEmpty else { return }
        taskRepository.add(StudyTask(courseID: courseID, title: normalizedTitle))
    }

    // Preserve Board dates and durations when editing through the existing Plan UI.
    // يزامن القائمة كاملة: يحذف العناصر الغائبة ويعدل الموجودة ويضيف الجديدة؛ يجب تمرير كل المهام المراد الاحتفاظ بها.
    func replaceTaskItems(_ items: [PlanTaskItem]) {
        // القائمة الممررة تمثل الحالة الكاملة المطلوبة، لذلك أي مهمة يغيب معرّفها تُحذف.
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

    // يعكس حالة إنجاز المهمة ثم يحدث مصدر البيانات.
    func toggleTask(_ task: StudyTask) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        taskRepository.update(updatedTask)
    }

    @discardableResult
    // يحوّل مسودة الخطة إلى بيانات محفوظة عبر خدمة الخطط.
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
        // إذا لم يكن الوقت المختار بعد startDate، يُرحّل أول موعد إلى اليوم التالي.
        let firstStudyDate = firstCandidate > startDate
            ? firstCandidate
            : calendar.date(byAdding: .day, value: 1, to: firstCandidate) ?? firstCandidate

        // تنشأ مهمة لكل يوم ضمن مدة الخطة، وتُحصر مدة المهمة بين ١٥ دقيقة والحد اليومي المعدل.
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

        // الخطة تحفظ معرّفات المهام؛ تفاصيل المهام نفسها موجودة في مستودع المهام.
        let plan = StudyPlan(title: draft.title, taskIDs: taskIDs)
        planRepository.save(plan)
        return plan
    }
}
