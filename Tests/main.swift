import Foundation

var failures = 0
func expect(_ cond: Bool, _ msg: String) {
    if cond { print("✓ \(msg)") } else { failures += 1; print("✗ \(msg)") }
}
func lunar(_ d: Int, _ m: Int, _ y: Int) -> LunarDate { LunarCalendar.lunarDate(from: SolarDate(day: d, month: m, year: y)) }

// Reference screenshot: 24/7/2026 = 11/6 âm, ngày Kỷ Hợi, tháng Ất Mùi, năm Bính Ngọ
let ref = DayInfo(solar: SolarDate(day: 24, month: 7, year: 2026))
expect(ref.lunar == LunarDate(day: 11, month: 6, year: 2026, isLeap: false), "24/7/2026 → 11/6/2026 (got \(ref.lunar))")
expect(ref.canChiDay == "Kỷ Hợi", "ngày Kỷ Hợi (got \(ref.canChiDay))")
expect(ref.canChiMonth == "Ất Mùi", "tháng Ất Mùi (got \(ref.canChiMonth))")
expect(ref.canChiYear == "Bính Ngọ", "năm Bính Ngọ (got \(ref.canChiYear))")
expect(ref.weekdayName == "Thứ Sáu", "24/7/2026 Thứ Sáu (got \(ref.weekdayName))")

// Known Tết dates
for (d, m, y) in [(10, 2, 2024), (29, 1, 2025), (17, 2, 2026), (6, 2, 2027), (22, 1, 2023)] {
    let l = lunar(d, m, y)
    expect(l.day == 1 && l.month == 1 && l.year == y, "Tết \(y) = \(d)/\(m) (got \(l))")
    expect(DayInfo(solar: SolarDate(day: d, month: m, year: y)).holidays.contains { $0.name == "Tết Nguyên Đán" }, "Tết holiday on \(d)/\(m)/\(y)")
}
// Giao thừa 16/2/2026
expect(DayInfo(solar: SolarDate(day: 16, month: 2, year: 2026)).holidays.contains { $0.name == "Giao thừa" }, "Giao thừa 16/2/2026")
// Leap months: 2023 nhuận tháng 2, 2025 nhuận tháng 6
expect(lunar(25, 7, 2025).isLeap && lunar(25, 7, 2025).month == 6, "25/7/2025 in leap month 6 (got \(lunar(25, 7, 2025)))")
expect(lunar(25, 3, 2023).isLeap && lunar(25, 3, 2023).month == 2, "25/3/2023 in leap month 2 (got \(lunar(25, 3, 2023)))")
// Trung thu 2026 = 25/9/2026, 2025 = 6/10/2025
expect(lunar(25, 9, 2026) == LunarDate(day: 15, month: 8, year: 2026, isLeap: false), "Trung thu 2026 = 25/9")
expect(lunar(6, 10, 2025) == LunarDate(day: 15, month: 8, year: 2025, isLeap: false), "Trung thu 2025 = 6/10")

// Round-trip every day 1900–2100
var roundTripErrors = 0
let start = LunarCalendar.julianDay(SolarDate(day: 1, month: 1, year: 1900))
let end = LunarCalendar.julianDay(SolarDate(day: 31, month: 12, year: 2100))
for jd in start...end {
    let s = LunarCalendar.solarDate(julianDay: jd)
    if LunarCalendar.julianDay(s) != jd { roundTripErrors += 1; continue }
    if LunarCalendar.solarDate(from: LunarCalendar.lunarDate(from: s)) != s { roundTripErrors += 1 }
}
expect(roundTripErrors == 0, "round-trip solar↔lunar 1900–2100 (\(end - start + 1) days, \(roundTripErrors) errors)")

// Month model
let nov = MonthModel(year: 2026, month: 11)
expect(nov.days.count == 30 && nov.leadingBlanks == 6, "11/2026 has 30 days, starts Sunday (blanks \(nov.leadingBlanks))")
expect(MonthModel(year: 2026, month: 12).shifted(by: 1).id == MonthModel(year: 2027, month: 1).id, "month shift across year")
expect(MonthModel(year: 2024, month: 2).days.count == 29, "leap Feb 2024")

let today = DayInfo(solar: SolarDate(day: 24, month: 11, year: 2026))
print("Hôm nay:", today.weekdayName, today.lunarShort, today.canChiDay, today.canChiMonth, today.canChiYear)
print("Sắp tới:", HolidayBook.upcoming(from: today, limit: 3).map { "\($0.holiday.name) \($0.day.solar.day)/\($0.day.solar.month) \($0.countdownText)" })
print(failures == 0 ? "ALL PASSED" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
