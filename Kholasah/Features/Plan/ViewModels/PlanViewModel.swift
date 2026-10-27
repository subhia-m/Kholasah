// MARK: - شرح الملف
// ينسق استيراد المادة وتوليد الخطة وحفظ المهام وتذكيرات النظام، ويعرض حالات الانتظار والأخطاء للواجهة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class PlanViewModel {
    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored
    // الخدمة المسؤولة عن قواعد العمل.
    private let service: StudyPlanService
    @ObservationIgnored
    // خدمة قراءة المادة الدراسية من الملف.
    private let fileImportService: any FileImportService
    @ObservationIgnored
    // خدمة توليد الخطة من المادة.
    private let aiService: any AIService
    @ObservationIgnored
    // خدمة طلب إذن الإشعارات وجدولتها.
    private let notificationService: any NotificationService

    // النص وبيانات الملف بعد الاستيراد.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    private(set) var importedMaterial: ImportedCourseMaterial?
    // هل استيراد المادة جارٍ؟
    private(set) var isImportingMaterial = false
    // رسالة فشل استيراد الملف.
    var materialImportError: String?
    // مسودة الخطة الناتجة عن النموذج المحلي.
    private(set) var generatedPlanDraft: GeneratedStudyPlanDraft?
    // هل توليد الخطة جارٍ؟
    private(set) var isGeneratingPlan = false
    // هل حُفظت الخطة المولدة؟
    private(set) var didSaveGeneratedPlan = false
    // رسالة فشل توليد الخطة.
    var planGenerationError: String?
    // رسالة تعذر إعداد إشعارات النظام.
    var notificationError: String?
    // عدد التذكيرات المجدولة بعد اكتمال العملية.
    private(set) var scheduledReminderCount = 0

    // حالة توفر نموذج الذكاء الاصطناعي.
    var aiAvailability: AIModelAvailability {
        aiService.availability
    }

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    convenience init(service: StudyPlanService) {
        self.init(
            service: service,
            fileImportService: PDFFileImportService(),
            aiService: LocalFoundationModelsAIService(),
            notificationService: LocalNotificationService()
        )
    }

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(
        service: StudyPlanService,
        fileImportService: any FileImportService,
        aiService: any AIService,
        notificationService: any NotificationService
    ) {
        self.service = service
        self.fileImportService = fileImportService
        self.aiService = aiService
        self.notificationService = notificationService
    }

    // المقررات المتاحة من مصدر البيانات.
    var courses: [Course] {
        service.courses
    }

    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask] {
        service.tasks
    }

    // نسبة المهام المكتملة إلى جميع المهام، وصفر عند عدم وجود مهام.
    var completionProgress: Double {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }

    // يضيف مهمة جديدة بعد التحقق من عنوانها في مسار الإضافة.
    func addTask(title: String, courseID: Course.ID?) {
        service.addTask(title: title, courseID: courseID)
    }

    // يزامن القائمة كاملة: يحذف العناصر الغائبة ويعدل الموجودة ويضيف الجديدة؛ يجب تمرير كل المهام المراد الاحتفاظ بها.
    func replaceTaskItems(_ items: [PlanTaskItem]) {
        service.replaceTaskItems(items)
    }

    // يعكس حالة إنجاز المهمة ثم يحدث مصدر البيانات.
    func toggleTask(_ task: StudyTask) {
        service.toggleTask(task)
    }

    // يبدأ الاستيراد ويحدث حالة الانتظار ثم يخزن المادة أو رسالة الخطأ.
    // async يسمح بتعليق التنفيذ أثناء الانتظار؛ await ينتظر النتيجة، وthrows يعني أن العملية قد ترمي خطأ إذا ظهر في التوقيع.
    func importStudyMaterial(from url: URL) async {
        isImportingMaterial = true
        materialImportError = nil

        // يجمع عمليات قد ترمي أخطاء؛ يعالج catch الخطأ بدل إيقاف مسار التطبيق دون معالجة.
        do {
            importedMaterial = try await fileImportService.importCourseMaterial(from: url)
        } catch {
            importedMaterial = nil
            materialImportError = error.localizedDescription
        }

        isImportingMaterial = false
    }

    // يمسح المادة المستوردة ومسودة الخطة وحالة حفظها.
    func removeImportedMaterial() {
        importedMaterial = nil
        materialImportError = nil
        generatedPlanDraft = nil
        didSaveGeneratedPlan = false
    }

    // يولد خطة من المادة وفق عدد الأيام والوقت اليومي؛ التفاصيل أدناه توضح مسؤولية هذه الطبقة.
    func generateStudyPlan(
        courseID: Course.ID?,
        durationDays: Int,
        dailyMinutes: Int,
        remindersEnabled: Bool,
        preferredStudyTime: Date
    ) async {
        guard let importedMaterial else { return }

        isGeneratingPlan = true
        didSaveGeneratedPlan = false
        planGenerationError = nil
        notificationError = nil
        scheduledReminderCount = 0

        do {
            let draft = try await aiService.generateStudyPlan(
                material: importedMaterial,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes
            )
            generatedPlanDraft = draft
            // التوليد هنا يتبعه الحفظ مباشرة؛ المسودة المعروضة ليست منفصلة عن المهام المحفوظة.
            let plan = service.saveGeneratedPlan(
                draft,
                courseID: courseID,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes,
                preferredStudyTime: preferredStudyTime
            )
            didSaveGeneratedPlan = true

            if remindersEnabled {
                syncVisibleReminders(for: plan, courseID: courseID)
                await scheduleReminders(for: plan)
            } else {
                PlanRemindersStore.shared.replaceGeneratedReminders(
                    with: [],
                    courseID: courseID
                )
                await notificationService.cancelStudyReminders()
            }
        } catch {
            generatedPlanDraft = nil
            planGenerationError = error.localizedDescription
        }

        isGeneratingPlan = false
    }

    // يستخرج مهام الخطة ويحدّث تذكيراتها في مخزن الواجهة.
    private func syncVisibleReminders(for plan: StudyPlan, courseID: Course.ID?) {
        let planTasks = tasks.filter { plan.taskIDs.contains($0.id) }
        PlanRemindersStore.shared.replaceGeneratedReminders(
            with: planTasks,
            courseID: courseID
        )
    }

    // يطلب الإذن ثم يستبدل إشعارات الدراسة المعلقة بإشعارات مهام الخطة ويحدث العدد.
    private func scheduleReminders(for plan: StudyPlan) async {
        do {
            guard try await notificationService.requestAuthorization() else {
                throw NotificationServiceError.permissionDenied
            }

            // الإلغاء يشمل جميع إشعارات الدراسة ذات البادئة المشتركة، وليس إشعارات هذا المقرر وحده.
            await notificationService.cancelStudyReminders()
            let planTasks = tasks.filter { plan.taskIDs.contains($0.id) }
            for task in planTasks {
                try await notificationService.scheduleReminder(for: task)
            }
            scheduledReminderCount = planTasks.count
        } catch {
            notificationError = error.localizedDescription
        }
    }

    // يحوّل مسودة الخطة إلى بيانات محفوظة عبر خدمة الخطط.
    func saveGeneratedPlan(
        courseID: Course.ID?,
        durationDays: Int,
        dailyMinutes: Int
    ) {
        guard let generatedPlanDraft else { return }

        service.saveGeneratedPlan(
            generatedPlanDraft,
            courseID: courseID,
            durationDays: durationDays,
            dailyMinutes: dailyMinutes
        )
        didSaveGeneratedPlan = true
    }
}
