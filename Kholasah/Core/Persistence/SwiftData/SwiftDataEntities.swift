import Foundation
import SwiftData

@Model
final class CourseEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var instructor: String

    init(id: UUID, title: String, instructor: String) {
        self.id = id
        self.title = title
        self.instructor = instructor
    }
}

@Model
final class StudyTaskEntity {
    @Attribute(.unique) var id: UUID
    var courseID: UUID?
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var durationMinutes: Int?
    var concept: String?
    var explanation: String?
    var keyPoints: [String]
    var reviewPrompt: String?
    var reminderMessage: String?

    init(task: StudyTask) {
        id = task.id
        courseID = task.courseID
        title = task.title
        isCompleted = task.isCompleted
        dueDate = task.dueDate
        durationMinutes = task.durationMinutes
        concept = task.concept
        explanation = task.explanation
        keyPoints = task.keyPoints
        reviewPrompt = task.reviewPrompt
        reminderMessage = task.reminderMessage
    }
}

@Model
final class StudyPlanEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskIDs: [UUID]

    init(plan: StudyPlan) {
        id = plan.id
        title = plan.title
        taskIDs = plan.taskIDs
    }
}

@Model
final class PlanReminderEntity {
    @Attribute(.unique) var id: UUID
    var courseID: UUID?
    var title: String
    var date: Date
    var isOn: Bool
    var generatedTaskID: UUID?

    init(reminder: PlanReminderItem) {
        id = reminder.id
        courseID = reminder.courseID
        title = reminder.title
        date = reminder.date
        isOn = reminder.isOn
        generatedTaskID = reminder.generatedTaskID
    }
}

extension CourseEntity {
    var domainModel: Course {
        Course(id: id, title: title, instructor: instructor)
    }
}

extension StudyTaskEntity {
    var domainModel: StudyTask {
        StudyTask(
            id: id,
            courseID: courseID,
            title: title,
            isCompleted: isCompleted,
            dueDate: dueDate,
            durationMinutes: durationMinutes,
            concept: concept,
            explanation: explanation,
            keyPoints: keyPoints,
            reviewPrompt: reviewPrompt,
            reminderMessage: reminderMessage
        )
    }

    func update(from task: StudyTask) {
        courseID = task.courseID
        title = task.title
        isCompleted = task.isCompleted
        dueDate = task.dueDate
        durationMinutes = task.durationMinutes
        concept = task.concept
        explanation = task.explanation
        keyPoints = task.keyPoints
        reviewPrompt = task.reviewPrompt
        reminderMessage = task.reminderMessage
    }
}

extension StudyPlanEntity {
    var domainModel: StudyPlan {
        StudyPlan(id: id, title: title, taskIDs: taskIDs)
    }

    func update(from plan: StudyPlan) {
        title = plan.title
        taskIDs = plan.taskIDs
    }
}

extension PlanReminderEntity {
    var domainModel: PlanReminderItem {
        PlanReminderItem(
            id: id,
            courseID: courseID,
            title: title,
            date: date,
            isOn: isOn,
            generatedTaskID: generatedTaskID
        )
    }

    func update(from reminder: PlanReminderItem) {
        courseID = reminder.courseID
        title = reminder.title
        date = reminder.date
        isOn = reminder.isOn
        generatedTaskID = reminder.generatedTaskID
    }
}
