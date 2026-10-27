import SwiftUI

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        if dependencies.appState.hasCompletedOnboarding {
            MainTabView(dependencies: dependencies)
        } else {
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDependencies())
}
