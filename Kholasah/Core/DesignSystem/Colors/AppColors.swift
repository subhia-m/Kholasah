// MARK: - شرح الملف
// مرجع مشترك لألوان التطبيق، بحيث تستخدم الشاشات الألوان نفسها.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

// enum يجمع حالات محددة أو قيمًا مشتركة تحت اسم واحد بحسب محتواه أدناه.
enum AppColors {
    // Brand palette
    // لون مشترك من لوحة ألوان التصميم.
    static let green = Color(red: 41 / 255, green: 122 / 255, blue: 0 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let burgundy = Color(red: 100 / 255, green: 25 / 255, blue: 14 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let brown = Color(red: 115 / 255, green: 87 / 255, blue: 75 / 255)
    // التاريخ المرتبط بالعنصر.
    static let date = Color(red: 182 / 255, green: 100 / 255, blue: 47 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let sand = Color(red: 223 / 255, green: 165 / 255, blue: 120 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let darkPage = Color(red: 229 / 255, green: 208 / 255, blue: 195 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let lightPage = Color(red: 235 / 255, green: 225 / 255, blue: 215 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let light2Page = Color(red: 242 / 255, green: 238 / 255, blue: 234 / 255)
    // لون مشترك من لوحة ألوان التصميم.
    static let neutralGray = Color(red: 151 / 255, green: 151 / 255, blue: 151 / 255)

    // Semantic colors used throughout the app
    static let background = lightPage
    static let primary = burgundy
    static let card = lightPage
    static let secondaryText = neutralGray
}
