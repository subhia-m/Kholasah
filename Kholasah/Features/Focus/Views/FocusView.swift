// MARK: - شرح الملف
// يتيح التبديل بين أصوات التركيز ومؤقت بومودورو.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct FocusView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: FocusViewModel

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // وضع التركيز المحدد: الصوت أو المؤقت.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var selectedMode = FocusMode.sound

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 20) {
            header
            modePicker

            Group {
                switch selectedMode {
                case .sound:
                    MusicView(audioPlayer: viewModel.audioPlayer)
                case .pomodoro:
                    // يسمح بتمرير المحتوى عندما يتجاوز المساحة المتاحة.
                    ScrollView {
                        PomodoroView(viewModel: viewModel)
                            // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                            .padding(.horizontal, 24)
                            .padding(.top, 22)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            // يضبط مساحة تخطيط العنصر ومحاذاته.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 8)
        .background(AppColors.lightPage.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // الجزء العلوي من الواجهة.
    private var header: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            Text("Focus")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(AppColors.burgundy)

            // يرتب العناصر أفقيًا.
            HStack {
                // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                Button("Back", systemImage: "chevron.backward") {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(AppColors.lightPage, in: Circle())
                // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, 18)
    }

    // أزرار اختيار وضع التركيز.
    private var modePicker: some View {
        HStack(spacing: 0) {
            modeButton(.sound)
            modeButton(.pomodoro)
        }
        .padding(3)
        .background(AppColors.darkPage.opacity(0.55), in: Capsule())
        .padding(.horizontal, 18)
    }

    // يبني زر اختيار وضع التركيز ويحدث الوضع المحدد عند الضغط.
    private func modeButton(_ mode: FocusMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMode = mode
            }
        } label: {
            Text(mode.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedMode == mode ? Color.white : Color.clear,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
    }
}

private enum FocusMode {
    case sound
    case pomodoro

    // العنوان المستخدم لهذا العنصر.
    var title: LocalizedStringKey {
        switch self {
        case .sound:
            "Sound"
        case .pomodoro:
            "Pomodoro"
        }
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        FocusView(viewModel: AppDependencies().focusViewModel)
    }
}
