import Foundation

struct TaskQueue: Codable, Equatable {
    var current: Task?
    var pending: [Task]

    init(current: Task? = nil, pending: [Task] = []) {
        self.current = current
        self.pending = pending
    }

    static let empty = TaskQueue(current: nil, pending: [])
}
