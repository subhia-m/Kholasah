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
    // Measured from the start of one message to the start of the next.
    var interval: Duration = .seconds(35)
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

    @ObservationIgnored private var hasOpened = false

    func prepareForDisplay(today: Date = .now) {
        guard !hasOpened else { return }
        hasOpened = true
        selectedDate = calendar.startOfDay(for: today)
        displayedMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        // Canvas fixtures must never mark the real app's demo data as installed.
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        seedDemoTasksIfNeeded(today: today)
    }

    func seedDemoTasksIfNeeded(today: Date = .now, defaults: UserDefaults = .standard) {
        let key = "board.demoTasks.seeded.v1"
        guard !defaults.bool(forKey: key) else { return }
        let samples: [(offset: Int, title: String, minutes: Int, completed: Bool)] = [
            (-3, "Review vocabulary", 15, true),
            (-1, "Summarize lecture", 30, true),
            (-1, "Practice exercises", 20, false),
            (0, "Review notes", 25, false),
            (0, "Practice quiz", 15, true),
            (1, "Read chapter 3", 20, false),
            (1, "Prepare flashcards", 10, false),
            (3, "Practice exam", 45, false)
        ]
        for (index, sample) in samples.enumerated() {
            // Stable IDs prevent partial seeding from duplicating tasks after an interrupted launch.
            guard let id = UUID(uuidString: String(format: "B04D0000-0000-4000-8000-%012d", index)),
                  !repository.tasks.contains(where: { $0.id == id }),
                  let day = calendar.date(byAdding: .day, value: sample.offset, to: calendar.startOfDay(for: today))
            else { continue }
            repository.add(StudyTask(id: id, title: sample.title, isCompleted: sample.completed,
                                     dueDate: day, durationMinutes: sample.minutes))
        }
        defaults.set(true, forKey: key)
    }

    static func preview() -> BoardViewModel {
        let model = BoardViewModel(repository: InMemoryTaskRepository())
        let suite = "BoardPreview." + UUID().uuidString
        if let defaults = UserDefaults(suiteName: suite) {
            model.seedDemoTasksIfNeeded(defaults: defaults)
            defaults.removePersistentDomain(forName: suite)
        }
        return model
    }
}
