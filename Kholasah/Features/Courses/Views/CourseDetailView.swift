// MARK: - شرح الملف
// يجمع بيانات المقرر وملفات الدراسة وإعدادات الخطة، ثم ينسق إنشاء المقرر وتوليد خطته.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI
import UniformTypeIdentifiers
//مكتبة تسمح لنا نحدد انواع الملفات-برفع البي دي اف
import UIKit
//مكتبة ابل
struct CourseView: View {
    @Environment(\.dismiss) private var dismiss
    //يتيح لنا إغلاق الشاشة أو الرجوع للخلف (مثل زر الرجوع في الشريط العلوي).
    //أداة جاهزة من النظام عشان تقفل الشاشة الحالية.
    // نموذج عرض إدارة المقررات.
    let coursesViewModel: CoursesViewModel
    // نموذج عرض الخطة والمهام وتوليد المحتوى.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    let planViewModel: PlanViewModel?
    // إجراء اختياري لإبلاغ المستدعي بالمقرر بعد إنشاء الخطة.
    var onPlanGenerated: ((Course) -> Void)? = nil

    // MARK: - Form Data

    // اسم المقرر الذي يدخله المستخدم.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var courseName = ""
    // تاريخ البداية.
    @State private var startDate = Date()
    // تاريخ النهاية.
    @State private var endDate =
        Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now
    // نوع الدافع المحدد في النموذج.

    // Upload states
    // يتحكم في ظهور منتقي الملفات.
    @State private var showFileImporter = false
    // عدد دقائق الدراسة اليومية.
    @State private var dailyMinutes = 30
    // اختيار تفعيل التذكيرات عند توليد الخطة.
    @State private var remindersEnabled = true
    // الوقت المفضل للدراسة؛ تُستخدم الساعة والدقيقة عند إنشاء المواعيد.
    @State private var preferredStudyTime =
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now) ?? .now
    // المقرر الناتج عن عملية الإنشاء.
    @State private var generatedCourse: Course?

    // Alert
    // يتحكم في ظهور التنبيه.
    @State private var showAlert = false
    // النص المعروض في التنبيه.
    @State private var alertMessage = ""

    // عدد أيام الخطة.
    private var durationDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        return max((calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1, 1)
    }

    // MARK: - Colors

    // لون خلفية الصفحة.
    private let backgroundColor = Color(
        red: 0.96, green: 0.94, blue: 0.92
    )

    // درجة البني الداكن المستخدمة في التصميم.
    private let darkBrown = Color(
        red: 0.31, green: 0.04, blue: 0.01
    )

    // لون العناوين.
    private let titleBrown = Color(
        red: 0.42, green: 0.10, blue: 0.06
    )

    // لون تسميات الحقول.
    private let labelOrange = Color(
        red: 0.73, green: 0.36, blue: 0.16
    )

    // MARK: - Body

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            // يوفر حجم المساحة المتاحة ليحسب المحتوى أبعاده بناءً عليها.
            GeometryReader { geometry in
                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    // يضبط مساحة تخطيط العنصر ومحاذاته.
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .offset(x: -150, y: 102)
                    .opacity(0.2)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 16) {
                
                // MARK: Header
                
                PlanTopBar(title: "Add Course", onBack: { dismiss() })
                    .padding(.top, 12)

                // MARK: Form
                
                // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // Course Name
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Course Name:")
                            
                            // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
                            TextField(
                                "Enter course name",
                                text: $courseName
                            )
                            
                            .padding(.horizontal, 18)
                            .frame(height: 56)
                            .background(fieldBackground)
                            .textInputAutocapitalization(.words)
                        }
                        
                        // MARK: Study dates
                        VStack(alignment: .leading, spacing: 12) {
                            fieldLabel("Study dates")

                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: 12) {
                                    studyDateCard(
                                        title: "Starts",
                                        systemImage: "calendar.badge.plus",
                                        selection: $startDate,
                                        range: Date.distantPast...Date.distantFuture
                                    )
                                    studyDateCard(
                                        title: "Ends",
                                        systemImage: "calendar.badge.checkmark",
                                        selection: $endDate,
                                        range: startDate...Date.distantFuture
                                    )
                                }

                                VStack(spacing: 12) {
                                    studyDateCard(
                                        title: "Starts",
                                        systemImage: "calendar.badge.plus",
                                        selection: $startDate,
                                        range: Date.distantPast...Date.distantFuture
                                    )
                                    studyDateCard(
                                        title: "Ends",
                                        systemImage: "calendar.badge.checkmark",
                                        selection: $endDate,
                                        range: startDate...Date.distantFuture
                                    )
                                }
                            }

                        }
                        .onChange(of: startDate) { _, newStartDate in
                            if endDate < newStartDate {
                                endDate = newStartDate
                            }
                        }

                        // MARK: Course Materials
                        VStack(alignment: .leading, spacing: 12) {
                            fieldLabel("Study material")

                            Button {
                                showFileImporter = true
                            } label: {
                                VStack(spacing: 14) {
                                    Image(systemName: planViewModel?.importedMaterial == nil
                                          ? "arrow.up.doc"
                                          : "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(planViewModel?.importedMaterial == nil
                                                         ? titleBrown
                                                         : AppColors.green)

                                    VStack(spacing: 5) {
                                        Text(planViewModel?.importedMaterial == nil
                                             ? "Upload study material"
                                             : "Material ready")
                                            .font(AppTypography.headline)
                                            .foregroundStyle(darkBrown)

                                        Text(planViewModel?.importedMaterial?.fileName
                                             ?? "Choose a PDF or text file")
                                            .font(AppTypography.caption)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }

                                    Text(planViewModel?.importedMaterial == nil
                                         ? "Choose file"
                                         : "Replace file")
                                        .font(AppTypography.button)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 10)
                                        .background(titleBrown, in: Capsule())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .padding(.horizontal, 16)
                                .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            titleBrown.opacity(0.45),
                                            style: StrokeStyle(lineWidth: 1.5, dash: [7, 6])
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens the document picker")
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            fieldLabel("Study Plan:")

                            Text("Plan duration: \(durationDays) days")

                            Stepper(
                                "Daily study: \(dailyMinutes) minutes",
                                value: $dailyMinutes,
                                in: 15...180,
                                step: 15
                            )

                            Toggle("Daily study reminders", isOn: $remindersEnabled)
                                .tint(titleBrown)

                            if remindersEnabled {
                                DatePicker(
                                    "Preferred study time",
                                    selection: $preferredStudyTime,
                                    displayedComponents: .hourAndMinute
                                )
                            }

                            // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
                            if let planViewModel {
                                Text(planViewModel.aiAvailability.message)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(18)
                        .background(fieldBackground)
                        
                        
                        // MARK: Done Button
                        Button {
                            generatePlan()
                        } label: {
                            Text(planViewModel?.isGeneratingPlan == true ? "Creating plan…" : "Generate study plan")
                                .font(AppTypography.button)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(darkBrown)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 30)
                                )
                        }
                        .disabled(planViewModel?.isGeneratingPlan == true)
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }

            if planViewModel?.isGeneratingPlan == true {
                PlanGenerationLoadingView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.25), value: planViewModel?.isGeneratingPlan == true)
        // MARK: File Importer
        // يفتح منتقي الملفات ويعيد نتيجة الاختيار أو الخطأ إلى المعالج.
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                .pdf,
                .plainText
            ],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
                guard let url = urls.first, let planViewModel else { return }
                Task {
                    await planViewModel.importStudyMaterial(from: url)
                }
            case .failure(let error):
                print("File selection failed: \(error)")
            }
        }
        // MARK: Alert
        .alert(
            "Course",
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        // يربط حالة التنقل بالشاشة التي ستفتح داخل NavigationStack.
        .navigationDestination(item: $generatedCourse) { course in
            CourseFlowView(
                course: course,
                viewModel: planViewModel,
                showsBackButton: true,
                startingAt: .plan,
                onBack: {
                    if let onPlanGenerated {
                        onPlanGenerated(course)
                    } else {
                        dismiss()
                    }
                }
            )
        }
    }

    // MARK: - Reusable Components

    // الخلفية المشتركة لحقول النموذج.
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(.white.opacity(0.92))
            .shadow(
                color: Color.brown.opacity(0.13),
                radius: 10,
                x: 0,
                y: 6
            )
    }

    private func studyDateCard(
        title: LocalizedStringKey,
        systemImage: String,
        selection: Binding<Date>,
        range: ClosedRange<Date>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(AppTypography.subheadlineEmphasized)
                .foregroundStyle(titleBrown)

            DatePicker(
                title,
                selection: selection,
                in: range,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(titleBrown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(titleBrown.opacity(0.1), lineWidth: 1)
        }
        .shadow(color: Color.brown.opacity(0.1), radius: 8, y: 4)
    }

    // يبني عنوان حقل إدخال بالتنسيق المشترك.
    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.sectionTitle)
            .foregroundStyle(titleBrown)
            .padding(.leading, 10)
    }

    // يتحقق من بيانات المقرر والمادة ثم يبدأ مسار إنشاء الخطة.
    private func generatePlan() {
        let normalizedName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else {
            alertMessage = "Please enter a course name before continuing."
            showAlert = true
            return
        }
        guard let planViewModel else {
            alertMessage = "Plan generation is unavailable."
            showAlert = true
            return
        }
        guard planViewModel.importedMaterial != nil else {
            alertMessage = "Please upload a PDF or text file before generating the plan."
            showAlert = true
            return
        }
        guard let course = coursesViewModel.createCourse(title: normalizedName, instructor: "") else {
            alertMessage = coursesViewModel.errorMessage ?? "Unable to create the course."
            showAlert = true
            return
        }

        Task {
            await planViewModel.generateStudyPlan(
                courseID: course.id,
                durationDays: durationDays,
                dailyMinutes: dailyMinutes,
                remindersEnabled: remindersEnabled,
                preferredStudyTime: preferredStudyTime
            )

            if planViewModel.didSaveGeneratedPlan {
                generatedCourse = course
            } else {
                coursesViewModel.removeCourse(id: course.id)
                alertMessage = planViewModel.planGenerationError ?? "Unable to generate the study plan."
                showAlert = true
            }
        }
    }
}

private struct PlanGenerationLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.96, green: 0.94, blue: 0.92))
                    .shadow(color: .black.opacity(0.16), radius: 18, y: 8)

                Image("palm-tree")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190)
                    .offset(x: -74, y: 62)
                    .opacity(0.22)
                    .accessibilityHidden(true)

                VStack(spacing: 18) {
                    Image("date")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 92, height: 92)
                        .rotationEffect(.degrees(isAnimating && !reduceMotion ? 6 : -6))
                        .offset(y: isAnimating && !reduceMotion ? -8 : 2)
                        .accessibilityHidden(true)

                    Text("Creating your study plan")
                        .font(AppTypography.title)
                        .foregroundStyle(Color(red: 0.42, green: 0.10, blue: 0.06))

                    Text("Reading your material and organizing each study day…")
                        .font(AppTypography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    ModernPlanLoader()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(28)
            }
            .frame(maxWidth: 330, minHeight: 330, maxHeight: 330)
            .padding(24)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creating your study plan. Reading your material and organizing each study day.")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct ModernPlanLoader: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let accent = Color(red: 0.42, green: 0.10, blue: 0.06)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            let rotation = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 1.15) / 1.15 * 360

            ZStack {
                Circle()
                    .stroke(accent.opacity(0.13), lineWidth: 6)

                Circle()
                    .trim(from: 0.08, to: 0.72)
                    .stroke(
                        AngularGradient(
                            colors: [accent.opacity(0.15), accent, Color(red: 0.73, green: 0.36, blue: 0.16)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(reduceMotion ? 0 : rotation))

                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 46, height: 46)
        .accessibilityHidden(true)
    }
}

private extension AIModelAvailability {
    var message: LocalizedStringKey {
        switch self {
        case .available:
            "On-device AI is ready"
        case .appleIntelligenceDisabled:
            "Apple Intelligence is disabled"
        case .deviceNotEligible:
            "This device does not support on-device AI"
        case .modelNotReady:
            "The on-device model is still preparing"
        case .unsupportedLanguage:
            "The current language is not supported"
        case .unavailable:
            "On-device AI is unavailable"
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // الحاوية المشتركة للخدمات ونماذج العرض.
    let dependencies = AppDependencies()
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        CourseView(
            coursesViewModel: dependencies.coursesViewModel,
            planViewModel: dependencies.planViewModel
        )
    }
}
