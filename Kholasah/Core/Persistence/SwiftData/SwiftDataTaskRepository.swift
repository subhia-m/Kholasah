import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class SwiftDataTaskRepository: TaskRepository {
    private(set) var tasks: [StudyTask] = []
    @ObservationIgnored private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
        migrateLegacyTasksIfNeeded()
    }

    func add(_ task: StudyTask) {
        modelContext.insert(StudyTaskEntity(task: task))
        saveAndReload()
    }

    func update(_ task: StudyTask) {
        guard let entity = entities().first(where: { $0.id == task.id }) else { return }
        entity.update(from: task)
        saveAndReload()
    }

    func remove(id: StudyTask.ID) {
        guard let entity = entities().first(where: { $0.id == id }) else { return }
        modelContext.delete(entity)
        saveAndReload()
    }

    private func entities() -> [StudyTaskEntity] {
        (try? modelContext.fetch(FetchDescriptor<StudyTaskEntity>())) ?? []
    }

    private func reload() {
        tasks = entities().map(\.domainModel).sorted {
            ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
        }
    }

    private func saveAndReload() {
        try? modelContext.save()
        reload()
    }

    private func migrateLegacyTasksIfNeeded() {
        let defaults = UserDefaults.standard
        let migrationKey = "didMigrateStudyTasksToSwiftData.v1"
        guard tasks.isEmpty,
              !defaults.bool(forKey: migrationKey),
              let data = defaults.data(forKey: "sharedStudyTasks.v1"),
              let legacyTasks = try? JSONDecoder().decode([StudyTask].self, from: data) else {
            return
        }

        legacyTasks.forEach { modelContext.insert(StudyTaskEntity(task: $0)) }
        try? modelContext.save()
        defaults.set(true, forKey: migrationKey)
        reload()
    }
}
