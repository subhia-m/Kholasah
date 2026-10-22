import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    @ObservationIgnored
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func finish() {
        appState.completeOnboarding()
    }
}
