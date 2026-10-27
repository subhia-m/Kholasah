// MARK: - شرح الملف
// بطاقة تعرض عدد المهام المكتملة وإجمالي المهام ونسبة التقدم.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct ProgressCard: View {
    // عدد العناصر المكتملة.
    let completedCount: Int
    // إجمالي عدد العناصر.
    let totalCount: Int
    // نسبة التقدم التي تستخدمها الواجهة.
    let progress: Double

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Progress")
                .font(AppTypography.title)

            ProgressView(value: progress)

            Text("\(completedCount) of \(totalCount) tasks completed")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
        .padding()
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
