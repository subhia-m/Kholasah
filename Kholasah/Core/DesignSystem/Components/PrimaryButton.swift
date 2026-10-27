// MARK: - شرح الملف
// زر قابل لإعادة الاستخدام؛ يستقبل عنوانًا وإجراءً ينفذه عند الضغط.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct PrimaryButton: View {
    // العنوان المستخدم لهذا العنصر.
    let title: LocalizedStringKey
    // دالة يمررها المستدعي لتنفيذها عند التفاعل؛ () -> Void تعني أنها لا تأخذ مدخلات ولا تعيد قيمة.
    let action: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
        Button(action: action) {
            Text(title)
                .font(.headline)
                // يضبط مساحة تخطيط العنصر ومحاذاته.
                .frame(maxWidth: .infinity)
                // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.primary)
        .controlSize(.large)
    }
}
