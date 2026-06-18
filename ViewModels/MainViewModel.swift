import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var showConfetti: Bool = false

    let store: TaskStore
    let timer: TimerService
    let settings: SettingsStore
    private let haptics: HapticsService
    private let notifications: NotificationService

    private var cancellables: Set<AnyCancellable> = []
    private var confettiWorkItem: DispatchWorkItem?

    init(
        store: TaskStore = TaskStore(),
        timer: TimerService = TimerService(),
        settings: SettingsStore = SettingsStore(),
        haptics: HapticsService = HapticsService(),
        notifications: NotificationService = NotificationService()
    ) {
        self.store = store
        self.timer = timer
        self.settings = settings
        self.haptics = haptics
        self.notifications = notifications

        notifications.requestAuthorization()

        store.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        timer.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        settings.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.scheduleReminderIfNeeded()
            }
            .store(in: &cancellables)

        if store.currentTask != nil {
            timer.start()
        }
        scheduleReminderIfNeeded()
    }

    var currentTask: Task? { store.currentTask }
    var pendingTasks: [Task] { store.pendingTasks }
    var completedTasks: [Task] { store.completed }
    var hasTask: Bool { store.currentTask != nil }
    var timerText: String { timer.formatted }

    func completeCurrentTask() {
        guard hasTask else { return }
        if settings.hapticsEnabled {
            haptics.playCompletion()
        }
        triggerConfetti()
        store.completeCurrentTask()
        if hasTask {
            timer.start()
        } else {
            timer.reset()
        }
        scheduleReminderIfNeeded()
    }

    func addTask(_ title: String) {
        let wasEmpty = !hasTask
        store.addTask(title)
        if wasEmpty && hasTask {
            timer.start()
            scheduleReminderIfNeeded()
        }
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

    func clearHistory() {
        store.clearHistory()
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
