// MARK: - شرح الملف
// يجمع تبويبات التطبيق ويمرر إليها نماذج العرض المشتركة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct MainTabView: View {
    // حالة المشهد: نشط أو غير نشط أو في الخلفية.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.scenePhase) private var scenePhase
    // الحاوية المشتركة للخدمات ونماذج العرض.
    let dependencies: AppDependencies
    // خيار تمرير عرض بطاقات المعاينة إلى اللوحة.
    var boardPreviewCards = false

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    // تستقبل الشاشات نماذج العرض من الحاوية نفسها بدل إنشاء نسخ مستقلة من البيانات.
    var body: some View {
        TabView {
            Tab("Board", systemImage: "rectangle.grid.2x2") {
                // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
                NavigationStack {
                    BoardView(viewModel: dependencies.boardViewModel, previewCards: boardPreviewCards)
                }
            }

            Tab("Focus", systemImage: "hourglass.badge.eye") {
                NavigationStack {
                    FocusView(viewModel: dependencies.focusViewModel)
                }
            }

            Tab("Courses", systemImage: "book") {
                NavigationStack {
                    CoursesView(viewModel: dependencies.coursesViewModel, planViewModel: dependencies.planViewModel)
                }
            }
        }
        .tint(AppColors.primary)
        // ينفذ الإجراء عند تغير القيمة المراقبة.
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { dependencies.focusViewModel.audioPlayer.pause() }
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    MainTabView(dependencies: AppDependencies())
}
