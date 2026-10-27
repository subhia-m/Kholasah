// MARK: - شرح الملف
// يضم تصميم صفحات الخطة ومكوناتها المشتركة، ويعرض جدول المهام المولدة بحسب المقرر.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// MARK: - Theme (used only by the Plan and Courses screens)

// extension يضيف وظائف أو خصائص محسوبة إلى نوع موجود دون تعديل تعريفه الأصلي.
extension Color {
    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(planHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum PlanTheme {
    // لون مشترك من لوحة ألوان التصميم.
    static let background        = AppColors.background   // page background
    // النص المستخدم في هذا المكوّن.
    static let text              = AppColors.burgundy     // titles and body text
    // لون مشترك من لوحة ألوان التصميم.
    static let deepClay          = AppColors.primary      // main buttons, checkmarks, first course card
    // لون مشترك من لوحة ألوان التصميم.
    static let mauve             = AppColors.brown        // "New Task" box, third course card
    // لون مشترك من لوحة ألوان التصميم.
    static let progressBrown     = AppColors.burgundy     // Course Progress box
    // لون مشترك من لوحة ألوان التصميم.
    static let controlBackground = AppColors.darkPage     // switcher bar and text fields
    // لون مشترك من لوحة ألوان التصميم.
    static let chip              = AppColors.darkPage     // round + / back buttons, Cancel buttons
}

// MARK: - Shared building blocks

struct PlanTopBar: View {
    // العنوان المستخدم لهذا العنصر.
    let title: String
    // إجراء الرجوع الذي يمرره العرض الأب.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var onBack: (() -> Void)? = nil

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            Text(title)
                .font(.system(size: 26, weight: .regular))
                .foregroundStyle(PlanTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                .padding(.horizontal, 48)   // keeps long names clear of the back button
                .accessibilityAddTraits(.isHeader)

            // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
            if let onBack {
                // يرتب العناصر أفقيًا.
                HStack {
                    // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(PlanTheme.text)
                            // يضبط مساحة تخطيط العنصر ومحاذاته.
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(PlanTheme.chip))
                    }
                    // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                    .accessibilityLabel("Back")
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

struct PlanAddButton: View {
    // النص الذي يصف المكوّن.
    var label: String = "Add"
    // دالة يمررها المستدعي لتنفيذها عند التفاعل؛ () -> Void تعني أنها لا تأخذ مدخلات ولا تعيد قيمة.
    let action: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(PlanTheme.text)
                .frame(width: 36, height: 36)
                .background(Circle().fill(PlanTheme.chip))
        }
        .accessibilityLabel(label)
    }
}

struct PlanPalmLeaf: View {
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // Optional decoration: add an image named "palmLeaf" to Assets.
        Image("palmLeaf")
            .resizable()
            .scaledToFit()
            .frame(width: 40)
            .opacity(0.35)
            .allowsHitTesting(false)
    }
}

/// White card with a soft shadow and a palm leaf in the corner.
struct PlanCard<Content: View>: View {
    // المحتوى الداخلي الذي تتكون منه هذه الواجهة.
    // يسمح بتجميع عدة عناصر وشروط لبناء محتوى SwiftUI.
    @ViewBuilder var content: Content

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
            PlanPalmLeaf().padding(8)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

// MARK: - Section switcher

enum PlanScreenTab: String, CaseIterable {
    case overview = "Overview"
    case plan = "Plan"
    case tasks = "Tasks"
    case reminders = "Reminders"
}

struct PlanSectionPicker: View {
    // التبويب المحدد الذي يقرر المحتوى المعروض.
    // @Binding رابط قراءة وكتابة إلى قيمة يملكها العرض الأب، حتى ينعكس التعديل في الطرفين.
    @Binding var selection: PlanScreenTab
    // مساحة أسماء لحركة مؤشر التبويب المحدد.
    // مساحة أسماء مشتركة لربط العناصر التي تستخدم تأثيرات انتقال متطابقة.
    @Namespace private var pill

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        HStack(spacing: 0) {
            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(PlanScreenTab.allCases, id: \.self) { tab in
                let isSelected = tab == selection
                Text(tab.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selection = tab
                        }
                    }
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(Capsule().fill(PlanTheme.controlBackground))
        .padding(.horizontal, 12)
    }
}

// MARK: - Page scaffold (every page uses this: background, top bar, switcher, divider)

struct PlanPageScaffold<Content: View>: View {
    // العنوان المستخدم لهذا العنصر.
    let title: String
    // التبويب المحدد الذي يقرر المحتوى المعروض.
    @Binding var selection: PlanScreenTab
    // إجراء الرجوع الذي يمرره العرض الأب.
    var onBack: (() -> Void)? = nil
    // المحتوى الداخلي الذي تتكون منه هذه الواجهة.
    @ViewBuilder var content: Content

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        ZStack {
            PlanTheme.background.ignoresSafeArea()

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 0) {
                PlanTopBar(title: title, onBack: onBack)

                PlanSectionPicker(selection: $selection)
                    .padding(.bottom, 10)

                Divider()

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Plan page (intentionally empty for now)

/// The "Plan" page. Empty until the team decides what goes here; it only shows
/// the palm backdrop from the design (invisible if the image isn't in Assets).
struct PlanView: View {
    // عنوان المقرر المعروض في الصفحة.
    var courseTitle: String = "Plan"
    // معرّف المقرر المرتبط؛ nil يعني عدم الارتباط بمقرر.
    var courseID: Course.ID? = nil
    /// Passed in by MainTabView.
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    var viewModel: PlanViewModel? = nil
    // هل يظهر زر الرجوع؟
    var showsBackButton: Bool = false

    /// Set by CourseFlowView so the switcher can move between pages.
    /// When nil (for example MainTabView creates PlanView directly), the page
    /// wraps itself in a CourseFlowView so the switcher still works.
    // التبويب المحدد الذي يقرر المحتوى المعروض.
    var selection: Binding<PlanScreenTab>? = nil
    // إجراء الرجوع الذي يمرره العرض الأب.
    var onBack: (() -> Void)? = nil

    // المهام المرتبطة بالمقرر الحالي، أو جميع المهام عند عدم تحديد مقرر.
    private var planTasks: [StudyTask] {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard let viewModel else { return [] }
        guard let courseID else { return viewModel.tasks }
        return viewModel.tasks.filter { $0.courseID == courseID }
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        if let selection {
            PlanPageScaffold(title: courseTitle, selection: selection, onBack: onBack) {
                GeneratedPlanSchedule(tasks: planTasks)
            }
        } else {
            CourseFlowView(course: nil,
                           viewModel: viewModel,
                           showsBackButton: showsBackButton,
                           startingAt: .plan)
        }
    }
}

private struct GeneratedPlanSchedule: View {
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    let tasks: [StudyTask]

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        if tasks.isEmpty {
            ContentUnavailableView(
                "No Study Plan Yet",
                systemImage: "calendar.badge.plus",
                description: Text("Create a course and generate its plan from the Add Course page.")
            )
        } else {
            // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(PlanTheme.deepClay, in: Circle())

                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundStyle(PlanTheme.text)

                                if let concept = task.concept, !concept.isEmpty {
                                    Text(concept)
                                        .font(.subheadline)
                                        .foregroundStyle(PlanTheme.text.opacity(0.7))
                                }

                                HStack(spacing: 12) {
                                    if let dueDate = task.dueDate {
                                        Label(
                                            dueDate.formatted(date: .abbreviated, time: .shortened),
                                            systemImage: "calendar"
                                        )
                                    }
                                    if let minutes = task.durationMinutes {
                                        Label("\(minutes) min", systemImage: "clock")
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(PlanTheme.mauve)
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(16)
                        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(20)
            }
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        CourseFlowView(
            course: Course(title: "Swift Basics"),
            viewModel: AppDependencies().planViewModel,
            showsBackButton: true,
            startingAt: .plan
        )
    }
}
