import SwiftUI

struct BoardCalendarView: View {
    let viewModel: BoardViewModel

    var body: some View {
        // Apple's inline single-date calendar supplies month navigation, today styling,
        // accessibility and its natural layout without a fixed height or a custom day grid.
        DatePicker(
            "Task date",
            selection: Binding(
                get: { viewModel.selectedDate },
                set: { date in
                    viewModel.selectedDate = viewModel.calendar.startOfDay(for: date)
                    viewModel.displayedMonth = viewModel.calendar.dateInterval(of: .month, for: date)?.start ?? date
                }
            ),
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .environment(\.calendar, viewModel.calendar)
        .environment(\.locale, Locale(identifier: "en_US"))
        .tint(AppColors.primary)
        .padding(8)
        .boardCard()
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
