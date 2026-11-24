import Foundation

struct Holiday: Identifiable, Hashable {
    enum Kind: String, Hashable { case solar, lunar }

    let name: String
    let kind: Kind
    let day: Int
    let month: Int
    /// Official public day off for workers.
    var isDayOff = false
    /// Shown in "upcoming" lists and widgets.
    var isMajor = false

    var id: String { "\(kind.rawValue)-\(month)-\(day)-\(name)" }
}

struct HolidayOccurrence: Identifiable, Hashable {
    let day: DayInfo
    let holiday: Holiday
    let daysAway: Int

    var id: String { "\(day.julianDay)-\(holiday.id)" }

    var countdownText: String {
        switch daysAway {
        case 0: return "Hôm nay"
        case 1: return "Ngày mai"
        default: return "Còn \(daysAway) ngày"
        }
    }
}

enum HolidayBook {
    static let solar: [Holiday] = [
        Holiday(name: "Tết Dương lịch", kind: .solar, day: 1, month: 1, isDayOff: true, isMajor: true),
        Holiday(name: "Ngày Học sinh – Sinh viên", kind: .solar, day: 9, month: 1),
        Holiday(name: "Thành lập Đảng Cộng sản Việt Nam", kind: .solar, day: 3, month: 2),
        Holiday(name: "Lễ Tình nhân", kind: .solar, day: 14, month: 2, isMajor: true),
        Holiday(name: "Ngày Thầy thuốc Việt Nam", kind: .solar, day: 27, month: 2),
        Holiday(name: "Quốc tế Phụ nữ", kind: .solar, day: 8, month: 3, isMajor: true),
        Holiday(name: "Thành lập Đoàn TNCS Hồ Chí Minh", kind: .solar, day: 26, month: 3),
        Holiday(name: "Ngày Sách và Văn hoá đọc Việt Nam", kind: .solar, day: 21, month: 4),
        Holiday(name: "Ngày Giải phóng miền Nam", kind: .solar, day: 30, month: 4, isDayOff: true, isMajor: true),
        Holiday(name: "Quốc tế Lao động", kind: .solar, day: 1, month: 5, isDayOff: true, isMajor: true),
        Holiday(name: "Chiến thắng Điện Biên Phủ", kind: .solar, day: 7, month: 5),
        Holiday(name: "Ngày sinh Chủ tịch Hồ Chí Minh", kind: .solar, day: 19, month: 5),
        Holiday(name: "Quốc tế Thiếu nhi", kind: .solar, day: 1, month: 6, isMajor: true),
        Holiday(name: "Ngày Báo chí Cách mạng Việt Nam", kind: .solar, day: 21, month: 6),
        Holiday(name: "Ngày Gia đình Việt Nam", kind: .solar, day: 28, month: 6, isMajor: true),
        Holiday(name: "Ngày Thương binh – Liệt sĩ", kind: .solar, day: 27, month: 7),
        Holiday(name: "Cách mạng Tháng Tám", kind: .solar, day: 19, month: 8),
        Holiday(name: "Quốc khánh", kind: .solar, day: 2, month: 9, isDayOff: true, isMajor: true),
        Holiday(name: "Ngày Giải phóng Thủ đô", kind: .solar, day: 10, month: 10),
        Holiday(name: "Ngày Doanh nhân Việt Nam", kind: .solar, day: 13, month: 10),
        Holiday(name: "Ngày Phụ nữ Việt Nam", kind: .solar, day: 20, month: 10, isMajor: true),
        Holiday(name: "Ngày Nhà giáo Việt Nam", kind: .solar, day: 20, month: 11, isMajor: true),
        Holiday(name: "Ngày Quân đội Nhân dân Việt Nam", kind: .solar, day: 22, month: 12),
        Holiday(name: "Lễ Giáng sinh", kind: .solar, day: 24, month: 12, isMajor: true),
    ]

    static let lunar: [Holiday] = [
        Holiday(name: "Tết Nguyên Đán", kind: .lunar, day: 1, month: 1, isDayOff: true, isMajor: true),
        Holiday(name: "Mùng 2 Tết", kind: .lunar, day: 2, month: 1, isDayOff: true),
        Holiday(name: "Mùng 3 Tết", kind: .lunar, day: 3, month: 1, isDayOff: true),
        Holiday(name: "Tết Nguyên Tiêu (Rằm tháng Giêng)", kind: .lunar, day: 15, month: 1, isMajor: true),
        Holiday(name: "Tết Hàn Thực", kind: .lunar, day: 3, month: 3, isMajor: true),
        Holiday(name: "Giỗ Tổ Hùng Vương", kind: .lunar, day: 10, month: 3, isDayOff: true, isMajor: true),
        Holiday(name: "Lễ Phật Đản", kind: .lunar, day: 15, month: 4, isMajor: true),
        Holiday(name: "Tết Đoan Ngọ", kind: .lunar, day: 5, month: 5, isMajor: true),
        Holiday(name: "Lễ Vu Lan", kind: .lunar, day: 15, month: 7, isMajor: true),
        Holiday(name: "Tết Trung Thu", kind: .lunar, day: 15, month: 8, isMajor: true),
        Holiday(name: "Tết Trùng Cửu", kind: .lunar, day: 9, month: 9),
        Holiday(name: "Tết Thường Tân", kind: .lunar, day: 10, month: 10),
        Holiday(name: "Tết Hạ Nguyên", kind: .lunar, day: 15, month: 10),
        Holiday(name: "Ông Công Ông Táo", kind: .lunar, day: 23, month: 12, isMajor: true),
    ]

    static let newYearEve = Holiday(
        name: "Giao thừa", kind: .lunar, day: 30, month: 12, isDayOff: true, isMajor: true
    )

    static func holidays(solar date: SolarDate, lunar: LunarDate, isLunarNewYearEve: Bool) -> [Holiday] {
        let solarMatches = solar.filter { $0.day == date.day && $0.month == date.month }
        let lunarMatches = lunar.isLeap ? [] : self.lunar.filter { $0.day == lunar.day && $0.month == lunar.month }
        let eve = isLunarNewYearEve ? [newYearEve] : []
        return lunarMatches + eve + solarMatches
    }

    /// Holidays from `start` + `firstOffset` days onward, nearest first.
    static func upcoming(
        from start: DayInfo, firstOffset: Int = 0, limit: Int, majorOnly: Bool = true, horizon: Int = 400
    ) -> [HolidayOccurrence] {
        var result: [HolidayOccurrence] = []
        for offset in firstOffset...horizon where result.count < limit {
            let day = start.adding(days: offset)
            let picked = day.holidays.filter { !majorOnly || $0.isMajor }
            for holiday in picked where result.count < limit {
                result.append(HolidayOccurrence(day: day, holiday: holiday, daysAway: offset))
            }
        }
        return result
    }
}
