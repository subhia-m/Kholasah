// MARK: - شرح الملف
// نقطة بدء التطبيق: تنشئ الاعتماديات المشتركة وتضع الشاشة الأولى داخل نافذة التطبيق.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// نقطة الدخول التي يبدأ منها تشغيل التطبيق.
@main
struct MyApp: App {
    // الحاوية المشتركة للخدمات ونماذج العرض.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var dependencies: AppDependencies

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init() {
        _dependencies = State(initialValue: AppDependencies())
    }

    // يعرّف مشهد التطبيق؛ WindowGroup ينشئ نافذة تعرض ContentView.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
    }
}
