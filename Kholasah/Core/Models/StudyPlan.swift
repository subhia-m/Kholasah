import Foundation

struct StudyPlan: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var taskIDs: [StudyTask.ID]

    init(id: UUID = UUID(), title: String, taskIDs: [StudyTask.ID] = []) {
        self.id = id
        self.title = title
        self.taskIDs = taskIDs
    }
}
