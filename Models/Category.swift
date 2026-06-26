import SwiftUI

struct Category: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var colorHex: String
    var symbol: String

    init(id: UUID = UUID(), name: String, colorHex: String, symbol: String = "circle.fill") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.symbol = symbol
    }

    var color: Color { Color(hex: colorHex) ?? .blue }

    static let defaults: [Category] = [
        Category(name: "Work", colorHex: "#0A84FF", symbol: "briefcase.fill"),
        Category(name: "Personal", colorHex: "#30D158", symbol: "person.fill"),
        Category(name: "Health", colorHex: "#FF375F", symbol: "heart.fill"),
        Category(name: "Learning", colorHex: "#FF9F0A", symbol: "book.fill")
    ]
}

extension Color {
    /// Creates a color from a `#RRGGBB` hex string. Returns nil for malformed input.
    init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }
        guard value.count == 6, let int = UInt64(value, radix: 16) else { return nil }
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}
