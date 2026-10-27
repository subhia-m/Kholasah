import Foundation
import Observation

@MainActor
@Observable
final class CoursesViewModel {
    private(set) var errorMessage: String?

    @ObservationIgnored
    private let service: CourseService

    init(service: CourseService) {
        self.service = service
    }

    var courses: [Course] {
        service.courses
    }

    func addCourse(title: String, instructor: String) -> Bool {
        createCourse(title: title, instructor: instructor) != nil
    }

    func createCourse(title: String, instructor: String) -> Course? {
        do {
            let course = try service.addCourse(title: title, instructor: instructor)
            errorMessage = nil
            return course
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func removeCourse(id: Course.ID) {
        service.removeCourse(id: id)
    }
}
