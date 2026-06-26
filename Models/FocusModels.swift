import Foundation

enum TimerMode: String, Codable, CaseIterable, Identifiable {
    case pomodoro
    case stopwatch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pomodoro: return "Pomodoro"
        case .stopwatch: return "Stopwatch"
        }
    }
}

enum FocusPhase: String, Codable {
    case idle
    case work
    case shortBreak
    case longBreak

    var title: String {
        switch self {
        case .idle: return "Ready"
        case .work: return "Focus"
        case .shortBreak: return "Short break"
        case .longBreak: return "Long break"
        }
    }

    var isBreak: Bool { self == .shortBreak || self == .longBreak }
}

/// A recorded chunk of focus time, used to build statistics.
struct FocusSession: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var seconds: TimeInterval
    var taskTitle: String

    init(id: UUID = UUID(), date: Date = Date(), seconds: TimeInterval, taskTitle: String) {
        self.id = id
        self.date = date
        self.seconds = seconds
        self.taskTitle = taskTitle
    }
}
