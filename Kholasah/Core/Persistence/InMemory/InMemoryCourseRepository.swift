// MARK: - شرح الملف
// مستودع المقررات في الذاكرة؛ لا يكتب البيانات إلى تخزين دائم.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class InMemoryCourseRepository: CourseRepository {
    // المقررات المتاحة من مصدر البيانات.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var courses: [Course]

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(courses: [Course] = []) {
        self.courses = courses
    }

    // يضيف العنصر إلى مجموعة البيانات في المستودع.
    func add(_ course: Course) {
        courses.append(course)
    }

    // يبحث عن العنصر بمعرّفه ويستبدل بياناته عند وجوده.
    func update(_ course: Course) {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard let index = courses.firstIndex(where: { $0.id == course.id }) else { return }
        courses[index] = course
    }

    // يحذف العنصر المطابق للمعرّف.
    func remove(id: Course.ID) {
        courses.removeAll { $0.id == id }
    }
}
