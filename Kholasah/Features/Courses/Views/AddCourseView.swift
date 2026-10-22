import SwiftUI

struct AddCourseView: View {
    let viewModel: CoursesViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var instructor = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Course") {
                    TextField("Course name", text: $title)
                    TextField("Instructor (optional)", text: $instructor)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearError()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if viewModel.addCourse(title: title, instructor: instructor) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
