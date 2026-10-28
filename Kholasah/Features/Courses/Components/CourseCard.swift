// MARK: - شرح الملف

import SwiftUI

struct CourseCard: View {
    // العنوان المستخدم لهذا العنصر.
    let title: String
    // اسم المدرّس.
    let instructor: String

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)

            if !instructor.isEmpty {
                Label(instructor, systemImage: "person")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        // يضبط مساحة تخطيط العنصر ومحاذاته.
        .frame(maxWidth: .infinity, alignment: .leading)
        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
        .padding()
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CourseCard(title: "Course", instructor: "Instructor")
        .padding()
}
