import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SwiftDataCourseRepository: CourseRepository {
    private(set) var courses: [Course] = []
    @ObservationIgnored private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
    }

    func add(_ course: Course) {
        modelContext.insert(CourseEntity(id: course.id, title: course.title, instructor: course.instructor))
        saveAndReload()
    }

    func update(_ course: Course) {
        guard let entity = entities().first(where: { $0.id == course.id }) else { return }
        entity.title = course.title
        entity.instructor = course.instructor
        saveAndReload()
    }

    func remove(id: Course.ID) {
        guard let entity = entities().first(where: { $0.id == id }) else { return }
        modelContext.delete(entity)
        saveAndReload()
    }

    private func entities() -> [CourseEntity] {
        (try? modelContext.fetch(FetchDescriptor<CourseEntity>())) ?? []
    }

    private func reload() {
        courses = entities().map(\.domainModel).sorted { $0.title < $1.title }
    }

    private func saveAndReload() {
        try? modelContext.save()
        reload()
    }
}
