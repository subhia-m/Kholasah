import Foundation

@MainActor
protocol StorageService: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
}

@MainActor
final class UserDefaultsStorageService: StorageService {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }
}
