import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AccentOption: Identifiable {
    let id: String
    let name: String
    let hex: String

    var color: Color { Color(hex: hex) ?? .blue }
}

final class ThemeStore: ObservableObject {
    private enum Keys {
        static let appearance = "theme.appearance"
        static let accent = "theme.accent"
    }

    static let accents: [AccentOption] = [
        AccentOption(id: "blue", name: "Blue", hex: "#0A84FF"),
        AccentOption(id: "indigo", name: "Indigo", hex: "#5E5CE6"),
        AccentOption(id: "purple", name: "Purple", hex: "#BF5AF2"),
        AccentOption(id: "pink", name: "Pink", hex: "#FF375F"),
        AccentOption(id: "orange", name: "Orange", hex: "#FF9F0A"),
        AccentOption(id: "green", name: "Green", hex: "#30D158"),
        AccentOption(id: "teal", name: "Teal", hex: "#40C8E0")
    ]

    private let defaults: UserDefaults

    @Published var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) }
    }

    @Published var accentID: String {
        didSet { defaults.set(accentID, forKey: Keys.accent) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appearance = AppearanceMode(rawValue: defaults.string(forKey: Keys.appearance) ?? "") ?? .system
        accentID = defaults.string(forKey: Keys.accent) ?? "blue"
    }

    var accent: AccentOption {
        Self.accents.first { $0.id == accentID } ?? Self.accents[0]
    }

    var accentColor: Color { accent.color }
}
