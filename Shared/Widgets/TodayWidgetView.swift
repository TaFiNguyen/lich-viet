import SwiftUI
import WidgetKit

struct TodayWidgetView: View {
    let entry: DayEntry
    let family: WidgetFamily

    private var day: DayInfo { entry.day }
    private var theme: SeasonTheme { .of(day) }

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular: circular
            case .accessoryRectangular: rectangular
            case .accessoryInline: inline
            case .systemMedium: medium
            default: small
            }
        }
        .widgetURL(AppLink.today)
    }

    private let haloOpacity = 0.85

    private var backdrop: some View {
        SceneryView(theme: theme)
    }

    // MARK: Home screen

    private var small: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(day.weekdayName.uppercased())
                .font(Typeface.label(11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(day.isSunday ? theme.accent : theme.inkSoft)
            Text("\(day.solar.day)")
                .font(Typeface.numeral(54))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("tháng \(day.solar.month)")
                .font(Typeface.title(13))
                .foregroundStyle(theme.inkSoft)
                .shadow(color: .white.opacity(haloOpacity), radius: 6)
            Spacer(minLength: 4)
            lunarPill
        }
        .foregroundStyle(theme.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { backdrop }
    }

    private var lunarPill: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label(day.lunarShort + " âm", systemImage: "moon.fill")
                .font(Typeface.label(12, weight: .bold))
            if let holiday = day.holidays.first {
                Text(holiday.name)
                    .font(Typeface.label(10, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Text(day.weekdayName.uppercased())
                    .font(Typeface.label(11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(day.isSunday ? theme.accent : theme.inkSoft)
                Text("\(day.solar.day)")
                    .font(Typeface.numeral(62))
                    .lineLimit(1)
                Text("tháng \(day.solar.month), \(String(day.solar.year))")
                    .font(Typeface.title(13))
                    .foregroundStyle(theme.inkSoft)
            }
            .shadow(color: .white.opacity(haloOpacity), radius: 8)
            .frame(maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(day.lunar.day)").font(Typeface.numeral(24)).foregroundStyle(theme.accent)
                    Text(day.lunarMonthName).font(Typeface.title(13)).lineLimit(1)
                }
                Text("Năm \(day.canChiYear)")
                    .font(Typeface.label(11, weight: .semibold))
                    .foregroundStyle(theme.inkSoft)
                Divider().overlay(theme.ink.opacity(0.15))
                nextHoliday
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .foregroundStyle(theme.ink)
        .containerBackground(for: .widget) { backdrop }
    }

    @ViewBuilder
    private var nextHoliday: some View {
        if let next = entry.next {
            VStack(alignment: .leading, spacing: 1) {
                Text(next.countdownText.uppercased())
                    .font(Typeface.label(9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(theme.accent)
                Text(next.holiday.name)
                    .font(Typeface.label(12, weight: .semibold))
                    .lineLimit(2)
            }
        }
    }

    // MARK: Lock screen

    private var circular: some View {
        VStack(spacing: -2) {
            Text("\(day.solar.day)").font(Typeface.numeral(22))
            Text(day.lunarShort).font(Typeface.label(10, weight: .bold))
        }
        .widgetAccentable()
        .containerBackground(for: .widget) { AccessoryWidgetBackground() }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("\(day.weekdayName), \(day.solar.day)/\(day.solar.month)")
                .font(Typeface.label(15, weight: .bold))
                .widgetAccentable()
            Text("Âm lịch \(day.lunarShort)")
                .font(Typeface.label(13, weight: .semibold))
            Text(day.holidays.first?.name ?? entry.next.map { "\($0.countdownText): \($0.holiday.name)" } ?? "")
                .font(Typeface.label(12))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) { Color.clear }
    }

    private var inline: some View {
        Label("\(day.lunarShort) âm lịch", systemImage: "moon")
            .containerBackground(for: .widget) { Color.clear }
    }
}
