import SwiftUI
import WidgetKit

@main
struct LichWidgetBundle: WidgetBundle {
    init() {
        Typeface.register()
    }

    var body: some Widget {
        TodayWidget()
        MonthWidget()
    }
}

/// One entry per local midnight for the coming week, so the date flips without the app running.
struct DayProvider: TimelineProvider {
    private static let daysAhead = 7

    func placeholder(in context: Context) -> DayEntry {
        .make(for: .today, at: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(.make(for: .today, at: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: .now)
        let today = DayInfo(date: .now, calendar: calendar)
        let entries = (0..<Self.daysAhead).compactMap { offset -> DayEntry? in
            guard let start = calendar.date(byAdding: .day, value: offset, to: midnight) else { return nil }
            return .make(for: today.adding(days: offset), at: offset == 0 ? .now : start)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayWidget", provider: DayProvider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hôm nay")
        .description("Ngày dương, ngày âm và ngày lễ sắp tới.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryCircular, .accessoryRectangular, .accessoryInline,
        ])
    }
}

struct MonthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MonthWidget", provider: DayProvider()) { entry in
            MonthWidgetView(entry: entry)
        }
        .configurationDisplayName("Tháng này")
        .description("Lịch cả tháng kèm ngày âm.")
        .supportedFamilies([.systemLarge])
    }
}

/// Reads the family from the widget environment and hands it to the shared view.
private struct TodayWidgetEntryView: View {
    let entry: DayEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        TodayWidgetView(entry: entry, family: family)
    }
}
