// MARK: - شرح الملف
// يعرض تفاصيل مهمة واحدة، بما فيها المفهوم والشرح والنقاط الأساسية وسؤال المراجعة عند توفرها.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct TaskDetailView: View {
    // بيانات المهمة المعروضة.
    let task: StudyTask

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            PlanTheme.background.ignoresSafeArea()

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 0) {
                PlanTopBar(title: "Task Details", onBack: { dismiss() })

                // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        titleCard
                        details
                    }
                    // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // بطاقة عنوان المهمة وحالتها.
    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                task.isCompleted ? "Completed" : "Upcoming Task",
                systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(PlanTheme.deepClay)

            Text(task.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(PlanTheme.text)
                // يضبط مساحة تخطيط العنصر ومحاذاته.
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    // يسمح بتجميع عدة عناصر وشروط لبناء محتوى SwiftUI.
    @ViewBuilder
    // تفاصيل المهمة المتاحة للعرض.
    private var details: some View {
        // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
        if let concept = task.concept, !concept.isEmpty {
            detailCard(title: "Concept", systemImage: "book.pages", text: concept)
        }

        if let explanation = task.explanation, !explanation.isEmpty {
            detailCard(
                title: "Explanation",
                systemImage: "text.book.closed",
                text: explanation
            )
        }

        if !task.keyPoints.isEmpty {
            keyPointsCard
        }

        if let durationMinutes = task.durationMinutes {
            detailCard(
                title: "Study Duration",
                systemImage: "clock",
                text: "\(durationMinutes) minutes"
            )
        }

        if let dueDate = task.dueDate {
            detailCard(
                title: "Study Time",
                systemImage: "calendar",
                text: dueDate.formatted(date: .abbreviated, time: .shortened)
            )
        }

        if let reviewPrompt = task.reviewPrompt, !reviewPrompt.isEmpty {
            detailCard(
                title: "Review Question",
                systemImage: "questionmark.bubble",
                text: reviewPrompt
            )
        }

        if let reminderMessage = task.reminderMessage, !reminderMessage.isEmpty {
            detailCard(
                title: "Encouragement",
                systemImage: "sparkles",
                text: reminderMessage
            )
        }
    }

    // بطاقة النقاط التعليمية الأساسية.
    private var keyPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Points", systemImage: "list.bullet")
                .font(.headline)
                .foregroundStyle(PlanTheme.deepClay)

            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(task.keyPoints, id: \.self) { point in
                // يرتب العناصر أفقيًا.
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(PlanTheme.deepClay)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)

                    Text(point)
                        .font(.body)
                        .foregroundStyle(PlanTheme.text)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }

    // يبني بطاقة تفصيل بعنوان ورمز ونص.
    private func detailCard(title: LocalizedStringKey, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(PlanTheme.deepClay)

            Text(text)
                .font(.body)
                .foregroundStyle(PlanTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        TaskDetailView(
            task: StudyTask(
                title: "Review Swift functions",
                dueDate: .now,
                durationMinutes: 30,
                concept: "Functions, parameters, and return values",
                explanation: "Functions group reusable behavior and can receive values through parameters.",
                keyPoints: ["Use parameters for input", "Use return values for output"],
                reviewPrompt: "Explain the difference between a parameter and an argument.",
                reminderMessage: "You are close—one focused session to finish this concept."
            )
        )
    }
}
