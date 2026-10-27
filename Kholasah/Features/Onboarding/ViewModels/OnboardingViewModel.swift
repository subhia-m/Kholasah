// MARK: - شرح الملف
// ينهي المقدمة بتحديث حالة التطبيق المشتركة، فتتغير الشاشة التي يعرضها ContentView.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class OnboardingViewModel {
    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored
    // حالة التطبيق المشتركة التي تحدد مسار الدخول.
    private let appState: AppState

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(appState: AppState) {
        self.appState = appState
    }

    // يبلغ حالة التطبيق بأن المستخدم أكمل المقدمة.
    func finish() {
        appState.completeOnboarding()
    }
}
