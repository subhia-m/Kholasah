// MARK: - شرح الملف
// مكوّن واجهة يعرض مؤشر انتظار أثناء تنفيذ عملية.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct LoadingView: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        ProgressView("Loading…")
            // يضبط مساحة تخطيط العنصر ومحاذاته.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
    }
}
