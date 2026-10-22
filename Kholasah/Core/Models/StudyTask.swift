import Foundation

struct StudyTask: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let courseID: Course.ID?
    var title: String
    var isCompleted: Bool
    var dueDate: Date?

    init(
        id: UUID = UUID(),
        courseID: Course.ID? = nil,
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.courseID = courseID
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
}
