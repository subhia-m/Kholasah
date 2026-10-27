import Foundation

@MainActor
protocol StorageService: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
    var hasCompletedFirstCourseSetup: Bool { get set }
}

@MainActor
final class UserDefaultsStorageService: StorageService {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasCompletedFirstCourseSetup = "hasCompletedFirstCourseSetup"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    var hasCompletedFirstCourseSetup: Bool {
        get { defaults.bool(forKey: Key.hasCompletedFirstCourseSetup) }
        set { defaults.set(newValue, forKey: Key.hasCompletedFirstCourseSetup) }
    }
}
