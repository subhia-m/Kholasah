// MARK: - شرح الملف
// يجمع بيانات المقرر وملفات الدراسة وإعدادات الخطة، ثم ينسق إنشاء المقرر وتوليد خطته.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct CourseView: View {
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
    @State private var motivationType = "Choose a type"
    // الأهداف المدخلة في النموذج.
    @State private var goals = ""
    // الأهداف الإضافية المدخلة.
    @State private var additionalGoals = ""

    // Upload states
    // يتحكم في ظهور منتقي الملفات.
    @State private var showFileImporter = false
    // روابط الملفات التي اختارها المستخدم.
    @State private var selectedFiles: [URL] = []
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


    // الخيارات المعروضة للدافع؛ القيم الحالية تتضمن نصوصًا تجريبية.
    private let motivationTypes = [
        "bbbbb",
        "aaaaa",
        "ccccc",
        "ddddd",
        "Other"
    ]

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
            VStack(spacing: 0) {
                
                // MARK: Header
                
                Text("Add Course")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(titleBrown)
                    // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // MARK: Form
                
                // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // Course Name
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Course Name:")
                            
                            // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
                            TextField(
                                "Enter course name",
                                text: $courseName
                            )
                            .padding(.horizontal, 18)
                            .frame(height: 70)
                            .background(fieldBackground)
                            .textInputAutocapitalization(.words)
                        }
                        
                        // Start Date and End Date
                        // يرتب العناصر أفقيًا.
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("Start Date:")
                                
                                DatePicker(
                                    "Start Date",
                                    selection: $startDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                                // ينفذ الإجراء عند تغير القيمة المراقبة.
                                .onChange(of: startDate) { _, newStartDate in
                                    if endDate < newStartDate {
                                        endDate = newStartDate
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                fieldLabel("End Date:")
                                
                                DatePicker(
                                    "End Date",
                                    selection: $endDate,
                                    in: startDate...,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 64,
                                    alignment: .leading
                                )
                                .padding(.leading, 12)
                                .background(fieldBackground)
                            }
                        }
                        
                        // Motivation Type
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Motivation Type:")
                            
                            Picker(
                                "Motivation Type",
                                selection: $motivationType
                            ) {
                                Text("Choose a type")
                                    .tag("Choose a type")
                                
                                // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
                                ForEach(
                                    motivationTypes,
                                    id: \.self
                                ) { type in
                                    Text(type)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(darkBrown)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 70,
                                alignment: .leading
                            )
                            .padding(.horizontal, 18)
                            .background(fieldBackground)
                        }
                        
                        // Goals
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Goals:")
                            
                            TextField(
                                "What do you want to achieve?",
                                text: $goals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // Tasks
                        VStack(alignment: .leading, spacing: 0) {
                            fieldLabel("Tasks:")
                            
                            TextField(
                                "Add your tasks",
                                text: $additionalGoals,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding(18)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 95,
                                alignment: .topLeading
                            )
                            .background(fieldBackground)
                        }
                        
                        // MARK: Course Materials
                        VStack(alignment: .leading, spacing: 8) {
                            fieldLabel("Course Materials:")
                            
                            // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                            Button {
                                showFileImporter = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 21))
                                        .foregroundStyle(darkBrown)
                                    
                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {
                                        Text("Upload materials")
                                            .font(.system(size: 15))
                                            .foregroundStyle(darkBrown)
                                        
                                        Text(planViewModel?.importedMaterial?.fileName ?? "No file selected")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 62
                                )
                                .background(fieldBackground)
                            }
                            .buttonStyle(.plain)
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
                                    .font(.caption)
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
                                .font(.system(size: 20))
                                .fontWeight(.bold)
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
        }
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
                selectedFiles = urls
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
                startingAt: .plan
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

    // يبني عنوان حقل إدخال بالتنسيق المشترك.
    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .regular))
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
                if let onPlanGenerated {
                    onPlanGenerated(course)
                } else {
                    generatedCourse = course
                }
            } else {
                coursesViewModel.removeCourse(id: course.id)
                alertMessage = planViewModel.planGenerationError ?? "Unable to generate the study plan."
                showAlert = true
            }
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
