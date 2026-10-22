import SwiftUI

struct PlanOverviewView: View {
    let viewModel: PlanViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProgressCard(
                    completedCount: viewModel.tasks.filter(\.isCompleted).count,
                    totalCount: viewModel.tasks.count,
                    progress: viewModel.completionProgress
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Courses in your plan")
                        .font(AppTypography.title)

                    if viewModel.courses.isEmpty {
                        Text("Courses you add in the Courses tab will appear here.")
                            .foregroundStyle(AppColors.secondaryText)
                    } else {
                        ForEach(viewModel.courses) { course in
                            CourseCard(
                                title: course.title,
                                instructor: course.instructor
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Overview")
    }
}
