import Foundation

protocol FileImportService: Sendable {
    func importCourseMaterial(from url: URL) async throws -> Data
}
