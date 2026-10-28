// MARK: - شرح الملف
// يربط واجهات المقررات بالخدمة ويحوّل الأخطاء إلى رسالة يمكن عرضها للمستخدم.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class CoursesViewModel {
    // رسالة الخطأ الحالية؛ nil يعني عدم وجود رسالة.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    private(set) var errorMessage: String?

    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored
    // الخدمة المسؤولة عن قواعد العمل.
    private let service: CourseService

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(service: CourseService) {
        self.service = service
    }

    // المقررات المتاحة من مصدر البيانات.
    var courses: [Course] {
        service.courses
    }

    // يطلب إضافة مقرر باستخدام البيانات المدخلة؛ تتولى الخدمة التحقق من العنوان.
    func addCourse(title: String, instructor: String) -> Bool {
        createCourse(title: title, instructor: instructor) != nil
    }

    // ينشئ المقرر عبر الخدمة؛ يعيد المقرر عند النجاح وnil مع رسالة خطأ عند الفشل.
    func createCourse(title: String, instructor: String) -> Course? {
        // يجمع عمليات قد ترمي أخطاء؛ يعالج catch الخطأ بدل إيقاف مسار التطبيق دون معالجة.
        do {
            let course = try service.addCourse(title: title, instructor: instructor)
            errorMessage = nil
            return course
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // يمسح رسالة الخطأ السابقة.
    func clearError() {
        errorMessage = nil
    }

    // يحذف المقرر المحدد من مصدر البيانات.
    func removeCourse(id: Course.ID) {
        service.removeCourse(id: id)
    }
}
