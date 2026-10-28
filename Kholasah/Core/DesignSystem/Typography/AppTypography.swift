// MARK: - شرح الملف
// مرجع مشترك للخطوط المستخدمة في واجهات التطبيق.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum AppTypography {
    static let displayTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let screenTitle = Font.system(.title, design: .rounded, weight: .bold)
    static let largeTitle = screenTitle
    static let title = Font.system(.title2, design: .rounded, weight: .bold)
    static let sectionTitle = Font.system(.title3, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let button = Font.system(.headline, design: .rounded, weight: .bold)
    static let body = Font.system(.body, design: .rounded)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let subheadlineEmphasized = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let captionEmphasized = Font.system(.caption, design: .rounded, weight: .semibold)
    static let caption2 = Font.system(.caption2, design: .rounded)
    // A display treatment for the Pomodoro clock; VoiceOver exposes the same value.
    static let timer = Font.system(size: 58, weight: .light, design: .rounded)
}
