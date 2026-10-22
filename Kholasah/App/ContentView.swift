import SwiftUI

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        if dependencies.appState.hasCompletedOnboarding {
            MainTabView(dependencies: dependencies)
        } else {
            OnboardingView(viewModel: dependencies.onboardingViewModel)
        }
    }
}
