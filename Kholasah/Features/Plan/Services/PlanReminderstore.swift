//
//  PlanReminderstore.swift
//  Kholasah
//
//  Created by subhia  on 26/10/2026.
//

import Foundation
import Observation

// MARK: - Model

struct PlanReminderItem: Identifiable, Equatable, Hashable {
    var id = UUID()
    /// The course this reminder belongs to. nil = not tied to a course.
    var courseID: Course.ID?
    var title: String
    var date: Date
    var isOn: Bool = true
}

// MARK: - Store

.
@MainActor
@Observable
final class PlanRemindersStore {
    static let shared = PlanRemindersStore()

    private(set) var reminders: [PlanReminderItem] = []

    init() {}

    /// Reminders for one course, or all reminders when `courseID` is nil.
    func reminders(for courseID: Course.ID?) -> [PlanReminderItem] {
        guard let courseID else { return reminders }
        return reminders.filter { $0.courseID == courseID }
    }

    func add(title: String, date: Date, courseID: Course.ID?) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        reminders.append(PlanReminderItem(courseID: courseID, title: trimmed, date: date))
        reminders.sort { $0.date < $1.date }
    }

    func setEnabled(_ id: PlanReminderItem.ID, _ isOn: Bool) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].isOn = isOn
    }

    func delete(_ id: PlanReminderItem.ID) {
        reminders.removeAll { $0.id == id }
    }
}
