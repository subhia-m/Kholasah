// MARK: - شرح الملف
// مكونات قائمة مهام اللوحة ونموذج إضافة مهمة وشاشة تفاصيلها.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct BoardTaskList: View {
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    let tasks: [StudyTask]
    // إجراء تبديل إنجاز المهمة.
    let toggle: (StudyTask) -> Void
    // تفاصيل المهمة المتاحة للعرض.
    let details: (StudyTask) -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 0) {
            if tasks.isEmpty {
                Text("No tasks for this day")
                    .foregroundStyle(AppColors.secondaryText)
                    // يضبط مساحة تخطيط العنصر ومحاذاته.
                    .frame(maxWidth: .infinity, minHeight: 110)
            }
            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(tasks) { task in
                VStack(spacing: 0) {
                    // يرتب العناصر أفقيًا.
                    HStack(spacing: 4) {
                        // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                        Button { toggle(task) } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle" : "circle")
                                .font(AppTypography.sectionTitle)
                                .frame(width: 44, height: 44)
                        }
                        // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                        .accessibilityLabel(task.isCompleted ? "Mark \(task.title) incomplete" : "Complete \(task.title)")
                        Button { details(task) } label: {
                            HStack(spacing: 8) {
                                Text(task.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "alarm")
                                Text(task.durationMinutes.map { "\($0) min" } ?? "— min")
                                    .font(AppTypography.subheadline)
                                Image(systemName: "chevron.right")
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .accessibilityHint("Opens task details")
                    }
                    if task.id != tasks.last?.id { Divider() }
                }
            }
        }
        .buttonStyle(.plain)
        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .boardCard()
    }
}

struct BoardAddTaskView: View {
    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // العنوان المستخدم لهذا العنصر.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var title = ""
    // مدة المهمة كما أُدخلت نصيًا، ثم تُحوّل إلى عدد.
    @State private var minutes = "25"
    // التاريخ المرتبط بالعنصر.
    @State private var date: Date
    // الحقل الذي يمتلك تركيز لوحة المفاتيح.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    // @FocusState يربط حالة التركيز بحقول الإدخال للتحكم بلوحة المفاتيح.
    @FocusState private var focusedField: Field?
    // ارتفاع النافذة السفلية المختار.
    @State private var selectedDetent: PresentationDetent = .medium
    // إجراء تمرير بيانات الحفظ إلى الجهة المالكة.
    let onSave: (String, Date, Int) -> Void

    private enum Field: Hashable {
        case name
        case duration
    }

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(date: Date, onSave: @escaping (String, Date, Int) -> Void) {
        _date = State(initialValue: date)
        self.onSave = onSave
    }

    // نتيجة التحقق من صلاحية مدخلات المهمة.
    private var valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(minutes) ?? 0) > 0
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
        NavigationStack {
            // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task name")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(.secondary)
                        // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
                        TextField("Enter task name", text: $title)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 44)
                            .focused($focusedField, equals: .name)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                            .accessibilityLabel("Task name")
                    }
                    .padding(.vertical, 12)

                    Divider()

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .frame(minHeight: 52)
                        .padding(.vertical, 4)
                        .simultaneousGesture(TapGesture().onEnded { focusedField = nil })

                    Divider()

                    LabeledContent("Duration") {
                        HStack(spacing: 6) {
                            TextField("Minutes", text: $minutes)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .frame(minWidth: 44, maxWidth: 88, minHeight: 44)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .duration)
                                .accessibilityLabel("Duration in minutes")
                            Text("min")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minHeight: 52)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(20)
            }
            .background {
                AppColors.background
                    .ignoresSafeArea()
            }
            .onTapGesture { focusedField = nil }
            .font(AppTypography.body)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        focusedField = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
                        guard valid, let duration = Int(minutes) else { return }
                        focusedField = nil
                        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), date, duration)
                        dismiss()
                    }
                    .disabled(!valid)
                }
            }
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(AppColors.primary)
        .presentationBackground(AppColors.background)
        .presentationDetents([.medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        // ينفذ الإجراء عند تغير القيمة المراقبة.
        .onChange(of: focusedField) { _, field in
            if field != nil {
                selectedDetent = .large
            }
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview("New Task Sheet") {
    BoardAddTaskView(date: .now) { _, _, _ in }
}

struct BoardTaskDetailView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: BoardViewModel
    // معرّف المهمة المطلوب عرضها.
    let taskID: StudyTask.ID
    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    @Environment(\.dismiss) private var dismiss

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        NavigationStack {
            Form {
                // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
                if let task = viewModel.repository.tasks.first(where: { $0.id == taskID }) {
                    LabeledContent("Name", value: task.title)
                    if let date = task.dueDate {
                        LabeledContent("Date", value: date.formatted(date: .long, time: .omitted))
                    }
                    LabeledContent("Duration", value: task.durationMinutes.map { "\($0) min" } ?? "Not set")
                    LabeledContent("Status", value: task.isCompleted ? "Completed" : "Not completed")
                    Button(task.isCompleted ? "Mark incomplete" : "Mark completed") {
                        viewModel.toggle(task)
                    }
                }
            }
            .navigationTitle("Task Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
        }
        .tint(AppColors.primary)
    }
}
