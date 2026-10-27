// MARK: - شرح الملف
// مرجع مشترك للخطوط المستخدمة في واجهات التطبيق.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum AppTypography {
    // نمط خط العنوان الكبير.
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    // العنوان المستخدم لهذا العنصر.
    static let title = Font.system(.title2, design: .rounded, weight: .semibold)
    // نمط الخط الأساسي لنصوص التطبيق.
    static let body = Font.system(.body, design: .rounded)
}
