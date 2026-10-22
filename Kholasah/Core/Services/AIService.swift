import Foundation

protocol AIService: Sendable {
    func generateStudySuggestions(for course: Course) async throws -> [String]
}
