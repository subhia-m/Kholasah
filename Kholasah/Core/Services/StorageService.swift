// MARK: - شرح الملف
// يحفظ علامتي إكمال المقدمة وإعداد المقرر باستخدام UserDefaults، وهو تخزين محلي للإعدادات البسيطة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation

// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// protocol عقد يحدد المتطلبات؛ النوع المطابق له يقدم التنفيذ الفعلي.
protocol StorageService: AnyObject {
    // علامة إكمال المستخدم لشاشات المقدمة.
    var hasCompletedOnboarding: Bool { get set }
    // علامة إكمال إعداد المقرر الأول.
    var hasCompletedFirstCourseSetup: Bool { get set }
}

@MainActor
final class UserDefaultsStorageService: StorageService {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasCompletedFirstCourseSetup = "hasCompletedFirstCourseSetup"
    }

    // وسيلة الوصول إلى التخزين المحلي UserDefaults.
    private let defaults: UserDefaults

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // علامة إكمال المستخدم لشاشات المقدمة.
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    // علامة إكمال إعداد المقرر الأول.
    var hasCompletedFirstCourseSetup: Bool {
        get { defaults.bool(forKey: Key.hasCompletedFirstCourseSetup) }
        set { defaults.set(newValue, forKey: Key.hasCompletedFirstCourseSetup) }
    }
}
