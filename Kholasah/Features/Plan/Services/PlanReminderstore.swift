// MARK: - شرح الملف
// يحفظ تذكيرات الواجهة في الذاكرة لكل مقرر. تعديل هذه القائمة وحده لا يجدول أو يلغي إشعارات النظام.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

//
//  PlanReminderstore.swift
//  Kholasah
//
//  Created by subhia  on 26/10/2026.
//

import Foundation
import Observation

// MARK: - Model

// Identifiable يوفر هوية للعنصر؛ Equatable للمقارنة، وHashable لاستخدامه في المجموعات إن كانا مذكورين.
struct PlanReminderItem: Identifiable, Equatable, Hashable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    var id = UUID()
    /// The course this reminder belongs to. nil = not tied to a course.
    // معرّف المقرر المرتبط؛ nil يعني عدم الارتباط بمقرر.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var courseID: Course.ID?
    // العنوان المستخدم لهذا العنصر.
    var title: String
    // التاريخ المرتبط بالعنصر.
    var date: Date
    // حالة تفعيل تذكير الواجهة.
    var isOn: Bool = true
    // معرّف المهمة التي نتج عنها التذكير؛ nil للتذكير اليدوي.
    var generatedTaskID: StudyTask.ID?
}

// MARK: - Store


// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class PlanRemindersStore {
    // نسخة واحدة مشتركة من مخزن تذكيرات الواجهة.
    static let shared = PlanRemindersStore()

    // تذكيرات الواجهة المعروضة.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var reminders: [PlanReminderItem] = []

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init() {}

    /// Reminders for one course, or all reminders when `courseID` is nil.
    // يعيد تذكيرات المقرر المحدد، أو جميع التذكيرات إذا كان المعرّف nil.
    func reminders(for courseID: Course.ID?) -> [PlanReminderItem] {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard let courseID else { return reminders }
        return reminders.filter { $0.courseID == courseID }
    }

    // يضيف تذكيرًا إلى قائمة الواجهة بعد تنظيف العنوان ويرتبها زمنيًا.
    func add(title: String, date: Date, courseID: Course.ID?) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        reminders.append(PlanReminderItem(courseID: courseID, title: trimmed, date: date))
        reminders.sort { $0.date < $1.date }
    }

    /// Replaces only AI-generated reminders while preserving reminders added by the user.
    // يستبدل التذكيرات المولدة لمقرر معين ويحافظ على التذكيرات اليدوية.
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
    }

    // يحدث حالة تفعيل التذكير في الذاكرة فقط؛ لا يعدل إشعار النظام.
    func setEnabled(_ id: PlanReminderItem.ID, _ isOn: Bool) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].isOn = isOn
    }

    // يحذف التذكير من مخزن الواجهة فقط.
    func delete(_ id: PlanReminderItem.ID) {
        reminders.removeAll { $0.id == id }
    }
}
