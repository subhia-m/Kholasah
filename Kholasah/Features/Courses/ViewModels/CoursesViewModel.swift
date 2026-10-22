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
        do {
            try service.addCourse(title: title, instructor: instructor)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
