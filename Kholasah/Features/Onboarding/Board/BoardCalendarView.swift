import SwiftUI

struct BoardCalendarView: View {
    let viewModel: BoardViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                Text(viewModel.displayedMonth.formatted(.dateTime.month(.wide).year().locale(Locale(identifier: "en_US"))))
                    .font(.headline)
                Spacer()
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 5) {
                ForEach(0..<7) { index in
                    Text(viewModel.calendar.shortWeekdaySymbols[index].uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.secondaryText)
                }
                ForEach(0..<viewModel.leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                ForEach(viewModel.monthDays, id: \.self) { date in
                    day(date)
                }
            }
        }
        .padding(12)
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
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(selected ? Color.white : PlanTheme.text)
                .background {
                    if selected { Circle().fill(AppColors.primary).frame(width: 36, height: 36) }
                }
                .overlay {
                    if today {
                        Circle().stroke(AppColors.date, lineWidth: 2).frame(width: 39, height: 39)
                    }
                }
        }
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
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
