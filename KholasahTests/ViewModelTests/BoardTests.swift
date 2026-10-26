import Foundation
import Testing
@testable import Kholasah

@MainActor
struct BoardTests {
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    @Test func tasksUseFullDatesAndRetainCompletion() {
        let model = BoardViewModel(repository: InMemoryTaskRepository(), today: date(2026, 10, 26))
        let dates = [date(2025, 10, 26), date(2026, 9, 26), date(2026, 10, 26), date(2028, 2, 29)]
        for (index, day) in dates.enumerated() {
            model.add(title: "Task \(index)", date: day, minutes: index + 10)
        }
        for (index, day) in dates.enumerated() {
            model.selectedDate = day
            #expect(model.tasks.count == 1)
            #expect(model.tasks.first?.title == "Task \(index)")
        }
        model.selectedDate = dates[0]
        if let task = model.tasks.first { model.toggle(task) }
        model.selectedDate = dates[3]
        model.moveMonth(13)
        model.selectedDate = dates[0]
        #expect(model.tasks.first?.isCompleted == true)
        #expect(model.repository.tasks.count == 4)
        model.selectedDate = date(2030, 1, 1)
        #expect(model.tasks.isEmpty)
    }

    @Test func persistenceSurvivesRepositoryRecreation() throws {
        let suite = "BoardTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let repository = InMemoryTaskRepository(defaults: defaults)
        let model = BoardViewModel(repository: repository)
        model.add(title: "Saved", date: date(2027, 1, 2), minutes: 35)
        let task = try #require(model.tasks.first)
        model.toggle(task)
        let restored = InMemoryTaskRepository(defaults: defaults)
        #expect(restored.tasks == repository.tasks)
        #expect(restored.tasks.first?.durationMinutes == 35)
        #expect(restored.tasks.first?.isCompleted == true)
    }

    @Test func invalidInputAndRealCalendar() {
        let model = BoardViewModel(repository: InMemoryTaskRepository(), today: date(2028, 2, 1))
        model.add(title: "  ", date: .now, minutes: 25)
        model.add(title: "Invalid", date: .now, minutes: 0)
        model.add(title: "Invalid", date: .now, minutes: -1)
        #expect(model.repository.tasks.isEmpty)
        #expect(model.monthDays.count == 29)
        #expect(model.leadingEmptyDays == 2)
        model.moveMonth(-2)
        #expect(model.calendar.component(.year, from: model.displayedMonth) == 2027)
        #expect(model.calendar.component(.month, from: model.displayedMonth) == 12)
    }

    @Test func streakUsesLastRecordedDayIndependentlyOfSelection() {
        let last = date(2026, 10, 27)
        let streak = BoardStreak(count: 17, lastRecordedDay: last)
        let model = BoardViewModel(repository: InMemoryTaskRepository(), streak: streak)
        let week = streak.week(calendar: model.calendar)
        #expect(week.count == 7)
        #expect(week.contains { model.calendar.isDate($0, inSameDayAs: last) })
        #expect(model.calendar.component(.weekday, from: week[0]) == 1)
        model.selectedDate = date(2040, 1, 1)
        model.add(title: "Task", date: .now, minutes: 10)
        if let task = model.tasks.first { model.toggle(task) }
        #expect(model.streak == streak)
    }

    @Test func planEditsPreserveBoardMetadata() throws {
        let repository = InMemoryTaskRepository()
        let service = StudyPlanService(courseRepository: InMemoryCourseRepository(),
                                       taskRepository: repository,
                                       planRepository: InMemoryStudyPlanRepository())
        let model = BoardViewModel(repository: repository)
        model.add(title: "Shared", date: date(2027, 4, 20), minutes: 45)
        let task = try #require(model.tasks.first)
        service.replaceTaskItems([PlanTaskItem(id: task.id, title: task.title, isDone: true)])
        #expect(model.tasks.first?.isCompleted == true)
        #expect(model.tasks.first?.dueDate == task.dueDate)
        #expect(model.tasks.first?.durationMinutes == 45)
    }
}
