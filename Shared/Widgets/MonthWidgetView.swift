import SwiftUI
import WidgetKit

struct MonthWidgetView: View {
    let entry: DayEntry

    private var today: DayInfo { entry.day }
    private var month: MonthModel { MonthModel(containing: today) }
    private var theme: SeasonTheme { .of(today) }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        let month = month
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Tháng \(month.month)").font(Typeface.numeral(24))
                Text(String(month.year)).font(Typeface.title(15)).foregroundStyle(theme.inkSoft)
                Spacer()
                Text(today.canChiYear)
                    .font(Typeface.label(12, weight: .semibold))
                    .foregroundStyle(theme.inkSoft)
            }

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(VietText.weekdayColumns.enumerated()), id: \.offset) { index, label in
                    Text(label)
                        .font(Typeface.label(10, weight: .bold))
                        .foregroundStyle(index == 6 ? theme.accent : theme.inkSoft)
                        .frame(height: 16)
                }
                ForEach(0..<month.leadingBlanks, id: \.self) { _ in Color.clear.frame(height: 36) }
                ForEach(month.days) { day in cell(day) }
            }
            .padding(8)
            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            if let next = entry.next {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text(next.holiday.name).lineLimit(1)
                    Spacer(minLength: 4)
                    Text(next.countdownText).foregroundStyle(theme.accent)
                }
                .font(Typeface.label(12, weight: .semibold))
            }
        }
        .foregroundStyle(theme.ink)
        .frame(maxHeight: .infinity, alignment: .top)
        .containerBackground(for: .widget) {
            SceneryView(theme: theme, wash: .strong)
        }
        .widgetURL(AppLink.month)
    }

    private func cell(_ day: DayInfo) -> some View {
        let isToday = day.julianDay == today.julianDay
        let solarColor: Color = isToday ? .white : (day.isSunday || day.isDayOff ? theme.accent : theme.ink)
        return VStack(spacing: 0) {
            Text("\(day.solar.day)")
                .font(Typeface.title(14))
                .foregroundStyle(solarColor)
            Text(day.lunarCellText)
                .font(Typeface.label(8, weight: day.lunar.day == 1 ? .bold : .medium))
                .foregroundStyle(isToday ? .white.opacity(0.85) : (day.lunar.day == 1 ? theme.accent : theme.inkSoft))
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .background {
            if isToday {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(theme.accent.gradient)
            } else if !day.holidays.isEmpty {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(theme.accent.opacity(0.1))
            }
        }
    }
}
