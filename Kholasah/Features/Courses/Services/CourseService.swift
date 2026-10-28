// MARK: - شرح الملف
// ينفذ قواعد التعامل مع المقررات؛ ينظف العنوان ويرفض الاسم الفارغ قبل الإضافة إلى المستودع.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
final class CourseService {
    // مستودع البيانات الذي تنفذ عليه عمليات القراءة والتعديل.
    private let repository: any CourseRepository

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(repository: any CourseRepository) {
        self.repository = repository
    }

    // المقررات المتاحة من مصدر البيانات.
    var courses: [Course] {
        repository.courses
    }

    @discardableResult
    // يطلب إضافة مقرر باستخدام البيانات المدخلة؛ تتولى الخدمة التحقق من العنوان.
    func addCourse(title: String, instructor: String) throws -> Course {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard !normalizedTitle.isEmpty else {
            throw CourseServiceError.emptyTitle
        }

        let course = Course(
            title: normalizedTitle,
            instructor: instructor.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        repository.add(course)
        return course
    }

    // يحذف المقرر المحدد من مصدر البيانات.
    func removeCourse(id: Course.ID) {
        repository.remove(id: id)
    }
}

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum CourseServiceError: LocalizedError {
    case emptyTitle

    // وصف قابل للعرض للخطأ.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    var errorDescription: String? {
        "Enter a course name."
    }
}
