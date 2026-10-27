import Observation

@MainActor
@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        didSet {
            storage.hasCompletedOnboarding = hasCompletedOnboarding
        }
    }

    var hasCompletedFirstCourseSetup: Bool {
        didSet {
            storage.hasCompletedFirstCourseSetup = hasCompletedFirstCourseSetup
        }
    }

    @ObservationIgnored
    private let storage: any StorageService

    init(storage: any StorageService) {
        self.storage = storage
        hasCompletedOnboarding = storage.hasCompletedOnboarding
        hasCompletedFirstCourseSetup = storage.hasCompletedFirstCourseSetup
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func completeFirstCourseSetup() {
        hasCompletedFirstCourseSetup = true
    }
}
