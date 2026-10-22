import SwiftUI

struct PlanView: View {
    let viewModel: PlanViewModel

    var body: some View {
        List {
            NavigationLink {
                PlanOverviewView(viewModel: viewModel)
            } label: {
                Label("Overview", systemImage: "chart.bar")
            }

            NavigationLink {
                TasksView(viewModel: viewModel)
            } label: {
                Label("Tasks", systemImage: "checklist")
            }

            NavigationLink {
                RemindersView()
            } label: {
                Label("Reminders", systemImage: "bell")
            }

            Section("Shared Courses") {
                if viewModel.courses.isEmpty {
                    Text("Add a course from the Courses tab.")
                        .foregroundStyle(AppColors.secondaryText)
                } else {
                    ForEach(viewModel.courses) { course in
                        Label(course.title, systemImage: "book.closed")
                    }
                }
            }
        }
        .navigationTitle("Plan")
    }
}
