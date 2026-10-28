// MARK: - شرح الملف
// يحتوي مكونات الترحيب وإعداد أول مقرر.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct AddCourseWelcomeView: View {
    // إجراء فتح مسار إضافة مقرر.
    let onAddCourse: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            WelcomeHeroView(onAddCourse: onAddCourse)
        }
    }
}

private struct WelcomeHeroView: View {
    // إجراء فتح مسار إضافة مقرر.
    let onAddCourse: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يوفر حجم المساحة المتاحة ليحسب المحتوى أبعاده بناءً عليها.
        GeometryReader { proxy in
            // Root ZStack to handle visual layers correctly inside GeometryReader
            ZStack {
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    // يضبط مساحة تخطيط العنصر ومحاذاته.
                    .frame(width: proxy.size.width * 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .ignoresSafeArea(edges: .bottom)
                    .offset(x: -150, y: 102)
                    .opacity(0.6)

                Button(action: onAddCourse) {
                    Image(systemName: "plus")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundStyle(Color.white)
                        .frame(width: 72, height: 72)
                        .background(Color.neutralGray.opacity(0.8), in: Circle())
                }
                
                // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
                VStack(spacing: 0) {
                    WelcomeTitleView()
                        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                        .padding(.top, 58)

                    FirstCoursePromptView()
                        .padding(.top, 54)

                    Spacer()

                    QuoteView()
                        .padding(.leading, 138)
                        .padding(.trailing, 12)
                        .padding(.bottom, 80)
                }
            }
        }
    }
}

struct FirstCourseSetupView: View {
    // الحاوية المشتركة للخدمات ونماذج العرض.
    let dependencies: AppDependencies
    // يتحكم في فتح شاشة بيانات المقرر.
    @State private var showingCourseDetails = false

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        NavigationStack {
            AddCourseWelcomeView {
                showingCourseDetails = true
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dependencies.appState.hasSkippedFirstCourseSetup = true
                } label: {
                    Text("Skip")
                        .font(.footnote)
                        .foregroundStyle(AppColors.brown.opacity(0.7))
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Continue to Board, Focus, and Courses without adding a course")
                .padding(.trailing, 20)
                .padding(.top, 4)
            }
            // يربط حالة التنقل بالشاشة التي ستفتح داخل NavigationStack.
            .navigationDestination(isPresented: $showingCourseDetails) {
                CourseView(
                    coursesViewModel: dependencies.coursesViewModel,
                    planViewModel: dependencies.planViewModel
                ) { _ in
                    dependencies.appState.completeFirstCourseSetup()
                }
            }
        }
    }
}

private struct WelcomeTitleView: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(spacing: 8) {
            Text("ADD YOUR")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.titleBrown)

            // يرتب العناصر أفقيًا.
            HStack(spacing: 10) {
                Text("FIRST COURSE")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.titleBrown)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
        }
        .multilineTextAlignment(.center)
    }
}

private struct FirstCoursePromptView: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(spacing: 31) {
            Text("Add your first course!")
                .font(.system(size: 21, weight: .regular, design: .rounded))
                .foregroundStyle(Color.titleBrown)
        }
        // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
        .accessibilityLabel("Add your first course")
    }
}

private struct QuoteView: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.quoteBrown.opacity(0.89))
                .frame(height: 70)

            HStack(spacing: 8) {
                Image("date")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 66, height: 66)
                    .rotationEffect(.degrees(5))
                    .offset(x: -22, y: 19)

                Text("“ motivation quote here ”")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .italic()
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                    .offset(x: -28)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Motivation quote")
    }
}

// extension يضيف وظائف أو خصائص محسوبة إلى نوع موجود دون تعديل تعريفه الأصلي.
private extension Color {
    // لون مشترك من لوحة ألوان التصميم.
    static let backgroundCream = Color(red: 242 / 255, green: 238 / 255, blue: 234 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let quoteBrown = Color(red: 72 / 255, green: 9 / 255, blue: 2 / 255)
    // لون العناوين.
    static let titleBrown = Color(red: 100 / 255, green: 25 / 255, blue: 14 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let neutralGray = Color(red: 151 / 255, green: 151 / 255, blue: 151 / 255)
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    AddCourseWelcomeView(onAddCourse: {})
}
