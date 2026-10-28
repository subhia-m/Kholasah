// MARK: - شرح الملف
// نموذج بيانات المقرر: معرّف وعنوان واسم المدرّس، دون منطق عرض الواجهة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// Identifiable يوفر هوية للعنصر؛ Equatable للمقارنة، وHashable لاستخدامه في المجموعات إن كانا مذكورين.
// Codable يتيح ترميز البيانات وفكها مثل JSON، وSendable يصف إمكانية نقلها بأمان بين سياقات التزامن.
struct Course: Identifiable, Codable, Equatable, Hashable, Sendable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    let id: UUID
    // العنوان المستخدم لهذا العنصر.
    var title: String
    // اسم المدرّس.
    var instructor: String

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(id: UUID = UUID(), title: String, instructor: String = "") {
        self.id = id
        self.title = title
        self.instructor = instructor
    }
}
