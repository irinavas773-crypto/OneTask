import Foundation
import Combine

/// Persists completed focus sessions so the Statistics screen can summarize them.
final class StatsStore: ObservableObject {
    private static let key = "focusSessions"
    private static let maxSessions = 2000

    @Published private(set) var sessions: [FocusSession] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func log(seconds: TimeInterval, taskTitle: String) {
        guard seconds >= 1 else { return }
        sessions.insert(FocusSession(seconds: seconds, taskTitle: taskTitle), at: 0)
        if sessions.count > Self.maxSessions {
            sessions = Array(sessions.prefix(Self.maxSessions))
        }
        save()
    }

    func clear() {
        sessions.removeAll()
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key) else { return }
        sessions = (try? JSONDecoder().decode([FocusSession].self, from: data)) ?? []
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
