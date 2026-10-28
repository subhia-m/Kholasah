// MARK: - شرح الملف
// يطلب إذن الإشعارات ويجدول تذكيرات النظام المحلية للمهام ويلغي التذكيرات التي تحمل بادئة التطبيق المحددة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import UserNotifications

// protocol عقد يحدد المتطلبات؛ النوع المطابق له يقدم التنفيذ الفعلي.
protocol NotificationService: Sendable {
    // يطلب من النظام إذن إظهار التنبيهات وتشغيل أصواتها.
    // async يسمح بتعليق التنفيذ أثناء الانتظار؛ await ينتظر النتيجة، وthrows يعني أن العملية قد ترمي خطأ إذا ظهر في التوقيع.
    func requestAuthorization() async throws -> Bool
    // ينشئ إشعارًا محليًا لموعد مهمة مستقبلية ويستخدم معرّف المهمة لتحديده.
    func scheduleReminder(for task: StudyTask) async throws
    // يلغي إشعارات الدراسة المعلقة التي تحمل بادئة المعرّف المحددة.
    func cancelStudyReminders() async
}

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum NotificationServiceError: LocalizedError {
    case permissionDenied
    case missingDate

    // وصف قابل للعرض للخطأ.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
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
    // بادئة تميز إشعارات الدراسة عن غيرها.
    private static let identifierPrefix = "study-task-"

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    nonisolated init() {}

    // يطلب من النظام إذن إظهار التنبيهات وتشغيل أصواتها.
    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    // ينشئ إشعارًا محليًا لموعد مهمة مستقبلية ويستخدم معرّف المهمة لتحديده.
    func scheduleReminder(for task: StudyTask) async throws {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
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

    // يلغي إشعارات الدراسة المعلقة التي تحمل بادئة المعرّف المحددة.
    func cancelStudyReminders() async {
        let center = UNUserNotificationCenter.current()
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // يبني نص التذكير من الرسالة التحفيزية ومدة المهمة عند توفرها.
    private func reminderBody(for task: StudyTask) -> String {
        let encouragement = task.reminderMessage
            ?? "You are one focused session closer to your goal."
        guard let duration = task.durationMinutes else {
            return encouragement
        }
        return "\(duration) minutes • \(encouragement)"
    }
}
