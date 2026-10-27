import SwiftUI

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        if dependencies.appState.hasCompletedOnboarding {
            if dependencies.appState.hasSkippedFirstCourseSetup
                || (dependencies.appState.hasCompletedFirstCourseSetup
                    && !dependencies.coursesViewModel.courses.isEmpty) {
                MainTabView(dependencies: dependencies)
            } else {
                FirstCourseSetupView(dependencies: dependencies)
            }
        } else {
            intredac(viewModel: dependencies.onboardingViewModel)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDependencies())
}
