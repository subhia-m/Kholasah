import Observation

@MainActor
@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        didSet {
            storage.hasCompletedOnboarding = hasCompletedOnboarding
        }
    }

    @ObservationIgnored
    private let storage: any StorageService

    init(storage: any StorageService) {
        self.storage = storage
        hasCompletedOnboarding = storage.hasCompletedOnboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
