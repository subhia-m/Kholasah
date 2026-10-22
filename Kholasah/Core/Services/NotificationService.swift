import Foundation

protocol NotificationService: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleReminder(for task: StudyTask) async throws
}
