import Testing
@testable import Kholasah

@MainActor
struct SharedCourseDataTests {
    @Test
    func courseAddedInCoursesIsVisibleInPlan() {
        let repository = InMemoryCourseRepository()
        let coursesViewModel = CoursesViewModel(
            service: CourseService(repository: repository)
        )
        let planViewModel = PlanViewModel(
            service: StudyPlanService(
                courseRepository: repository,
                taskRepository: InMemoryTaskRepository(),
                planRepository: InMemoryStudyPlanRepository()
            )
        )

        let wasAdded = coursesViewModel.addCourse(
            title: "Algorithms",
            instructor: "Dr. Noor"
        )

        #expect(wasAdded)
        #expect(coursesViewModel.courses.count == 1)
        #expect(planViewModel.courses == coursesViewModel.courses)
        #expect(planViewModel.courses.first?.title == "Algorithms")
    }

    @Test
    func onboardingCompletionIsPersisted() {
        let storage = TestStorageService()
        let appState = AppState(storage: storage)

        appState.completeOnboarding()

        #expect(appState.hasCompletedOnboarding)
        #expect(storage.hasCompletedOnboarding)
        #expect(AppState(storage: storage).hasCompletedOnboarding)
    }
}

@MainActor
private final class TestStorageService: StorageService {
    var hasCompletedOnboarding = false
}
