import SwiftUI

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    let dependencies: AppDependencies
    var boardPreviewCards = false

    var body: some View {
        TabView {
            Tab("Board", systemImage: "rectangle.grid.2x2") {
                NavigationStack {
                    BoardView(viewModel: dependencies.boardViewModel, previewCards: boardPreviewCards)
                }
            }

            Tab("Focus", systemImage: "hourglass.badge.eye") {
                NavigationStack {
                    FocusView(viewModel: dependencies.focusViewModel)
                }
            }

            Tab("Courses", systemImage: "book") {
                NavigationStack {
                    CoursesView(viewModel: dependencies.coursesViewModel, planViewModel: dependencies.planViewModel)
                }
            }
        }
        .tint(AppColors.primary)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { dependencies.focusViewModel.audioPlayer.pause() }
        }
    }
}

#Preview {
    MainTabView(dependencies: AppDependencies())
}
