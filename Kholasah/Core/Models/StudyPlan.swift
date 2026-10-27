// MARK: - شرح الملف
// نموذج خطة دراسية يحتفظ بمعرّفات مهامها لربطها ببيانات المهام.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// Identifiable يوفر هوية للعنصر؛ Equatable للمقارنة، وHashable لاستخدامه في المجموعات إن كانا مذكورين.
// Codable يتيح ترميز البيانات وفكها مثل JSON، وSendable يصف إمكانية نقلها بأمان بين سياقات التزامن.
struct StudyPlan: Identifiable, Codable, Equatable, Sendable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    let id: UUID
    // العنوان المستخدم لهذا العنصر.
    var title: String
    // معرّفات المهام التابعة للخطة.
    var taskIDs: [StudyTask.ID]

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(id: UUID = UUID(), title: String, taskIDs: [StudyTask.ID] = []) {
        self.id = id
        self.title = title
        self.taskIDs = taskIDs
    }
}
