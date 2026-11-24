import Foundation

/// A Gregorian calendar date without a time component.
struct SolarDate: Hashable, Comparable {
    let day: Int
    let month: Int
    let year: Int

    static func < (lhs: SolarDate, rhs: SolarDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

/// A date in the Vietnamese lunisolar calendar.
struct LunarDate: Hashable {
    let day: Int
    let month: Int
    let year: Int
    let isLeap: Bool
}

/// Vietnamese lunisolar calendar computed astronomically (Hồ Ngọc Đức's algorithm, UTC+7).
enum LunarCalendar {
    static let timeZone = 7.0
    private static let synodicMonth = 29.530588853
    private static let newMoonEpoch = 2415021.076998695

    // MARK: Julian day

    static func julianDay(_ date: SolarDate) -> Int {
        let a = (14 - date.month) / 12
        let y = date.year + 4800 - a
        let m = date.month + 12 * a - 3
        let base = date.day + (153 * m + 2) / 5 + 365 * y + y / 4
        let gregorian = base - y / 100 + y / 400 - 32045
        return gregorian < 2299161 ? base - 32083 : gregorian
    }

    static func solarDate(julianDay jd: Int) -> SolarDate {
        let b: Int
        let c: Int
        if jd > 2299160 {
            let a = jd + 32044
            b = (4 * a + 3) / 146097
            c = a - (b * 146097) / 4
        } else {
            b = 0
            c = jd + 32082
        }
        let d = (4 * c + 3) / 1461
        let e = c - (1461 * d) / 4
        let m = (5 * e + 2) / 153
        return SolarDate(
            day: e - (153 * m + 2) / 5 + 1,
            month: m + 3 - 12 * (m / 10),
            year: b * 100 + d - 4800 + m / 10
        )
    }

    // MARK: Conversions

    static func lunarDate(from solar: SolarDate) -> LunarDate {
        let dayNumber = julianDay(solar)
        let k = Int(floor((Double(dayNumber) - newMoonEpoch) / synodicMonth))
        var monthStart = newMoonDay(k + 1)
        if monthStart > dayNumber { monthStart = newMoonDay(k) }

        var a11 = lunarMonth11(year: solar.year)
        var b11 = a11
        var lunarYear: Int
        if a11 >= monthStart {
            lunarYear = solar.year
            a11 = lunarMonth11(year: solar.year - 1)
        } else {
            lunarYear = solar.year + 1
            b11 = lunarMonth11(year: solar.year + 1)
        }

        let lunarDay = dayNumber - monthStart + 1
        let diff = (monthStart - a11) / 29
        var lunarMonth = diff + 11
        var isLeap = false
        if b11 - a11 > 365 {
            let leapDiff = leapMonthOffset(a11: a11)
            if diff >= leapDiff {
                lunarMonth = diff + 10
                isLeap = diff == leapDiff
            }
        }
        if lunarMonth > 12 { lunarMonth -= 12 }
        if lunarMonth >= 11 && diff < 4 { lunarYear -= 1 }
        return LunarDate(day: lunarDay, month: lunarMonth, year: lunarYear, isLeap: isLeap)
    }

    /// Returns nil when the lunar date does not exist (e.g. a leap month that year does not have).
    static func solarDate(from lunar: LunarDate) -> SolarDate? {
        let a11: Int
        let b11: Int
        if lunar.month < 11 {
            a11 = lunarMonth11(year: lunar.year - 1)
            b11 = lunarMonth11(year: lunar.year)
        } else {
            a11 = lunarMonth11(year: lunar.year)
            b11 = lunarMonth11(year: lunar.year + 1)
        }
        let k = Int(floor(0.5 + (Double(a11) - newMoonEpoch) / synodicMonth))
        var offset = lunar.month - 11
        if offset < 0 { offset += 12 }

        if b11 - a11 > 365 {
            let leapOffset = leapMonthOffset(a11: a11)
            var leapMonth = leapOffset - 2
            if leapMonth < 0 { leapMonth += 12 }
            if lunar.isLeap && lunar.month != leapMonth { return nil }
            if lunar.isLeap || offset >= leapOffset { offset += 1 }
        } else if lunar.isLeap {
            return nil
        }
        let monthStart = newMoonDay(k + offset)
        return solarDate(julianDay: monthStart + lunar.day - 1)
    }

    // MARK: Astronomy

    /// Sun's apparent longitude in radians [0, 2π) at the given (fractional) Julian day.
    static func sunLongitude(julianDay jdn: Double) -> Double {
        let t = (jdn - 2451545.0) / 36525
        let t2 = t * t
        let dr = Double.pi / 180
        let m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2
        let l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2
        var dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * sin(dr * m)
        dl += (0.019993 - 0.000101 * t) * sin(dr * 2 * m) + 0.000290 * sin(dr * 3 * m)
        let longitude = (l0 + dl) * dr
        let fullTurn = Double.pi * 2
        return longitude - fullTurn * floor(longitude / fullTurn)
    }

    private static func newMoon(_ index: Int) -> Double {
        let k = Double(index)
        let t = k / 1236.85
        let t2 = t * t
        let t3 = t2 * t
        let dr = Double.pi / 180
        var jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3
        jd1 += 0.00033 * sin((166.56 + 132.87 * t - 0.009173 * t2) * dr)
        let m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3
        let mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3
        let f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3
        var c1 = (0.1734 - 0.000393 * t) * sin(m * dr) + 0.0021 * sin(2 * dr * m)
        c1 += -0.4068 * sin(mpr * dr) + 0.0161 * sin(dr * 2 * mpr)
        c1 += -0.0004 * sin(dr * 3 * mpr)
        c1 += 0.0104 * sin(dr * 2 * f) - 0.0051 * sin(dr * (m + mpr))
        c1 += -0.0074 * sin(dr * (m - mpr)) + 0.0004 * sin(dr * (2 * f + m))
        c1 += -0.0004 * sin(dr * (2 * f - m)) - 0.0006 * sin(dr * (2 * f + mpr))
        c1 += 0.0010 * sin(dr * (2 * f - mpr)) + 0.0005 * sin(dr * (2 * mpr + m))
        let deltaT: Double
        if t < -11 {
            deltaT = 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3
        } else {
            deltaT = -0.000278 + 0.000265 * t + 0.000262 * t2
        }
        return jd1 + c1 - deltaT
    }

    private static func newMoonDay(_ k: Int) -> Int {
        Int(floor(newMoon(k) + 0.5 + timeZone / 24))
    }

    /// Sun longitude sector (0...11, 30° each) at the start of the given local day.
    private static func sunSector(dayNumber: Int) -> Int {
        Int(floor(sunLongitude(julianDay: Double(dayNumber) - 0.5 - timeZone / 24) / Double.pi * 6))
    }

    private static func lunarMonth11(year: Int) -> Int {
        let offset = Double(julianDay(SolarDate(day: 31, month: 12, year: year))) - 2415021
        let k = Int(floor(offset / synodicMonth))
        let candidate = newMoonDay(k)
        return sunSector(dayNumber: candidate) >= 9 ? newMoonDay(k - 1) : candidate
    }

    private static func leapMonthOffset(a11: Int) -> Int {
        let k = Int(floor((Double(a11) - newMoonEpoch) / synodicMonth + 0.5))
        var index = 1
        var arc = sunSector(dayNumber: newMoonDay(k + index))
        var last = 0
        repeat {
            last = arc
            index += 1
            arc = sunSector(dayNumber: newMoonDay(k + index))
        } while arc != last && index < 14
        return index - 1
    }
}
