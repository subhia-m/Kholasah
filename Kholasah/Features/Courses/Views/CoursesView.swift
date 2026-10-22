import SwiftUI

struct CoursesView: View {
    let viewModel: CoursesViewModel
    @State private var isAddingCourse = false

    var body: some View {
        Group {
            if viewModel.courses.isEmpty {
                ContentUnavailableView(
                    "No Courses Yet",
                    systemImage: "books.vertical",
                    description: Text("Add your first course to begin building your study plan.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.courses) { course in
                            NavigationLink(value: course) {
                                CourseCard(
                                    title: course.title,
                                    instructor: course.instructor
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .background(AppColors.background)
            }
        }
        .navigationTitle("Courses")
        .toolbar {
            Button("Add Course", systemImage: "plus") {
                isAddingCourse = true
            }
        }
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(course: course)
        }
        .sheet(isPresented: $isAddingCourse) {
            AddCourseView(viewModel: viewModel)
        }
    }
}
