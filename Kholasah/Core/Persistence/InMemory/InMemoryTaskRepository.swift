// MARK: - شرح الملف
// مستودع المهام المشترك. رغم اسمه، يدعم حفظ JSON في UserDefaults عند تمرير defaults؛ وبدونها يعمل في الذاكرة فقط.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class InMemoryTaskRepository: TaskRepository {
    // المهام التي يستخدمها هذا الجزء من التطبيق.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var tasks: [StudyTask] {
        // كل تعديل للقائمة يستدعي الحفظ إذا كانت وسيلة التخزين مفعلة.
        didSet { persist() }
    }
    // وسيلة الوصول إلى التخزين المحلي UserDefaults.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    private let defaults: UserDefaults?
    // المفتاح الذي تُحفظ تحته بيانات المهام.
    private let storageKey = "sharedStudyTasks.v1"

    // Passing defaults enables local persistence; tests and previews remain isolated.
    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(tasks: [StudyTask] = [], defaults: UserDefaults? = nil) {
        self.defaults = defaults
        // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
        // نحاول استعادة المهام المحفوظة أولًا؛ عند غيابها أو فشل فكها نستخدم قائمة البداية.
        if let data = defaults?.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([StudyTask].self, from: data) {
            self.tasks = saved
        } else {
            self.tasks = tasks
        }
    }

    // يرمز المهام إلى JSON ويحفظها إذا توفرت UserDefaults؛ يتجاهل الحفظ عند غيابها أو فشل الترميز.
    private func persist() {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard let defaults, let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: storageKey)
    }

    // يضيف العنصر إلى مجموعة البيانات في المستودع.
    func add(_ task: StudyTask) {
        tasks.append(task)
    }

    // يبحث عن العنصر بمعرّفه ويستبدل بياناته عند وجوده.
    func update(_ task: StudyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    // يحذف العنصر المطابق للمعرّف.
    func remove(id: StudyTask.ID) {
        tasks.removeAll { $0.id == id }
    }
}
