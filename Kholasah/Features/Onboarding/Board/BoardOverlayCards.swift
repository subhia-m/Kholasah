// MARK: - شرح الملف
// مكونات بطاقات الاستمرارية والتحفيز والإغلاق والاقتباسات التي تظهر في لوحة المهام.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct BoardStreakCard: View {
    // بيانات الاستمرارية المعروضة.
    let streak: BoardStreak
    // التقويم المستخدم لحساب الأيام والشهور.
    let calendar: Calendar
    // إجراء إغلاق البطاقة.
    let close: () -> Void
    // تفضيل المستخدم لتقليل الحركة.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // مساحة أسماء تربط مواضع اللهب في الحركة.
    // مساحة أسماء مشتركة لربط العناصر التي تستخدم تأثيرات انتقال متطابقة.
    @Namespace private var flamePosition

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 12) {
            // يرتب العناصر أفقيًا.
            HStack {
                Spacer()
                Text("Streak!").font(AppTypography.largeTitle)
                Spacer()
                BoardCloseButton(label: "Close streak", action: close)
            }
            HStack(spacing: 3) {
                // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
                ForEach(streak.week(calendar: calendar), id: \.self) { date in
                    VStack(spacing: 3) {
                        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
                        ZStack(alignment: .top) {
                            if streak.count > 0,
                               let last = streak.lastRecordedDay,
                               calendar.isDate(last, inSameDayAs: date) {
                                BoardFlame()
                                    .matchedGeometryEffect(id: "flame", in: flamePosition)
                            }
                            // Draw the fruit last: it masks the lower flame while remaining still.
                            Image("date").resizable().scaledToFit()
                                // يضبط مساحة تخطيط العنصر ومحاذاته.
                                .frame(height: 34)
                                // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                                .padding(.top, 14)
                        }
                        .frame(height: 48)
                        Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US"))))
                            .font(.system(.caption2, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                    .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
                    .accessibilityValue(isLastDay(date) ? "Latest streak day" : "")
                }
            }
            .background {
                // يوفر حجم المساحة المتاحة ليحسب المحتوى أبعاده بناءً عليها.
                GeometryReader { geometry in
                    Path { path in
                        let inset = geometry.size.width / 14
                        path.move(to: CGPoint(x: inset, y: 31))
                        path.addLine(to: CGPoint(x: geometry.size.width - inset, y: 31))
                    }
                    .stroke(AppColors.date.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 5]))
                }
                .accessibilityHidden(true)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: streak.lastRecordedDay)
            Text("\(streak.count) DAY STREAK")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.date)
        }
        .padding(14)
        .boardFloatingCard()
    }

    // يتحقق مما إذا كان التاريخ يمثل آخر يوم مسجل في الاستمرارية.
    private func isLastDay(_ date: Date) -> Bool {
        streak.count > 0 && streak.lastRecordedDay.map { calendar.isDate($0, inSameDayAs: date) } == true
    }
}

private struct BoardFlame: View {
    // تفضيل المستخدم لتقليل الحركة.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // حالة تستخدم لتحريك رمز اللهب.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var pulsing = false

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        Image("fire").resizable().scaledToFit()
            .frame(width: 26, height: 30)
            .scaleEffect(pulsing ? 1.08 : 0.92, anchor: .bottom)
            .rotationEffect(.degrees(pulsing ? 4 : -4), anchor: .bottom)
            // ينفذ الإجراء عند ظهور الواجهة.
            .onAppear { pulsing = !reduceMotion }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsing)
            .accessibilityHidden(true)
    }
}

struct BoardMotivationCard: View {
    // إجراء إغلاق البطاقة.
    let close: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.max").font(.largeTitle)
            VStack(alignment: .leading, spacing: 3) {
                Text("Keep going!").font(AppTypography.title)
                Text("Every small step counts.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.date)
            }
            Spacer(minLength: 0)
            BoardCloseButton(label: "Dismiss encouragement", action: close)
        }
        .padding(12)
        .boardFloatingCard()
    }
}

struct BoardCloseButton: View {
    // النص الذي يصف المكوّن.
    let label: String
    // دالة يمررها المستدعي لتنفيذها عند التفاعل؛ () -> Void تعني أنها لا تأخذ مدخلات ولا تعيد قيمة.
    let action: () -> Void
    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
        Button(action: action) {
            Image(systemName: "xmark").frame(width: 32, height: 32)
        }
        .accessibilityLabel(label)
        .buttonStyle(.plain)
    }
}

// extension يضيف وظائف أو خصائص محسوبة إلى نوع موجود دون تعديل تعريفه الأصلي.
private extension View {
    // يطبق خلفية وشكل البطاقة العائمة المشتركة.
    func boardFloatingCard() -> some View {
        foregroundStyle(AppColors.primary)
            .background(AppColors.card, in: RoundedRectangle(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26).stroke(PlanTheme.text.opacity(0.7), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
    }
}

struct BoardQuotesView: View {
    // فهرس الاقتباس الحالي.
    @State private var index = 0
    // نصوص الاقتباسات التي تتناوب الواجهة على عرضها.
    private let quotes = [
        "You are doing better than you think.",
        "Small steps make great progress.",
        "Your effort today shapes tomorrow.",
        "One task at a time. You’ve got this.",
        "Progress matters more than perfection."
    ]

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        Button {
            index = (index + 1) % quotes.count
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bell.and.waves.left.and.right")
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quotes").font(.subheadline.weight(.semibold))
                    Text("“\(quotes[index])”").font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
            }
            .padding(18)
            .foregroundStyle(.white)
            .boardCard(fill: Color(red: 153 / 255, green: 93 / 255, blue: 72 / 255))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Shows another quote")
    }
}
