import Foundation
import Combine

/// Drives both the Pomodoro (count-down with work/break phases) and the
/// Stopwatch (count-up) focus modes.
final class TimerService: ObservableObject {
    @Published private(set) var mode: TimerMode = .pomodoro
    @Published private(set) var phase: FocusPhase = .idle
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var completedWorkSessions: Int = 0

    // Configuration (minutes).
    private var workMinutes: Int = 25
    private var shortBreakMinutes: Int = 5
    private var longBreakMinutes: Int = 15
    private var sessionsBeforeLongBreak: Int = 4

    // Callbacks.
    var onWorkSessionCompleted: ((TimeInterval) -> Void)?
    var onPhaseChanged: ((FocusPhase) -> Void)?

    private var cancellable: AnyCancellable?
    private var phaseStart: Date?
    private var accumulated: TimeInterval = 0

    // MARK: - Derived values

    var phaseDuration: TimeInterval {
        switch phase {
        case .idle, .work: return TimeInterval(workMinutes * 60)
        case .shortBreak: return TimeInterval(shortBreakMinutes * 60)
        case .longBreak: return TimeInterval(longBreakMinutes * 60)
        }
    }

    var remaining: TimeInterval { max(0, phaseDuration - elapsed) }

    var progress: Double {
        guard mode == .pomodoro, phaseDuration > 0 else { return 0 }
        return min(1, elapsed / phaseDuration)
    }

    /// Focus time accrued in the current work phase (0 during breaks / idle).
    var activeFocusSeconds: TimeInterval { phase == .work ? elapsed : 0 }

    var displayText: String {
        let value: Int
        switch mode {
        case .pomodoro: value = Int(remaining.rounded(.up))
        case .stopwatch: value = Int(elapsed)
        }
        return String(format: "%02d:%02d", value / 60, value % 60)
    }

    /// Legacy alias kept for any callers expecting `formatted`.
    var formatted: String { displayText }

    // MARK: - Configuration

    func configure(mode: TimerMode, work: Int, shortBreak: Int, longBreak: Int, sessions: Int) {
        self.mode = mode
        self.workMinutes = max(1, work)
        self.shortBreakMinutes = max(1, shortBreak)
        self.longBreakMinutes = max(1, longBreak)
        self.sessionsBeforeLongBreak = max(1, sessions)
    }

    // MARK: - Controls

    /// Starts a fresh focus session (resets phase/sessions) and begins running.
    func start() {
        reset()
        phase = .work
        beginPhase()
    }

    func pause() {
        guard isRunning else { return }
        stopTicking()
        isRunning = false
    }

    func resume() {
        guard !isRunning, phase != .idle else { return }
        beginTicking()
    }

    func toggle() {
        if isRunning {
            pause()
        } else if phase == .idle {
            start()
        } else {
            resume()
        }
    }

    /// Skips the current phase: finishes a work phase (counting it) or ends a break.
    func skip() {
        switch phase {
        case .work: finishWorkPhase()
        case .shortBreak, .longBreak: startWorkPhase()
        case .idle: start()
        }
    }

    func reset() {
        cancellable?.cancel()
        cancellable = nil
        phaseStart = nil
        accumulated = 0
        elapsed = 0
        isRunning = false
        phase = .idle
        completedWorkSessions = 0
    }

    // MARK: - Internal

    private func beginPhase() {
        accumulated = 0
        elapsed = 0
        onPhaseChanged?(phase)
        beginTicking()
    }

    private func beginTicking() {
        phaseStart = Date()
        isRunning = true
        cancellable = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func stopTicking() {
        if let start = phaseStart {
            accumulated += Date().timeIntervalSince(start)
        }
        phaseStart = nil
        elapsed = accumulated
        cancellable?.cancel()
        cancellable = nil
    }

    private func tick() {
        guard let start = phaseStart else { return }
        elapsed = accumulated + Date().timeIntervalSince(start)
        if mode == .pomodoro && elapsed >= phaseDuration {
            phaseCompleted()
        }
    }

    private func phaseCompleted() {
        switch phase {
        case .work: finishWorkPhase()
        case .shortBreak, .longBreak: startWorkPhase()
        case .idle: break
        }
    }

    private func finishWorkPhase() {
        let focusSeconds = mode == .pomodoro ? phaseDuration : elapsed
        stopTicking()
        completedWorkSessions += 1
        onWorkSessionCompleted?(focusSeconds)

        guard mode == .pomodoro else {
            // Stopwatch: one session at a time, return to idle.
            phase = .idle
            accumulated = 0
            elapsed = 0
            isRunning = false
            onPhaseChanged?(phase)
            return
        }

        phase = completedWorkSessions % sessionsBeforeLongBreak == 0 ? .longBreak : .shortBreak
        beginPhase()
    }

    private func startWorkPhase() {
        stopTicking()
        phase = .work
        beginPhase()
    }
}
