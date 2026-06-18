import Foundation
import Combine

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let remindersEnabled = "settings.remindersEnabled"
        static let reminderMinutes = "settings.reminderMinutes"
        static let hapticsEnabled = "settings.hapticsEnabled"
    }

    private let defaults: UserDefaults

    @Published var remindersEnabled: Bool {
        didSet { defaults.set(remindersEnabled, forKey: Keys.remindersEnabled) }
    }

    @Published var reminderMinutes: Int {
        didSet { defaults.set(reminderMinutes, forKey: Keys.reminderMinutes) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    init() {
        let store = UserDefaults.standard
        defaults = store
        remindersEnabled = store.bool(forKey: Keys.remindersEnabled)
        let minutes = store.integer(forKey: Keys.reminderMinutes)
        reminderMinutes = minutes == 0 ? 25 : minutes
        hapticsEnabled = store.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
    }
}
