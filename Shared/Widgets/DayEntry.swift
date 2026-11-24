import Foundation
import WidgetKit

/// Deep links the widgets open in the app.
enum AppLink {
    static let today = URL(string: "lichviet://today")
    static let month = URL(string: "lichviet://month")
}

struct DayEntry: TimelineEntry {
    let date: Date
    let day: DayInfo
    let next: HolidayOccurrence?

    static func make(for day: DayInfo, at date: Date) -> DayEntry {
        DayEntry(date: date, day: day, next: HolidayBook.upcoming(from: day, limit: 1).first)
    }
}
