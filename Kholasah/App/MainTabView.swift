import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab("Courses", systemImage: "books.vertical") {
                NavigationStack {
                    CoursesView(viewModel: dependencies.coursesViewModel)
                }
            }

            Tab("Focus", systemImage: "timer") {
                NavigationStack {
                    FocusView(viewModel: dependencies.focusViewModel)
                }
            }

            Tab("Plan", systemImage: "calendar") {
                NavigationStack {
                    PlanView(viewModel: dependencies.planViewModel)
                }
            }
        }
        .tint(AppColors.primary)
    }
}
