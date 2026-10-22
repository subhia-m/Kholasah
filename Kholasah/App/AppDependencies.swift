import Observation

@MainActor
@Observable
final class AppDependencies {
    let appState: AppState
    let onboardingViewModel: OnboardingViewModel
    let coursesViewModel: CoursesViewModel
    let focusViewModel: FocusViewModel
    let planViewModel: PlanViewModel

    convenience init() {
        self.init(
            storageService: UserDefaultsStorageService(),
            courseRepository: InMemoryCourseRepository(),
            taskRepository: InMemoryTaskRepository(),
            studyPlanRepository: InMemoryStudyPlanRepository(),
            timerService: SystemTimerService()
        )
    }

    init(
        storageService: any StorageService,
        courseRepository: InMemoryCourseRepository,
        taskRepository: InMemoryTaskRepository,
        studyPlanRepository: InMemoryStudyPlanRepository,
        timerService: any TimerService
    ) {
        let appState = AppState(storage: storageService)
        let courseService = CourseService(repository: courseRepository)
        let planService = StudyPlanService(
            courseRepository: courseRepository,
            taskRepository: taskRepository,
            planRepository: studyPlanRepository
        )

        self.appState = appState
        onboardingViewModel = OnboardingViewModel(appState: appState)
        coursesViewModel = CoursesViewModel(service: courseService)
        focusViewModel = FocusViewModel(timerService: timerService)
        planViewModel = PlanViewModel(service: planService)
    }
}
