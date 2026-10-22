import SwiftUI

struct CourseDetailView: View {
    let course: Course

    var body: some View {
        List {
            Section("Course Details") {
                LabeledContent("Name", value: course.title)
                if !course.instructor.isEmpty {
                    LabeledContent("Instructor", value: course.instructor)
                }
            }
        }
        .navigationTitle(course.title)
    }
}
