// MARK: - شرح الملف
// يعرض ملخص إنجاز المهام والتذكير القادم. عدادات الأيام هنا مدخلات افتراضية وليست حسابًا تلقائيًا من المهام.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// MARK: - Overview page

struct PlanOverviewView: View {
    var courseTitle: String = "Plan"
    @Binding var selection: PlanScreenTab
    // إجراء الرجوع الذي يمرره العرض الأب.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var onBack: (() -> Void)? = nil
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask] = []
    // تذكيرات الواجهة المعروضة.
    var reminders: [PlanReminderItem] = []
    var daysDone: Int = 0                    // NEW
    var daysTotal: Int = 0                   // NEW

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        PlanPageScaffold(title: courseTitle, selection: $selection, onBack: onBack) {
            PlanOverviewContent(tasks: tasks,
                                reminders: reminders,
                                daysDone: daysDone,          // NEW
                                daysTotal: daysTotal)        // NEW
        }
    }
}

// MARK: - Overview tab content

private struct PlanOverviewContent: View {
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    var tasks: [StudyTask] = []
    // تذكيرات الواجهة المعروضة.
    var reminders: [PlanReminderItem] = []
    // Passed in by CourseFlowView, worked out from the due dates of the course's tasks.
    var daysDone: Int = 0
    // إجمالي الأيام الممرر للواجهة.
    var daysTotal: Int = 0

    // MARK: Derived data

    // عدد المهام المكتملة.
    private var tasksDone: Int { tasks.filter(\.isCompleted).count }

    // نسبة إنجاز المهام.
    private var taskProgress: Double {
        tasks.isEmpty ? 0 : Double(tasksDone) / Double(tasks.count)
    }

    // نسبة إنجاز الأيام.
    private var dayProgress: Double {
        daysTotal == 0 ? 0 : Double(daysDone) / Double(daysTotal)
    }

    // أقرب تذكير قادم ومفعّل بحسب شروط التصفية.
    private var nextReminder: PlanReminderItem? {
        reminders
            .filter { $0.isOn && $0.date >= Date() }
            .min { $0.date < $1.date }
    }

    // المهمة غير المكتملة التي تختارها شروط الفرز أدناه.
    private var newestOpenTask: StudyTask? {
        tasks.last { !$0.isCompleted }
    }

    // MARK: Body

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
        ScrollView(showsIndicators: false) {
            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(alignment: .leading, spacing: 14) {

                // Upcoming reminder
                header(systemImage: "bell", title: "Upcoming Reminder:")
                // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                    //PlanPalmLeaf().padding(6)

                    // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
                    if let reminder = nextReminder {
                        VStack(spacing: 4) {
                            Text(reminder.title)
                                .font(.system(size: 17, weight: .medium))
                            Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 13))
                                .opacity(0.7)
                        }
                        .foregroundStyle(PlanTheme.text)
                        // يضبط مساحة تخطيط العنصر ومحاذاته.
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        emptyLabel("No upcoming reminders", color: PlanTheme.text)
                    }
                }
                .frame(height: 120)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                // New task
                header(systemImage: "list.clipboard", title: "New Task:")
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PlanTheme.mauve)
                    if let task = newestOpenTask {
                        Text(task.title)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                            .padding(.horizontal, 16)
                    } else {
                        emptyLabel("No tasks yet", color: .white)
                    }
                }
                .frame(height: 120)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                // Course progress
                header(systemImage: "chart.bar", title: "Course Progress :")
                // يرتب العناصر أفقيًا.
                HStack {
                    Spacer()

                    VStack(spacing: 10) {
                        ZStack {
                            ring(progress: taskProgress)
                            VStack(spacing: 0) {
                                Text("\(tasksDone)")
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 1)
                                Text("\(tasks.count)")
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                        }
                        Text("\(tasksDone) / \(tasks.count) Tasks")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(spacing: 10) {
                        ZStack {
                            ring(progress: dayProgress)
                            Image(systemName: "stopwatch")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        Text("\(daysDone) / \(daysTotal) Days")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }

                    Spacer()
                }
                .padding(.vertical, 90)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PlanTheme.progressBrown)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .accessibilityElement(children: .ignore)
                // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                .accessibilityLabel("Course progress")
                .accessibilityValue("\(tasksDone) of \(tasks.count) tasks, \(daysDone) of \(daysTotal) days")
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 16)
        }
    }

    // MARK: Helpers

    // يبني عنوان القسم مع الرمز المرتبط به.
    private func header(systemImage: String, title: String) -> some View {
        Label {
            Text(title).font(.system(size: 13))
        } icon: {
            Image(systemName: systemImage).font(.system(size: 14))
        }
        .foregroundStyle(PlanTheme.text)
    }

    // يبني النص المعروض عند غياب المحتوى.
    private func emptyLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(color.opacity(0.6))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // يرسم مؤشر تقدم دائري وفق النسبة الممررة.
    private func ring(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 60, height: 60)
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // Opens the whole flow on this page, so the switcher can reach every other page.
    // Use Live mode in the canvas (the play button) to tap around.
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        CourseFlowView(course: Course(title: "Plan"), showsBackButton: true, startingAt: .overview)
    }
}
