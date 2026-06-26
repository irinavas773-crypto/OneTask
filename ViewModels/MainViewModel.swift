import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var showConfetti: Bool = false

    let store: TaskStore
    let timer: TimerService
    let settings: SettingsStore
    let categories: CategoryStore
    let stats: StatsStore
    let theme: ThemeStore
    private let haptics: HapticsService
    private let notifications: NotificationService

    private var cancellables: Set<AnyCancellable> = []
    private var confettiWorkItem: DispatchWorkItem?

    init(
        store: TaskStore = TaskStore(),
        timer: TimerService = TimerService(),
        settings: SettingsStore = SettingsStore(),
        categories: CategoryStore = CategoryStore(),
        stats: StatsStore = StatsStore(),
        theme: ThemeStore = ThemeStore(),
        haptics: HapticsService = HapticsService(),
        notifications: NotificationService = NotificationService()
    ) {
        self.store = store
        self.timer = timer
        self.settings = settings
        self.categories = categories
        self.stats = stats
        self.theme = theme
        self.haptics = haptics
        self.notifications = notifications

        notifications.requestAuthorization()

        // Re-publish changes from child stores so views observing the view model update.
        let children: [ObservableObjectPublisher] = [
            store.objectWillChange,
            timer.objectWillChange,
            categories.objectWillChange,
            stats.objectWillChange,
            theme.objectWillChange
        ]
        for publisher in children {
            publisher
                .sink { [weak self] in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }

        settings.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.applyTimerConfig()
                self?.scheduleReminderIfNeeded()
            }
            .store(in: &cancellables)

        timer.onWorkSessionCompleted = { [weak self] seconds in
            self?.handleWorkSessionCompleted(seconds)
        }
        timer.onPhaseChanged = { [weak self] phase in
            self?.handlePhaseChanged(phase)
        }

        applyTimerConfig()
        scheduleReminderIfNeeded()
    }

    // MARK: - Derived state

    var currentTask: Task? { store.currentTask }
    var pendingTasks: [Task] { store.pendingTasks }
    var completedTasks: [Task] { store.completed }
    var hasTask: Bool { store.currentTask != nil }

    var timerText: String { timer.displayText }
    var timerProgress: Double { timer.progress }
    var isTimerRunning: Bool { timer.isRunning }
    var timerPhase: FocusPhase { timer.phase }
    var timerMode: TimerMode { timer.mode }

    var needsOnboarding: Bool { !settings.didCompleteOnboarding }

    // MARK: - Task actions

    func addTask(_ title: String, categoryID: UUID? = nil) {
        let wasEmpty = !hasTask
        store.addTask(title, categoryID: categoryID)
        if wasEmpty && hasTask {
            timer.start()
            scheduleReminderIfNeeded()
        }
    }

    func addTaskDetailed(title: String, categoryID: UUID?, subtasks: [Subtask]) {
        let wasEmpty = !hasTask
        store.add(Task(title: title, categoryID: categoryID, subtasks: subtasks))
        if wasEmpty && hasTask {
            timer.start()
            scheduleReminderIfNeeded()
        }
    }

    func updateTask(_ task: Task) {
        store.update(task)
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        store.moveTask(from: source, to: destination)
    }

    func removeTask(_ task: Task) {
        let wasCurrent = store.currentTask?.id == task.id
        store.removeTask(task)
        if wasCurrent {
            if hasTask {
                timer.start()
            } else {
                timer.reset()
            }
            scheduleReminderIfNeeded()
        }
    }

    func completeCurrentTask() {
        guard hasTask else { return }
        if settings.hapticsEnabled {
            haptics.playCompletion()
        }
        triggerConfetti()

        // Record any focus accrued in the active work phase before advancing.
        let partial = timer.activeFocusSeconds
        if partial >= 1, let title = store.currentTask?.title {
            store.addFocusToCurrent(partial)
            stats.log(seconds: partial, taskTitle: title)
        }

        store.completeCurrentTask()
        if hasTask {
            timer.start()
        } else {
            timer.reset()
        }
        scheduleReminderIfNeeded()
    }

    func clearHistory() {
        store.clearHistory()
    }

    // MARK: - Timer actions

    func toggleTimer() {
        if settings.hapticsEnabled { haptics.playSelection() }
        timer.toggle()
    }

    func skipPhase() {
        if settings.hapticsEnabled { haptics.playSelection() }
        timer.skip()
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        settings.didCompleteOnboarding = true
    }

    // MARK: - Private

    private func applyTimerConfig() {
        let modeChanged = timer.mode != settings.timerMode
        timer.configure(
            mode: settings.timerMode,
            work: settings.workMinutes,
            shortBreak: settings.shortBreakMinutes,
            longBreak: settings.longBreakMinutes,
            sessions: settings.sessionsBeforeLongBreak
        )
        if modeChanged {
            timer.reset()
        }
    }

    private func handleWorkSessionCompleted(_ seconds: TimeInterval) {
        store.addFocusToCurrent(seconds)
        if let title = store.currentTask?.title {
            stats.log(seconds: seconds, taskTitle: title)
        }
        if settings.hapticsEnabled { haptics.playCompletion() }
        notifications.notifyNow(title: "Focus session complete", body: "Time for a short break.")
    }

    private func handlePhaseChanged(_ phase: FocusPhase) {
        guard phase != .idle else { return }
        if settings.hapticsEnabled { haptics.playSelection() }
    }

    private func scheduleReminderIfNeeded() {
        notifications.cancelReminders()
        guard settings.remindersEnabled, let task = store.currentTask else { return }
        notifications.scheduleReminder(title: task.title, after: settings.reminderMinutes)
    }

    private func triggerConfetti() {
        confettiWorkItem?.cancel()
        showConfetti = true
        let work = DispatchWorkItem { [weak self] in
            self?.showConfetti = false
        }
        confettiWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }
}
