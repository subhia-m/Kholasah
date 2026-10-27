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

    @discardableResult
    func addCourse(title: String, instructor: String) throws -> Course {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            throw CourseServiceError.emptyTitle
        }

        let course = Course(
            title: normalizedTitle,
            instructor: instructor.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        repository.add(course)
        return course
    }

    func removeCourse(id: Course.ID) {
        repository.remove(id: id)
    }
}

enum CourseServiceError: LocalizedError {
    case emptyTitle

    var errorDescription: String? {
        "Enter a course name."
    }
}
