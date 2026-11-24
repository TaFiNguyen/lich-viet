import Foundation

enum VietText {
    /// Indexed by weekday where 0 = Sunday.
    static let weekdays = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"]
    /// Monday-first short labels for calendar grids.
    static let weekdayColumns = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    static let lunarMonths = [
        "Giêng", "Hai", "Ba", "Tư", "Năm", "Sáu", "Bảy", "Tám", "Chín", "Mười", "Một", "Chạp",
    ]
}

/// Everything the UI needs to know about one calendar day.
struct DayInfo: Identifiable, Hashable {
    let solar: SolarDate
    let julianDay: Int
    let lunar: LunarDate
    let holidays: [Holiday]

    var id: Int { julianDay }

    init(solar: SolarDate) {
        let jd = LunarCalendar.julianDay(solar)
        let lunar = LunarCalendar.lunarDate(from: solar)
        self.solar = solar
        self.julianDay = jd
        self.lunar = lunar
        self.holidays = HolidayBook.holidays(
            solar: solar,
            lunar: lunar,
            isLunarNewYearEve: Self.isLunarNewYearEve(julianDay: jd, lunar: lunar)
        )
    }

    init(date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.day, .month, .year], from: date)
        self.init(solar: SolarDate(day: parts.day ?? 1, month: parts.month ?? 1, year: parts.year ?? 2000))
    }

    static var today: DayInfo { DayInfo(date: .now) }

    func adding(days: Int) -> DayInfo {
        DayInfo(solar: LunarCalendar.solarDate(julianDay: julianDay + days))
    }

    func date(calendar: Calendar = .current) -> Date {
        let parts = DateComponents(year: solar.year, month: solar.month, day: solar.day)
        return calendar.date(from: parts) ?? .now
    }

    // MARK: Weekday

    /// 0 = Sunday ... 6 = Saturday.
    var weekdayIndex: Int { (julianDay + 1) % 7 }
    /// 0 = Monday ... 6 = Sunday.
    var mondayColumn: Int { julianDay % 7 }
    var weekdayName: String { VietText.weekdays[weekdayIndex] }
    var isSunday: Bool { weekdayIndex == 0 }

    // MARK: Lunar text

    var lunarShort: String { "\(lunar.day)/\(lunar.month)\(lunar.isLeap ? "N" : "")" }
    var lunarMonthName: String { "tháng \(VietText.lunarMonths[lunar.month - 1])\(lunar.isLeap ? " (nhuận)" : "")" }
    /// Short label for month-grid cells: shows the month on the first day of a lunar month.
    var lunarCellText: String { lunar.day == 1 ? lunarShort : "\(lunar.day)" }

    var canChiDay: String { CanChi.day(julianDay: julianDay) }
    var canChiMonth: String { CanChi.month(lunar) }
    var canChiYear: String { CanChi.year(lunar.year) }

    // MARK: Season & sky


    var isDayOff: Bool { holidays.contains { $0.isDayOff } }
    var isTetSeason: Bool {
        guard !lunar.isLeap else { return false }
        return (lunar.month == 1 && lunar.day <= 7) || (lunar.month == 12 && lunar.day >= 23)
    }

    private static func isLunarNewYearEve(julianDay jd: Int, lunar: LunarDate) -> Bool {
        guard lunar.month == 12, !lunar.isLeap, lunar.day >= 29 else { return false }
        let next = LunarCalendar.lunarDate(from: LunarCalendar.solarDate(julianDay: jd + 1))
        return next.month == 1 && next.day == 1
    }
}

/// Solar month laid out Monday-first for a calendar grid.
struct MonthModel: Identifiable, Hashable {
    let year: Int
    let month: Int
    let days: [DayInfo]

    var id: Int { year * 12 + month }
    var leadingBlanks: Int { days.first?.mondayColumn ?? 0 }

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
        let first = LunarCalendar.julianDay(SolarDate(day: 1, month: month, year: year))
        let nextMonth = month == 12 ? SolarDate(day: 1, month: 1, year: year + 1)
            : SolarDate(day: 1, month: month + 1, year: year)
        let count = LunarCalendar.julianDay(nextMonth) - first
        self.days = (0..<count).map { DayInfo(solar: LunarCalendar.solarDate(julianDay: first + $0)) }
    }

    init(containing day: DayInfo) {
        self.init(year: day.solar.year, month: day.solar.month)
    }

    func shifted(by months: Int) -> MonthModel {
        let index = year * 12 + (month - 1) + months
        return MonthModel(year: index / 12, month: index % 12 + 1)
    }

    var holidayOccurrences: [HolidayOccurrence] {
        days.flatMap { day in day.holidays.map { HolidayOccurrence(day: day, holiday: $0, daysAway: 0) } }
    }
}
