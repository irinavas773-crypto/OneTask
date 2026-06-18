import Foundation
import Combine

final class TaskStore: ObservableObject {
    static let storageKey = "taskQueue"
    static let completedKey = "completedTasks"

    @Published private(set) var queue: TaskQueue = .empty
    @Published private(set) var completed: [Task] = []

    private let defaults: UserDefaults

    init() {
        defaults = .standard
        loadQueue()
        loadCompleted()
    }

    var currentTask: Task? { queue.current }
    var pendingTasks: [Task] { queue.pending }

    func loadQueue() {
        guard let data = defaults.data(forKey: TaskStore.storageKey) else {
            queue = .empty
            return
        }
        if let decoded = try? JSONDecoder().decode(TaskQueue.self, from: data) {
            queue = decoded
        } else {
            queue = .empty
        }
    }

    func saveQueue() {
        if let data = try? JSONEncoder().encode(queue) {
            defaults.set(data, forKey: TaskStore.storageKey)
        }
    }

    private func loadCompleted() {
        guard let data = defaults.data(forKey: TaskStore.completedKey) else {
            completed = []
            return
        }
        completed = (try? JSONDecoder().decode([Task].self, from: data)) ?? []
    }

    private func saveCompleted() {
        if let data = try? JSONEncoder().encode(completed) {
            defaults.set(data, forKey: TaskStore.completedKey)
        }
    }

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let task = Task(title: trimmed)
        if queue.current == nil {
            queue.current = task
        } else {
            queue.pending.append(task)
        }
        saveQueue()
    }

    func removeTask(_ task: Task) {
        queue.pending.removeAll { $0.id == task.id }
        if queue.current?.id == task.id {
            advance()
        }
        saveQueue()
    }

    func completeCurrentTask() {
        if var done = queue.current {
            done.completedAt = Date()
            completed.insert(done, at: 0)
            saveCompleted()
        }
        advance()
        saveQueue()
    }

    func clearHistory() {
        completed.removeAll()
        saveCompleted()
    }

    private func advance() {
        if queue.pending.isEmpty {
            queue.current = nil
        } else {
            queue.current = queue.pending.removeFirst()
        }
    }
}
