import Foundation
import Combine

final class CategoryStore: ObservableObject {
    private static let key = "categories"

    @Published private(set) var categories: [Category] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
        if categories.isEmpty {
            categories = Category.defaults
            save()
        }
    }

    func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    func add(name: String, colorHex: String, symbol: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        categories.append(Category(name: trimmed, colorHex: colorHex, symbol: symbol))
        save()
    }

    func update(_ category: Category) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        save()
    }

    func delete(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key) else { return }
        categories = (try? JSONDecoder().decode([Category].self, from: data)) ?? []
    }

    private func save() {
        if let data = try? JSONEncoder().encode(categories) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
