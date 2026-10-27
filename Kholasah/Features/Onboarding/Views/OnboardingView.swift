// MARK: - شرح الملف
// واجهة تعريفية تستخدم نموذج عرض المقدمة لإكمال التعريف بالتطبيق.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct OnboardingView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: OnboardingViewModel

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 20) {
                Spacer()

                Image(.pic2)
                    .resizable()
                    .scaledToFit()
                    // يضبط مساحة تخطيط العنصر ومحاذاته.
                    .frame(width: 200, height: 200)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text("خُلاصة")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.primary)

                    Text("Kholasah")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.primary)
                }

                Text("Organize your courses, focus sessions, and study plan in one place.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                    .padding(.horizontal)

                Spacer()

                PrimaryButton(title: "Get Started") {
                    viewModel.finish()
                }
                .padding()
            }
        }
    }
}
