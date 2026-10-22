import Foundation

@MainActor
final class CourseService {
    private let repository: any CourseRepository

    init(repository: any CourseRepository) {
        self.repository = repository
    }

    var courses: [Course] {
        repository.courses
    }

    func addCourse(title: String, instructor: String) throws {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            throw CourseServiceError.emptyTitle
        }

        repository.add(
            Course(
                title: normalizedTitle,
                instructor: instructor.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
    }
}

enum CourseServiceError: LocalizedError {
    case emptyTitle

    var errorDescription: String? {
        "Enter a course name."
    }
}
