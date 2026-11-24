import Foundation

/// Sexagenary cycle (Can Chi) names for lunar days, months and years.
enum CanChi {
    static let stems = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
    static let branches = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]

    static func day(julianDay jd: Int) -> String {
        "\(stems[(jd + 9) % 10]) \(branches[(jd + 1) % 12])"
    }

    static func month(_ lunar: LunarDate) -> String {
        "\(stems[(lunar.year * 12 + lunar.month + 3) % 10]) \(branches[(lunar.month + 1) % 12])"
    }

    static func year(_ lunarYear: Int) -> String {
        "\(stems[(lunarYear + 6) % 10]) \(branches[(lunarYear + 8) % 12])"
    }
}
