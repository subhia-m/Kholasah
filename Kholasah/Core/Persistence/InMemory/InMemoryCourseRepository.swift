import Foundation
import Observation

@MainActor
@Observable
final class InMemoryCourseRepository: CourseRepository {
    private(set) var courses: [Course]

    init(courses: [Course] = []) {
        self.courses = courses
    }

    func add(_ course: Course) {
        courses.append(course)
    }

    func update(_ course: Course) {
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else { return }
        courses[index] = course
    }

    func remove(id: Course.ID) {
        courses.removeAll { $0.id == id }
    }
}
