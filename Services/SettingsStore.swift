import Foundation
import Combine

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let remindersEnabled = "settings.remindersEnabled"
        static let reminderMinutes = "settings.reminderMinutes"
        static let hapticsEnabled = "settings.hapticsEnabled"
        static let timerMode = "settings.timerMode"
        static let workMinutes = "settings.workMinutes"
        static let shortBreakMinutes = "settings.shortBreakMinutes"
        static let longBreakMinutes = "settings.longBreakMinutes"
        static let sessionsBeforeLongBreak = "settings.sessionsBeforeLongBreak"
        static let didCompleteOnboarding = "settings.didCompleteOnboarding"
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

    @Published var timerMode: TimerMode {
        didSet { defaults.set(timerMode.rawValue, forKey: Keys.timerMode) }
    }

    @Published var workMinutes: Int {
        didSet { defaults.set(workMinutes, forKey: Keys.workMinutes) }
    }

    @Published var shortBreakMinutes: Int {
        didSet { defaults.set(shortBreakMinutes, forKey: Keys.shortBreakMinutes) }
    }

    @Published var longBreakMinutes: Int {
        didSet { defaults.set(longBreakMinutes, forKey: Keys.longBreakMinutes) }
    }

    @Published var sessionsBeforeLongBreak: Int {
        didSet { defaults.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak) }
    }

    @Published var didCompleteOnboarding: Bool {
        didSet { defaults.set(didCompleteOnboarding, forKey: Keys.didCompleteOnboarding) }
    }

    init() {
        let store = UserDefaults.standard
        defaults = store

        remindersEnabled = store.bool(forKey: Keys.remindersEnabled)
        let minutes = store.integer(forKey: Keys.reminderMinutes)
        reminderMinutes = minutes == 0 ? 25 : minutes
        hapticsEnabled = store.object(forKey: Keys.hapticsEnabled) as? Bool ?? true

        timerMode = TimerMode(rawValue: store.string(forKey: Keys.timerMode) ?? "") ?? .pomodoro
        let work = store.integer(forKey: Keys.workMinutes)
        workMinutes = work == 0 ? 25 : work
        let shortBreak = store.integer(forKey: Keys.shortBreakMinutes)
        shortBreakMinutes = shortBreak == 0 ? 5 : shortBreak
        let longBreak = store.integer(forKey: Keys.longBreakMinutes)
        longBreakMinutes = longBreak == 0 ? 15 : longBreak
        let sessions = store.integer(forKey: Keys.sessionsBeforeLongBreak)
        sessionsBeforeLongBreak = sessions == 0 ? 4 : sessions

        didCompleteOnboarding = store.bool(forKey: Keys.didCompleteOnboarding)
    }
}
