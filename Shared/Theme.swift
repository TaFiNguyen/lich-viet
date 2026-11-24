import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Seasonal look: background painting, pastel tint and the ink/accent colors drawn on top of it.
struct SeasonTheme: Hashable {
    let name: String
    /// Bundled background image name (`bg-*.jpg`, see `SceneryView`).
    let photo: String
    let skyTop: Color
    let skyBottom: Color
    let ink: Color
    let inkSoft: Color
    let accent: Color

    static func of(_ day: DayInfo) -> SeasonTheme {
        if day.isTetSeason { return .tet }
        switch day.solar.month {
        case 2...4: return .spring
        case 5...7: return .summer
        case 8...10: return .autumn
        default: return .winter
        }
    }

    static let spring = SeasonTheme(
        name: "Xuân",
        photo: "bg-spring",
        skyTop: Color(hex: 0xD6ECC4), skyBottom: Color(hex: 0xF7F4DA),
        ink: Color(hex: 0x21402A), inkSoft: Color(hex: 0x4F6B52),
        accent: Color(hex: 0xD2493F)
    )

    static let summer = SeasonTheme(
        name: "Hạ",
        photo: "bg-summer",
        skyTop: Color(hex: 0x9ED8EA), skyBottom: Color(hex: 0xEAF7E0),
        ink: Color(hex: 0x15365A), inkSoft: Color(hex: 0x3D5C7A),
        accent: Color(hex: 0xDA4B43)
    )

    static let autumn = SeasonTheme(
        name: "Thu",
        photo: "bg-autumn",
        skyTop: Color(hex: 0xF9D3B0), skyBottom: Color(hex: 0xFFF2E2),
        ink: Color(hex: 0x4F2A14), inkSoft: Color(hex: 0x7A5236),
        accent: Color(hex: 0xC03C2A)
    )

    static let winter = SeasonTheme(
        name: "Đông",
        photo: "bg-winter",
        skyTop: Color(hex: 0xC4C3F0), skyBottom: Color(hex: 0xF8DFEA),
        ink: Color(hex: 0x272657), inkSoft: Color(hex: 0x55548A),
        accent: Color(hex: 0xCF4577)
    )

    static let tet = SeasonTheme(
        name: "Tết",
        photo: "bg-tet",
        skyTop: Color(hex: 0xFFC6BF), skyBottom: Color(hex: 0xFFF1D8),
        ink: Color(hex: 0x631915), inkSoft: Color(hex: 0x8E3F33),
        accent: Color(hex: 0xC4122F)
    )
}
