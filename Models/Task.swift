import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var note: String
    var categoryID: UUID?
    var subtasks: [Subtask]
    var focusSeconds: TimeInterval
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        categoryID: UUID? = nil,
        subtasks: [Subtask] = [],
        focusSeconds: TimeInterval = 0,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.categoryID = categoryID
        self.subtasks = subtasks
        self.focusSeconds = focusSeconds
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    // Backward-compatible decoding: fields added after 1.0 may be missing in
    // data that was persisted by an earlier build.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        categoryID = try container.decodeIfPresent(UUID.self, forKey: .categoryID)
        subtasks = try container.decodeIfPresent([Subtask].self, forKey: .subtasks) ?? []
        focusSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .focusSeconds) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }

    var subtaskProgress: (done: Int, total: Int) {
        (subtasks.filter { $0.isDone }.count, subtasks.count)
    }

    var hasSubtasks: Bool { !subtasks.isEmpty }
}
