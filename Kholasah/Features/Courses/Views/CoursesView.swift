// MARK: - شرح الملف
// يعرض قائمة المقررات وحالة القائمة الفارغة ومسارات فتح المقرر وإضافة مقرر.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// MARK: - Card colors (cycled by position in the list)

// أزواج ألوان الخلفية والنص المستخدمة لبطاقات المقررات.
private let courseCardStyles: [(background: Color, foreground: Color)] = [
    (PlanTheme.deepClay, Color(planHex: "#FFF7F0")),
    (Color.white,        PlanTheme.text),
    (PlanTheme.mauve,    Color(planHex: "#FFF7F0"))
]

// MARK: - My Courses screen

struct CoursesView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: CoursesViewModel
    /// Pass `dependencies.planViewModel` from MainTabView so each course's tasks
    /// are shared with the rest of the app. Without it, tasks stay local to the screen.
    // نموذج عرض الخطة والمهام وتوليد المحتوى.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var planViewModel: PlanViewModel? = nil

    // معرّف بطاقة المقرر الموسعة.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var expandedID: Course.ID?
    // المقرر المحدد لفتح تفاصيله.
    @State private var selectedCourse: Course?
    // يتحكم في فتح شاشة بيانات المقرر.
    @State private var showingCourseDetails = false

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // No NavigationStack here: MainTabView already provides one.
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack(alignment: .bottomTrailing) {
            PlanTheme.background.ignoresSafeArea()

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 0) {
                PlanTopBar(title: "My Courses")
                    // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                    .padding(.top, 12)

                if viewModel.courses.isEmpty {
                    emptyState
                } else {
                    // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: -28) {
                            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
                            ForEach(Array(viewModel.courses.enumerated()), id: \.element.id) { index, course in
                                StackedCourseCard(
                                    course: course,
                                    styleIndex: index,
                                    isExpanded: expandedID == course.id
                                )
                                .zIndex(Double(index))
                                .onTapGesture {
                                    if expandedID == course.id {
                                        selectedCourse = course          // second tap opens the course
                                    } else {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            expandedID = course.id       // first tap expands it
                                        }
                                    }
                                }
                                .accessibilityAddTraits(.isButton)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 80)
                    }
                }
            }

            PlanAddButton(label: "Add course") { showingCourseDetails = true }
                .padding(.trailing, 28)
                .padding(.bottom, 16)
        }
        // يربط حالة التنقل بالشاشة التي ستفتح داخل NavigationStack.
        .navigationDestination(item: $selectedCourse) { course in
            CourseFlowView(course: course,
                           viewModel: planViewModel,
                           showsBackButton: true,
                           startingAt: .overview)
        }
        .navigationDestination(isPresented: $showingCourseDetails) {
            CourseView(
                coursesViewModel: viewModel,
                planViewModel: planViewModel
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        // ينفذ الإجراء عند ظهور الواجهة.
        .onAppear {
            if expandedID == nil { expandedID = viewModel.courses.last?.id }
        }
    }

    // واجهة بديلة تظهر عندما تكون القائمة فارغة.
    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "book")
                .font(.system(size: 34))
            Text("No courses yet")
                .font(AppTypography.sectionTitle)
            Text("Tap + to add your first course.")
                .font(AppTypography.subheadline)
                .opacity(0.6)
            Spacer()
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        // يضبط مساحة تخطيط العنصر ومحاذاته.
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Card

private struct StackedCourseCard: View {
    // المقرر الذي تتعامل معه الواجهة.
    let course: Course
    // فهرس اختيار ألوان بطاقة المقرر.
    let styleIndex: Int
    // هل بطاقة المقرر موسعة؟
    let isExpanded: Bool

    // ألوان البطاقة المحسوبة.
    private var style: (background: Color, foreground: Color) {
        courseCardStyles[styleIndex % courseCardStyles.count]
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(course.title)
                .font(AppTypography.title)

            if isExpanded {
                if !course.instructor.isEmpty {
                    Label(course.instructor, systemImage: "person")
                        .font(AppTypography.caption)
                        .padding(.top, 8)
                }
                Spacer(minLength: 0)
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, isExpanded ? 16 : 40)   // the extra space is hidden by the next card's overlap
        .frame(maxWidth: .infinity, minHeight: isExpanded ? 190 : 0, alignment: .topLeading)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    
    MainTabView(dependencies: AppDependencies())
}
