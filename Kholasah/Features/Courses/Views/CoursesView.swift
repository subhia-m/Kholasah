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
                .font(.system(size: 18, weight: .medium))
            Text("Tap + to add your first course.")
                .font(.system(size: 14))
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
                .font(.system(size: 22, weight: .regular, design: .serif))

            if isExpanded {
                if !course.instructor.isEmpty {
                    Label(course.instructor, systemImage: "person")
                        .font(.system(size: 13))
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

// MARK: - Add course sheet

private struct NewCourseSheet: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: CoursesViewModel
    // إجراء إبلاغ الأب بنجاح الإضافة.
    let onAdded: () -> Void

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // العنوان المستخدم لهذا العنصر.
    @State private var title = ""
    // اسم المدرّس.
    @State private var instructor = ""
    // هل حقل الإدخال يمتلك تركيز لوحة المفاتيح؟
    // @FocusState يربط حالة التركيز بحقول الإدخال للتحكم بلوحة المفاتيح.
    @FocusState private var isFocused: Bool

    // العنوان بعد إزالة الفراغات والأسطر من طرفيه.
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Course")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
            TextField("Course name", text: $title)
                .focused($isFocused)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            TextField("Instructor (optional)", text: $instructor)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
            }

            // يرتب العناصر أفقيًا.
            HStack(spacing: 12) {
                // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                Button("Cancel") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add") {
                    if viewModel.addCourse(title: trimmedTitle, instructor: instructor) {
                        onAdded()
                        dismiss()
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(PlanTheme.deepClay))
                .opacity(trimmedTitle.isEmpty ? 0.4 : 1)
                .disabled(trimmedTitle.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(PlanTheme.background.ignoresSafeArea())
        .onAppear {
            isFocused = true
            viewModel.clearError()
        }
        // ينفذ الإجراء عند اختفاء الواجهة.
        .onDisappear { viewModel.clearError() }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    
    MainTabView(dependencies: AppDependencies())
}
