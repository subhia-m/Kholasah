import Foundation

struct StudyTask: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let courseID: Course.ID?
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var durationMinutes: Int?
    var concept: String?
    var explanation: String?
    var keyPoints: [String]
    var reviewPrompt: String?
    var reminderMessage: String?

    init(
        id: UUID = UUID(),
        courseID: Course.ID? = nil,
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        durationMinutes: Int? = nil,
        concept: String? = nil,
        explanation: String? = nil,
        keyPoints: [String] = [],
        reviewPrompt: String? = nil,
        reminderMessage: String? = nil
    ) {
        self.id = id
        self.courseID = courseID
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.durationMinutes = durationMinutes
        self.concept = concept
        self.explanation = explanation
        self.keyPoints = keyPoints
        self.reviewPrompt = reviewPrompt
        self.reminderMessage = reminderMessage
    }
}
