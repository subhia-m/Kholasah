// MARK: - شرح الملف
// يعرض المهام ويتيح إضافتها وإعادة تسميتها وتبديل الإنجاز وحذفها؛ يرسل التغييرات إلى الواجهة الأب عبر closures.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// MARK: - Legacy type

// Identifiable يوفر هوية للعنصر؛ Equatable للمقارنة، وHashable لاستخدامه في المجموعات إن كانا مذكورين.
struct PlanTaskItem: Identifiable, Equatable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    var id = UUID()
    // العنوان المستخدم لهذا العنصر.
    var title: String
    // حالة إنجاز المهمة المعروضة.
    var isDone: Bool = false
    // موعد المهمة الاختياري.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var dueDate: Date?
    // مدة الدراسة المقدرة بالدقائق.
    var durationMinutes: Int?
    // المفهوم الذي تتناوله المهمة.
    var concept: String?
    // شرح المفهوم المستخرج من المادة.
    var explanation: String?
    // النقاط الأساسية التي تساعد على مراجعة المفهوم.
    var keyPoints: [String] = []
    // سؤال مراجعة لاختبار فهم المفهوم.
    var reviewPrompt: String?
    // النص التحفيزي المرتبط بتذكير المهمة.
    var reminderMessage: String?
}

// MARK: - Tasks page

struct TasksView: View {
    // عنوان المقرر المعروض في الصفحة.
    var courseTitle: String = "Plan"
    // التبويب المحدد الذي يقرر المحتوى المعروض.
    // @Binding رابط قراءة وكتابة إلى قيمة يملكها العرض الأب، حتى ينعكس التعديل في الطرفين.
    @Binding var selection: PlanScreenTab
    // إجراء الرجوع الذي يمرره العرض الأب.
    var onBack: (() -> Void)? = nil
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask]
    // إجراء إرسال بيانات العنصر الجديد إلى الأب.
    var onAdd: (String) -> Void
    // إجراء طلب تبديل حالة الإنجاز أو المؤقت وفق المكوّن.
    var onToggle: (StudyTask) -> Void
    // إجراء إرسال عنوان المهمة الجديد.
    var onRename: (StudyTask, String) -> Void
    // إجراء طلب حذف العنصر المحدد.
    var onDelete: (StudyTask) -> Void

    // يتحكم في ظهور نافذة إضافة عنصر.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var showingAddSheet = false
    // المهمة الجاري تعديل عنوانها.
    @State private var editingTask: StudyTask?

    // عدد المهام المكتملة.
    private var doneCount: Int { tasks.filter(\.isCompleted).count }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        PlanPageScaffold(title: courseTitle, selection: $selection, onBack: onBack) {
            content
        }
    }

    // المحتوى الداخلي الذي تتكون منه هذه الواجهة.
    private var content: some View {
        
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 0) {
           
            PlanCard {
                // يرتب العناصر أفقيًا.
                HStack {
                    Spacer()
                    PlanAddButton(label: "Add task") { showingAddSheet = true }
                }
                // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 17)

                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack(spacing: 8) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 22))
                        if !tasks.isEmpty {
                            Text("\(doneCount) of \(tasks.count) done")
                                .font(.system(size: 13))
                                .opacity(0.7)
                        }
                    }
                    .foregroundStyle(PlanTheme.text)
                    .padding(.horizontal, 18)
                    .padding(.top, 16)

                    if tasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .padding(.top, 16)
        }
        // NEW: the add sheet uses the shared editor sheet
        .sheet(isPresented: $showingAddSheet) {
            PlanTaskEditorSheet(heading: "New Task", buttonTitle: "Add") { title in
                withAnimation { onAdd(title) }
            }
            .presentationDetents([.height(230)])
            .presentationDragIndicator(.visible)
        }
        // NEW: the edit sheet, opened with the task's current title filled in
        .sheet(item: $editingTask) { task in
            PlanTaskEditorSheet(heading: "Edit Task",
                                buttonTitle: "Save",
                                initialText: task.title) { title in
                withAnimation { onRename(task, title) }
            }
            .presentationDetents([.height(230)])
            .presentationDragIndicator(.visible)
        }
    }

    // واجهة بديلة تظهر عندما تكون القائمة فارغة.
    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No tasks yet")
                .font(.system(size: 16, weight: .medium))
            Text("Tap + to add your first task.")
                .font(.system(size: 13))
                .opacity(0.6)
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        // يضبط مساحة تخطيط العنصر ومحاذاته.
        .frame(maxWidth: .infinity)
    }

    // قائمة صفوف المهام وإجراءات التعامل معها.
    private var taskList: some View {
        List {
            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(tasks) { task in
                PlanTaskRow(task: task) {
                    withAnimation(.easeInOut(duration: 0.2)) { onToggle(task) }
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                // NEW: swipe left on a task to delete or edit it
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                    Button(role: .destructive) {
                        withAnimation { onDelete(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        editingTask = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(PlanTheme.mauve)
                }
                // NEW: or press and hold
                .contextMenu {
                    Button {
                        editingTask = task
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        withAnimation { onDelete(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Row

private struct PlanTaskRow: View {
    // بيانات المهمة المعروضة.
    let task: StudyTask
    // إجراء طلب تبديل حالة الإنجاز أو المؤقت وفق المكوّن.
    let onToggle: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(PlanTheme.deepClay)
            }
            .buttonStyle(.plain)
            // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
            .accessibilityLabel(task.isCompleted ? "Mark as not completed" : "Mark as completed")

            NavigationLink {
                TaskDetailView(task: task)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16))
                        .strikethrough(task.isCompleted)

                    HStack(spacing: 8) {
                        // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
                        if let dueDate = task.dueDate {
                            Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        }
                        if let durationMinutes = task.durationMinutes {
                            Text("\(durationMinutes) min")
                        }
                    }
                    .font(.caption)
                    .opacity(0.65)
                }
                .foregroundStyle(PlanTheme.text.opacity(task.isCompleted ? 0.45 : 1))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens task details")
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Add / edit sheet (NEW: one sheet used for both adding and editing)

private struct PlanTaskEditorSheet: View {
    // عنوان نافذة التحرير.
    let heading: String
    // عنوان زر التأكيد.
    let buttonTitle: String
    // إجراء تمرير بيانات الحفظ إلى الجهة المالكة.
    let onSave: (String) -> Void

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // العنوان المستخدم لهذا العنصر.
    @State private var title: String
    // هل حقل الإدخال يمتلك تركيز لوحة المفاتيح؟
    // @FocusState يربط حالة التركيز بحقول الإدخال للتحكم بلوحة المفاتيح.
    @FocusState private var isFocused: Bool

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(heading: String,
         buttonTitle: String,
         initialText: String = "",
         onSave: @escaping (String) -> Void) {
        self.heading = heading
        self.buttonTitle = buttonTitle
        self.onSave = onSave
        _title = State(initialValue: initialText)
    }

    // النص بعد إزالة الفراغات والأسطر من طرفيه.
    private var trimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(heading)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(PlanTheme.text)

            // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
            TextField("What do you need to do?", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(save)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .font(.system(size: 16))
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button(buttonTitle, action: save)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.deepClay))
                    .opacity(trimmed.isEmpty ? 0.4 : 1)
                    .disabled(trimmed.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(PlanTheme.background.ignoresSafeArea())
        // ينفذ الإجراء عند ظهور الواجهة.
        .onAppear { isFocused = true }
    }

    // يتحقق من العنوان ثم يرسل الحفظ إلى الأب ويغلق نافذة التحرير.
    private func save() {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard !trimmed.isEmpty else { return }
        onSave(trimmed)
        dismiss()
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        CourseFlowView(course: Course(title: "Plan"), showsBackButton: true, startingAt: .tasks)
    }
}
