import Foundation
import UserNotifications

protocol NotificationService: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleReminder(for task: StudyTask) async throws
    func cancelStudyReminders() async
}

enum NotificationServiceError: LocalizedError {
    case permissionDenied
    case missingDate

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Notifications are disabled. You can enable them in Settings."
        case .missingDate:
            "The study task does not have a valid reminder date."
        }
    }
}

struct LocalNotificationService: NotificationService {
    private static let identifierPrefix = "study-task-"

    nonisolated init() {}

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    func scheduleReminder(for task: StudyTask) async throws {
        guard let dueDate = task.dueDate, dueDate > .now else {
            throw NotificationServiceError.missingDate
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to study: \(task.title)"
        content.body = reminderBody(for: task)
        content.sound = .default
        content.threadIdentifier = "study-plan"

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: Self.identifierPrefix + task.id.uuidString,
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelStudyReminders() async {
        let center = UNUserNotificationCenter.current()
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func reminderBody(for task: StudyTask) -> String {
        let encouragement = task.reminderMessage
            ?? "You are one focused session closer to your goal."
        guard let duration = task.durationMinutes else {
            return encouragement
        }
        return "\(duration) minutes • \(encouragement)"
    }
}
