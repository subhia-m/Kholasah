// MARK: - شرح الملف
// يحفظ حالة إكمال المقدمة وإعداد أول مقرر. التخطي مؤقت للجلسة، بينما يُحفظ الإكمال عبر خدمة التخزين.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class AppState {
    // علامة إكمال المستخدم لشاشات المقدمة.
    var hasCompletedOnboarding: Bool {
        // didSet يعمل بعد تغيير الخاصية ليزامن قيمتها مع التخزين المحلي.
        didSet {
            storage.hasCompletedOnboarding = hasCompletedOnboarding
        }
    }

    // علامة إكمال إعداد المقرر الأول.
    var hasCompletedFirstCourseSetup: Bool {
        didSet {
            storage.hasCompletedFirstCourseSetup = hasCompletedFirstCourseSetup
        }
    }

    // Skipping only applies to the current app session.
    // علامة تخطي إعداد المقرر في جلسة التطبيق الحالية.
    var hasSkippedFirstCourseSetup = false

    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored
    // خدمة حفظ إعدادات التطبيق.
    private let storage: any StorageService

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(storage: any StorageService) {
        self.storage = storage
        hasCompletedOnboarding = storage.hasCompletedOnboarding
        hasCompletedFirstCourseSetup = storage.hasCompletedFirstCourseSetup
    }

    // يسجل إكمال المقدمة؛ مراقب الخاصية يحفظ القيمة في التخزين.
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // يسجل إكمال إعداد المقرر الأول.
    func completeFirstCourseSetup() {
        hasCompletedFirstCourseSetup = true
    }
}
