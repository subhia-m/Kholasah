import Foundation

struct Course: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    var title: String
    var instructor: String

    init(id: UUID = UUID(), title: String, instructor: String = "") {
        self.id = id
        self.title = title
        self.instructor = instructor
    }
}
