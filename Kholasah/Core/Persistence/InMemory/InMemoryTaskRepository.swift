import Foundation
import Observation

@MainActor
@Observable
final class InMemoryTaskRepository: TaskRepository {
    private(set) var tasks: [StudyTask] {
        didSet { persist() }
    }
    private let defaults: UserDefaults?
    private let storageKey = "sharedStudyTasks.v1"

    // Passing defaults enables local persistence; tests and previews remain isolated.
    init(tasks: [StudyTask] = [], defaults: UserDefaults? = nil) {
        self.defaults = defaults
        if let data = defaults?.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([StudyTask].self, from: data) {
            self.tasks = saved
        } else {
            self.tasks = tasks
        }
    }

    private func persist() {
        guard let defaults, let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func add(_ task: StudyTask) {
        tasks.append(task)
    }

    func update(_ task: StudyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    func remove(id: StudyTask.ID) {
        tasks.removeAll { $0.id == id }
    }
}
