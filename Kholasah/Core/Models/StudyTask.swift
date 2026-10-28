// MARK: - شرح الملف
// نموذج المهمة الدراسية: بيانات الإنجاز والموعد والمدة، مع تفاصيل المحتوى التعليمي الاختيارية.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// Identifiable يوفر هوية للعنصر؛ Equatable للمقارنة، وHashable لاستخدامه في المجموعات إن كانا مذكورين.
// Codable يتيح ترميز البيانات وفكها مثل JSON، وSendable يصف إمكانية نقلها بأمان بين سياقات التزامن.
struct StudyTask: Identifiable, Codable, Equatable, Hashable, Sendable {
    // معرّف يميز هذا العنصر عن بقية العناصر.
    let id: UUID
    // معرّف المقرر المرتبط؛ nil يعني عدم الارتباط بمقرر.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    let courseID: Course.ID?
    // العنوان المستخدم لهذا العنصر.
    var title: String
    // هل أُنجزت المهمة؟
    var isCompleted: Bool
    // موعد المهمة الاختياري.
    var dueDate: Date?
    // مدة الدراسة المقدرة بالدقائق.
    var durationMinutes: Int?
    // المفهوم الذي تتناوله المهمة.
    var concept: String?
    // شرح المفهوم المستخرج من المادة.
    var explanation: String?
    // النقاط الأساسية التي تساعد على مراجعة المفهوم.
    var keyPoints: [String]
    // سؤال مراجعة لاختبار فهم المفهوم.
    var reviewPrompt: String?
    // النص التحفيزي المرتبط بتذكير المهمة.
    var reminderMessage: String?

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(
        id: UUID = UUID(),
        courseID: Course.ID? = nil,
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        durationMinutes: Int? = nil,
        concept: String? = nil,
        explanation: String? = nil,
        keyPoints: [String] = [],
        reviewPrompt: String? = nil,
        reminderMessage: String? = nil
    ) {
        self.id = id
        self.courseID = courseID
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.durationMinutes = durationMinutes
        self.concept = concept
        self.explanation = explanation
        self.keyPoints = keyPoints
        self.reviewPrompt = reviewPrompt
        self.reminderMessage = reminderMessage
    }
}
