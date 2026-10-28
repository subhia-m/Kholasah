// MARK: - شرح الملف
// مستودع الخطط في الذاكرة؛ يحفظ الخطط طوال عمر هذه النسخة فقط.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import Observation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class InMemoryStudyPlanRepository: StudyPlanRepository {
    // الخطط المتاحة من مصدر البيانات.
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var plans: [StudyPlan]

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(plans: [StudyPlan] = []) {
        self.plans = plans
    }

    // يحفظ الخطة؛ يستبدل الموجودة ذات المعرّف نفسه أو يضيف خطة جديدة.
    func save(_ plan: StudyPlan) {
        // يفك قيمة اختيارية بأمان؛ ينفذ الفرع فقط إذا لم تكن nil.
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
        } else {
            plans.append(plan)
        }
    }

    // يحذف العنصر المطابق للمعرّف.
    func remove(id: StudyPlan.ID) {
        plans.removeAll { $0.id == id }
    }
}
