// MARK: - شرح الملف
// يعرض تذكيرات الواجهة ويتيح إضافة تذكير وتغيير حالته وحذفه عبر إجراءات يمررها الأب.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// MARK: - Reminders page

struct RemindersView: View {
    // عنوان المقرر المعروض في الصفحة.
    var courseTitle: String = "Plan"
    // التبويب المحدد الذي يقرر المحتوى المعروض.
    // @Binding رابط قراءة وكتابة إلى قيمة يملكها العرض الأب، حتى ينعكس التعديل في الطرفين.
    @Binding var selection: PlanScreenTab
    // إجراء الرجوع الذي يمرره العرض الأب.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var onBack: (() -> Void)? = nil
    // تذكيرات الواجهة المعروضة.
    var reminders: [PlanReminderItem]
    // إجراء إرسال بيانات العنصر الجديد إلى الأب.
    var onAdd: (String, Date) -> Void
    // إجراء تغيير حالة تفعيل تذكير الواجهة.
    var onSetEnabled: (PlanReminderItem, Bool) -> Void
    // إجراء طلب حذف العنصر المحدد.
    var onDelete: (PlanReminderItem) -> Void

    // يتحكم في ظهور نافذة إضافة عنصر.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var showingAddSheet = false

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
                    PlanAddButton(label: "Add reminder") { showingAddSheet = true }
                }
                // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 17)
                
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundStyle(PlanTheme.text)
                        .padding(.horizontal, 18)
                        .padding(.top, 16)

                    if reminders.isEmpty {
                        emptyState
                    } else {
                        reminderList
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .padding(.top, 16)

        }
        // يعرض نافذة فوق الشاشة اعتمادًا على حالة العرض أو العنصر المحدد.
        .sheet(isPresented: $showingAddSheet) {
            PlanAddReminderSheet { title, date in
                withAnimation { onAdd(title, date) }
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }

    // واجهة بديلة تظهر عندما تكون القائمة فارغة.
    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            Text("No reminders yet")
                .font(AppTypography.headline)
            Text("Tap + to add one.")
                .font(AppTypography.caption)
                .opacity(0.6)
            Spacer()
        }
        .foregroundStyle(PlanTheme.text)
        // يضبط مساحة تخطيط العنصر ومحاذاته.
        .frame(maxWidth: .infinity)
    }

    // قائمة صفوف التذكيرات وإجراءات التعامل معها.
    private var reminderList: some View {
        List {
            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(reminders) { reminder in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .font(AppTypography.headline)
                        Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTypography.caption)
                            .opacity(0.6)
                    }
                    .foregroundStyle(PlanTheme.text)
                    .opacity(reminder.isOn ? 1 : 0.5)

                    Spacer()

                    Toggle("Reminder on", isOn: Binding(
                        get: { reminder.isOn },
                        set: { onSetEnabled(reminder, $0) }
                    ))
                    .labelsHidden()
                    .tint(PlanTheme.deepClay)
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(PlanTheme.text.opacity(0.12))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                    Button(role: .destructive) {
                        withAnimation { onDelete(reminder) }
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

// MARK: - Add sheet

private struct PlanAddReminderSheet: View {
    // إجراء إرسال بيانات العنصر الجديد إلى الأب.
    let onAdd: (String, Date) -> Void

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // العنوان المستخدم لهذا العنصر.
    @State private var title = ""
    // التاريخ المرتبط بالعنصر.
    @State private var date = Date().addingTimeInterval(3600)
    // هل حقل الإدخال يمتلك تركيز لوحة المفاتيح؟
    // @FocusState يربط حالة التركيز بحقول الإدخال للتحكم بلوحة المفاتيح.
    @FocusState private var isFocused: Bool

    // النص بعد إزالة الفراغات والأسطر من طرفيه.
    private var trimmed: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Reminder")
                .font(AppTypography.title)
                .foregroundStyle(PlanTheme.text)

            // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
            TextField("Remind me to...", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PlanTheme.controlBackground)
                )

            DatePicker("When", selection: $date,
                       displayedComponents: [.date, .hourAndMinute])
                .tint(PlanTheme.deepClay)
                .foregroundStyle(PlanTheme.text)

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .font(AppTypography.body)
                    .foregroundStyle(PlanTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(PlanTheme.chip))

                Button("Add") {
                    // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, date)
                    dismiss()
                }
                .font(AppTypography.button)
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
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        CourseFlowView(course: Course(title: "Plan"), showsBackButton: true, startingAt: .reminders)
    }
}
