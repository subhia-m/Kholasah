import Testing
@testable import Kholasah

@MainActor
struct CourseServiceTests {
    @Test
    func trimsAndStoresCourseInput() throws {
        let repository = InMemoryCourseRepository()
        let service = CourseService(repository: repository)

        try service.addCourse(title: "  Physics  ", instructor: "  Dr. Amal  ")

        #expect(repository.courses == [
            Course(title: "Physics", instructor: "Dr. Amal")
        ])
    }

    @Test
    func rejectsBlankCourseTitle() {
        let service = CourseService(repository: InMemoryCourseRepository())

        #expect(throws: CourseServiceError.self) {
            try service.addCourse(title: "   ", instructor: "")
        }
    }
}
