// MARK: - شرح الملف
// يعرض وقت جلسة التركيز والتقدم وأزرار المؤقت وملاحظة محلية للواجهة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct PomodoroView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: FocusViewModel
    // الملاحظة النصية الخاصة بجلسة العرض.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var note = ""

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 34) {
            PomodoroDial(
                remainingSeconds: viewModel.remainingSeconds,
                progress: viewModel.progress
            )

            PomodoroTimerControls(
                timerState: viewModel.timerState,
                onToggle: viewModel.toggleTimer,
                onReset: viewModel.reset
            )

            PomodoroNoteEditor(note: $note)
        }
        // يضبط مساحة تخطيط العنصر ومحاذاته.
        .frame(maxWidth: .infinity)
        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
        .padding(.vertical, 8)
    }
}

private struct PomodoroDial: View {
    // الثواني المتبقية في المؤقت.
    let remainingSeconds: Int
    // نسبة التقدم التي تستخدمها الواجهة.
    let progress: Double

    // الوقت بعد تحويله إلى صيغة دقائق وثوانٍ.
    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            Circle()
                .stroke(.black.opacity(0.12), lineWidth: 5)

            // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
            ForEach(0..<60, id: \.self) { index in
                Capsule()
                    .fill(
                        index.isMultiple(of: 5)
                            ? AppColors.date
                            : .black.opacity(0.18)
                    )
                    .frame(
                        width: index.isMultiple(of: 5) ? 3 : 2,
                        height: index.isMultiple(of: 5) ? 13 : 6
                    )
                    .offset(y: -137)
                    .rotationEffect(.degrees(Double(index) * 6))
            }

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.date,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(AppColors.date)
                .frame(width: 22, height: 22)
                .shadow(color: AppColors.date.opacity(0.4), radius: 7)
                .offset(y: -150)
                .rotationEffect(.degrees(progress * 360))

            VStack(spacing: 20) {
                Text("\(remainingSeconds) SEC")
                    .font(AppTypography.captionEmphasized)
                    .foregroundStyle(.secondary)

                Text(formattedTime)
                    .font(AppTypography.timer)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                    .monospacedDigit()
                    .foregroundStyle(AppColors.burgundy)
            }
        }
        .frame(width: 310, height: 310)
            .animation(.linear(duration: 0.2), value: progress)
            .accessibilityElement(children: .ignore)
            // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
            .accessibilityLabel("Time remaining")
            .accessibilityValue(formattedTime)
    }
}

private struct PomodoroTimerControls: View {
    // الحالة الحالية للمؤقت.
    let timerState: PomodoroTimerState
    // إجراء طلب تبديل حالة الإنجاز أو المؤقت وفق المكوّن.
    let onToggle: () -> Void
    // إجراء إعادة ضبط المؤقت.
    let onReset: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر أفقيًا.
        HStack(spacing: 12) {
            // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
            Button(primaryButtonTitle, action: onToggle)
                .font(AppTypography.button)
                .foregroundStyle(.primary)
                .frame(width: 170)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.white, AppColors.lightPage.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(.white, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)

            Button("Reset Timer", systemImage: "arrow.counterclockwise", action: onReset)
                .labelStyle(.iconOnly)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.burgundy)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.7), in: Circle())
                .accessibilityLabel("Reset Timer")
        }
    }

    // عنوان زر المؤقت وفق حالته الحالية.
    private var primaryButtonTitle: LocalizedStringKey {
        switch timerState {
        case .idle:
            "Start Timer"
        case .running:
            "Pause Timer"
        case .paused:
            "Resume Timer"
        case .completed:
            "Start Again"
        }
    }
}

private struct PomodoroNoteEditor: View {
    // الملاحظة النصية الخاصة بجلسة العرض.
    // @Binding رابط قراءة وكتابة إلى قيمة يملكها العرض الأب، حتى ينعكس التعديل في الطرفين.
    @Binding var note: String

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Write a Note")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.burgundy)

            HStack(spacing: 10) {
                // حقل إدخال نص؛ الربط $ يكتب إدخال المستخدم في الخاصية المرتبطة.
                TextField("Write a note…", text: $note)
                    .textFieldStyle(.plain)

                Image(systemName: "pencil")
                    .foregroundStyle(AppColors.burgundy)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.neutralGray, lineWidth: 1)
            }
        }
        .padding(.horizontal, 12)
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    PomodoroView(viewModel: AppDependencies().focusViewModel)
        .padding(.horizontal, 12)
        .background(AppColors.lightPage)
}
