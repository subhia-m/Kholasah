// MARK: - شرح الملف
// يختار الشاشة الأولى وفق حالة المستخدم: المقدمة، ثم إعداد أول مقرر، ثم التبويبات الرئيسية.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct ContentView: View {
    // الحاوية المشتركة للخدمات ونماذج العرض.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(AppDependencies.self) private var dependencies

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        if dependencies.appState.hasCompletedOnboarding {
            if dependencies.appState.hasSkippedFirstCourseSetup
                || dependencies.appState.hasCompletedFirstCourseSetup {
                MainTabView(dependencies: dependencies)
            } else {
                FirstCourseSetupView(dependencies: dependencies)
            }
        } else {
            intredac(viewModel: dependencies.onboardingViewModel)
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    ContentView()
        .environment(AppDependencies())
}
