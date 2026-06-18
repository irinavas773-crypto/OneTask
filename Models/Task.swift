import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var createdAt: Date
    var completedAt: Date?

    init(id: UUID = UUID(), title: String, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
