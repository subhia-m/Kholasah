// MARK: - شرح الملف
// يرسم تقويم الشهر ويتيح اختيار يوم وتغيير الشهر المعروض.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct BoardCalendarView: View {
    // نموذج العرض الذي يزوّد هذه الواجهة بالبيانات والإجراءات.
    let viewModel: BoardViewModel
    // ارتفاع خلية اليوم؛ يتدرج مع حجم النص المفضل.
    // يجعل القياس يتغير وفق حجم النص الذي يختاره المستخدم.
    @ScaledMetric(relativeTo: .body) private var dayHeight = 32

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
        VStack(spacing: 5) {
            // يرتب العناصر أفقيًا.
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(viewModel.displayedMonth.formatted(
                    .dateTime.month(.wide).year().locale(Locale(identifier: "en_US"))
                ))
                .font(AppTypography.subheadlineEmphasized)
                Spacer(minLength: 0)
                // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                Button { viewModel.moveMonth(-1) } label: {
                    Image(systemName: "chevron.left").frame(width: 36, height: 36)
                }
                // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                .accessibilityLabel("Previous month")
                Button { viewModel.moveMonth(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 36, height: 36)
                }
                .accessibilityLabel("Next month")
            }
            Divider()
            // شبكة عمودية تنشئ عناصرها عند الحاجة للعرض.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 3) {
                // ينشئ عنصر واجهة لكل قيمة؛ المعرّف يربط العنصر ببياناته أثناء التحديث.
                ForEach(0..<7) { index in
                    Text(viewModel.calendar.shortWeekdaySymbols[index].uppercased())
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.secondaryText)
                        // يضبط مساحة تخطيط العنصر ومحاذاته.
                        .frame(height: 20)
                }
                ForEach(0..<viewModel.leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: dayHeight)
                }
                ForEach(viewModel.monthDays, id: \.self) { date in
                    day(date)
                }
            }
        }
        .buttonStyle(.plain)
        // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .boardCard()
    }

    // يبني خلية يوم في التقويم ويحدد مظهرها وإجراء اختيارها.
    private func day(_ date: Date) -> some View {
        let selected = viewModel.calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let today = viewModel.calendar.isDateInToday(date)
        return Button {
            viewModel.selectedDate = date
        } label: {
            Text("\(viewModel.calendar.component(.day, from: date))")
                .font(AppTypography.body)
                .foregroundStyle(selected ? Color.white : PlanTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: dayHeight)
                .background {
                    if selected {
                        Circle().fill(AppColors.primary)
                            .frame(width: dayHeight, height: dayHeight)
                    }
                }
                .overlay {
                    if today {
                        Circle().stroke(AppColors.date, lineWidth: 1.5)
                            .frame(width: dayHeight, height: dayHeight)
                    }
                }
                .contentShape(Rectangle())
        }
        .accessibilityLabel(date.formatted(
            .dateTime.weekday(.wide).month(.wide).day().year().locale(Locale(identifier: "en_US"))
        ))
        .accessibilityValue(today ? "Today" : "")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// extension يضيف وظائف أو خصائص محسوبة إلى نوع موجود دون تعديل تعريفه الأصلي.
extension View {
    // يطبق تنسيق بطاقة اللوحة المشترك على العرض.
    func boardCard(fill: Color = .white) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: 25))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(AppColors.primary.opacity(0.65), lineWidth: 1)
            }
    }
}

#Preview {
    BoardCalendarView(viewModel: BoardViewModel.preview())
        .padding()
}
