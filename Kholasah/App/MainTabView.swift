import SwiftUI

struct MainTabView: View {
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
//                    FocusView(viewModel: dependencies.focusViewModel)
                }
            }

            Tab("Courses", systemImage: "book") {
                NavigationStack {
                    CoursesView(viewModel: dependencies.coursesViewModel, planViewModel: dependencies.planViewModel)
                }
            }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView(dependencies: AppDependencies())
}
