// MARK: - شرح الملف
// بطاقة مهمة مع إجراء يطلب تبديل حالة الإنجاز.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct TaskCard: View {
    // العنوان المستخدم لهذا العنصر.
    let title: String
    // هل أُنجزت المهمة؟
    let isCompleted: Bool
    // إجراء طلب تبديل حالة الإنجاز أو المؤقت وفق المكوّن.
    let onToggle: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
        Button(action: onToggle) {
            // يرتب العناصر أفقيًا.
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? AppColors.primary : AppColors.secondaryText)
                Text(title)
                    .strikethrough(isCompleted)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isCompleted ? "Completed" : "Not completed")
    }
}
