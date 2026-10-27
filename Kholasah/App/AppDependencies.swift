// MARK: - شرح الملف
// يجمع الخدمات ومستودعات البيانات ونماذج العرض في مكان واحد؛ تشترك شاشتا اللوحة والخطة في مستودع المهام نفسه.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class AppDependencies {
    // حالة التطبيق المشتركة التي تحدد مسار الدخول.
    let appState: AppState
    // نموذج عرض إكمال المقدمة.
    let onboardingViewModel: OnboardingViewModel
    // نموذج عرض إدارة المقررات.
    let coursesViewModel: CoursesViewModel
    // نموذج عرض مؤقت التركيز.
    let focusViewModel: FocusViewModel
    // نموذج عرض الخطة والمهام وتوليد المحتوى.
    let planViewModel: PlanViewModel
    // نموذج عرض اللوحة والتقويم.
    let boardViewModel: BoardViewModel

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    convenience init() {
        self.init(
            storageService: UserDefaultsStorageService(),
            courseRepository: InMemoryCourseRepository(),
            taskRepository: InMemoryTaskRepository(defaults: .standard),
            studyPlanRepository: InMemoryStudyPlanRepository(),
            timerService: SystemTimerService(),
            fileImportService: PDFFileImportService(),
            aiService: LocalFoundationModelsAIService(),
            notificationService: LocalNotificationService()
        )
    }

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(
        storageService: any StorageService,
        courseRepository: InMemoryCourseRepository,
        taskRepository: InMemoryTaskRepository,
        studyPlanRepository: InMemoryStudyPlanRepository,
        timerService: any TimerService,
        fileImportService: any FileImportService = PDFFileImportService(),
        aiService: any AIService = LocalFoundationModelsAIService(),
        notificationService: any NotificationService = LocalNotificationService()
    ) {
        let appState = AppState(storage: storageService)
        let courseService = CourseService(repository: courseRepository)
        let planService = StudyPlanService(
            courseRepository: courseRepository,
            taskRepository: taskRepository,
            planRepository: studyPlanRepository
        )

        // تمرير taskRepository نفسه إلى اللوحة وخدمة الخطط يجعل تعديل المهمة ظاهرًا في الشاشتين.
        boardViewModel = BoardViewModel(repository: taskRepository)
        self.appState = appState
        onboardingViewModel = OnboardingViewModel(appState: appState)
        coursesViewModel = CoursesViewModel(service: courseService)
        focusViewModel = FocusViewModel(timerService: timerService)
        planViewModel = PlanViewModel(
            service: planService,
            fileImportService: fileImportService,
            aiService: aiService,
            notificationService: notificationService
        )
    }
}
