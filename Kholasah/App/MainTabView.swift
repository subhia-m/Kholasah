import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab("Board", systemImage: "rectangle.grid.2x2") {
                NavigationStack {
                    CoursesView(viewModel: dependencies.coursesViewModel)
                }
            }

            Tab("Focus", systemImage: "hourglass.badge.eye") {
                NavigationStack {
                    FocusView(viewModel: dependencies.focusViewModel)
                }
            }

            Tab("Plan", systemImage: "book") {
                NavigationStack {
                    PlanView(viewModel: dependencies.planViewModel)
                }
            }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView(dependencies: AppDependencies())
}
