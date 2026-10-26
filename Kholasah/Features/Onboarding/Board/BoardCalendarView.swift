import SwiftUI

struct BoardCalendarView: View {
    let viewModel: BoardViewModel
    @ScaledMetric(relativeTo: .body) private var dayHeight = 32

    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(viewModel.displayedMonth.formatted(
                    .dateTime.month(.wide).year().locale(Locale(identifier: "en_US"))
                ))
                .font(.subheadline.weight(.semibold))
                Spacer(minLength: 0)
                Button { viewModel.moveMonth(-1) } label: {
                    Image(systemName: "chevron.left").frame(width: 36, height: 36)
                }
                .accessibilityLabel("Previous month")
                Button { viewModel.moveMonth(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 36, height: 36)
                }
                .accessibilityLabel("Next month")
            }
            Divider()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 3) {
                ForEach(0..<7) { index in
                    Text(viewModel.calendar.shortWeekdaySymbols[index].uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.secondaryText)
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
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .boardCard()
    }

    private func day(_ date: Date) -> some View {
        let selected = viewModel.calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let today = viewModel.calendar.isDateInToday(date)
        return Button {
            viewModel.selectedDate = date
        } label: {
            Text("\(viewModel.calendar.component(.day, from: date))")
                .font(.body)
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

extension View {
    func boardCard(fill: Color = .white) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: 25))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(AppColors.primary.opacity(0.65), lineWidth: 1)
            }
    }
}
