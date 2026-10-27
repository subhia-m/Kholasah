// MARK: - شرح الملف
// بطاقة صوت تعرض صورة وعنوانًا ضمن قائمة أصوات التركيز.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct FocusSoundCard: View {
    // العنوان المستخدم لهذا العنصر.
    let title: LocalizedStringKey
    // اسم الصورة المستخدمة في الموارد.
    let imageName: String

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يوفر حجم المساحة المتاحة ليحسب المحتوى أبعاده بناءً عليها.
        GeometryReader { proxy in
            Image(imageName)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                // يضبط مساحة تخطيط العنصر ومحاذاته.
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height
                )
                .clipped()
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
        .accessibilityLabel(title)
    }
}
