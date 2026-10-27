//
//  PlanReminderstore.swift
//  Kholasah
//
//  Created by subhia  on 26/10/2026.
//

import Foundation
import Observation
import SwiftData

// MARK: - Model

struct PlanReminderItem: Identifiable, Equatable, Hashable {
    var id = UUID()
    /// The course this reminder belongs to. nil = not tied to a course.
    var courseID: Course.ID?
    var title: String
    var date: Date
    var isOn: Bool = true
    var generatedTaskID: StudyTask.ID?
}

// MARK: - Store


@MainActor
@Observable
final class PlanRemindersStore {
    static let shared = PlanRemindersStore()

    private(set) var reminders: [PlanReminderItem] = []
    @ObservationIgnored private var modelContext: ModelContext?

    init() {}

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        let descriptor = FetchDescriptor<PlanReminderEntity>()
        reminders = ((try? modelContext.fetch(descriptor)) ?? [])
            .map(\.domainModel)
            .sorted { $0.date < $1.date }
    }

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
        persistAll()
    }

    /// Replaces only AI-generated reminders while preserving reminders added by the user.
    func replaceGeneratedReminders(with tasks: [StudyTask], courseID: Course.ID?) {
        reminders.removeAll {
            $0.courseID == courseID && $0.generatedTaskID != nil
        }

        reminders.append(contentsOf: tasks.map { task in
            PlanReminderItem(
                courseID: courseID,
                title: task.reminderMessage ?? "Time to study: \(task.title)",
                date: task.dueDate ?? .now,
                generatedTaskID: task.id
            )
        })
        reminders.sort { $0.date < $1.date }
        persistAll()
    }

    func setEnabled(_ id: PlanReminderItem.ID, _ isOn: Bool) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].isOn = isOn
        persistAll()
    }

    func delete(_ id: PlanReminderItem.ID) {
        reminders.removeAll { $0.id == id }
        persistAll()
    }

    private func persistAll() {
        guard let modelContext else { return }
        let existing = (try? modelContext.fetch(FetchDescriptor<PlanReminderEntity>())) ?? []
        existing.forEach(modelContext.delete)
        reminders.forEach { modelContext.insert(PlanReminderEntity(reminder: $0)) }
        try? modelContext.save()
    }
}
