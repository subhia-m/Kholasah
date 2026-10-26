import Foundation
import Observation

/// Replace this fixture with the agreed streak calculation when it is available.
/// Calendar selection and task completion deliberately never update this value.
struct BoardStreak: Equatable {
    var count: Int
    var lastRecordedDay: Date?
    static var demo: BoardStreak { BoardStreak(count: 7, lastRecordedDay: .now) }

    func week(calendar: Calendar, fallback: Date = .now) -> [Date] {
        let anchor = lastRecordedDay ?? fallback
        guard let start = calendar.dateInterval(of: .weekOfYear, for: anchor)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
}

struct BoardMessageTiming {
    var initial: Duration = .seconds(30)
    var interval: Duration = .seconds(300)
    var visible: Duration = .seconds(5)
}

@MainActor
@Observable
final class BoardViewModel {
    let repository: InMemoryTaskRepository
    var selectedDate: Date
    var displayedMonth: Date
    var streak: BoardStreak
    let calendar: Calendar

    init(repository: InMemoryTaskRepository, today: Date = .now, streak: BoardStreak = .demo) {
        self.repository = repository
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1
        self.calendar = calendar
        selectedDate = calendar.startOfDay(for: today)
        displayedMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        self.streak = streak
    }

    var tasks: [StudyTask] {
        repository.tasks.filter { task in
            guard let date = task.dueDate else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    var monthDays: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: displayedMonth) }
    }

    var leadingEmptyDays: Int {
        (calendar.component(.weekday, from: displayedMonth) - calendar.firstWeekday + 7) % 7
    }

    func moveMonth(_ offset: Int) {
        if let next = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = next
        }
    }

    func add(title: String, date: Date, minutes: Int) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, minutes > 0 else { return }
        repository.add(StudyTask(title: title, dueDate: calendar.startOfDay(for: date), durationMinutes: minutes))
        selectedDate = calendar.startOfDay(for: date)
        displayedMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    func toggle(_ task: StudyTask) {
        guard var current = repository.tasks.first(where: { $0.id == task.id }) else { return }
        current.isCompleted.toggle()
        repository.update(current)
    }

    static func preview() -> BoardViewModel {
        BoardViewModel(repository: InMemoryTaskRepository(tasks: [
            StudyTask(title: "Review notes", isCompleted: true, dueDate: .now, durationMinutes: 25),
            StudyTask(title: "Practice quiz", isCompleted: true, dueDate: .now, durationMinutes: 15),
            StudyTask(title: "Read chapter 3", dueDate: .now, durationMinutes: 20)
        ]))
    }
}
