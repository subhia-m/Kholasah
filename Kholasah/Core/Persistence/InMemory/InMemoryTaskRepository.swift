import Foundation
import Observation

@MainActor
@Observable
final class InMemoryTaskRepository: TaskRepository {
    private(set) var tasks: [StudyTask]

    init(tasks: [StudyTask] = []) {
        self.tasks = tasks
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
