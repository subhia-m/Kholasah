import Foundation
import Observation

@MainActor
@Observable
final class AppDependencies {
    let appState: AppState
    let onboardingViewModel: OnboardingViewModel
    let coursesViewModel: CoursesViewModel
    let focusViewModel: FocusViewModel
    let planViewModel: PlanViewModel
    let boardViewModel: BoardViewModel

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
