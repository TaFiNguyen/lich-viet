import SwiftUI

/// Frosted card used on top of the illustrated backdrop.
struct GlassCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(.white.opacity(0.6), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
    }
}

struct DateHero: View {
    let day: DayInfo
    let theme: SeasonTheme

    var body: some View {
        VStack(spacing: 6) {
            Text(day.weekdayName.uppercased())
                .font(Typeface.label(17, weight: .bold))
                .tracking(4)
                .foregroundStyle(day.isSunday ? theme.accent : theme.inkSoft)

            Text("\(day.solar.day)")
                .font(Typeface.numeral(140))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())

            Text("tháng \(day.solar.month), \(String(day.solar.year))")
                .font(Typeface.title(20))
                .foregroundStyle(theme.inkSoft)

            if !day.holidays.isEmpty {
                VStack(spacing: 6) {
                    ForEach(day.holidays) { holiday in
                        HolidayChip(holiday: holiday, theme: theme)
                    }
                }
                .padding(.top, 10)
            }
        }
        .multilineTextAlignment(.center)
        // Soft halo keeps the date legible over busy painted backgrounds.
        .shadow(color: .white.opacity(0.9), radius: 10)
        .shadow(color: .white.opacity(0.6), radius: 24)
        .accessibilityElement(children: .combine)
    }
}

struct HolidayChip: View {
    let holiday: Holiday
    let theme: SeasonTheme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: holiday.kind == .lunar ? "moon.stars.fill" : "sparkles")
            Text(holiday.name)
            if holiday.isDayOff {
                Text("Nghỉ lễ")
                    .font(Typeface.label(11, weight: .bold))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.white.opacity(0.3), in: Capsule())
            }
        }
        .font(Typeface.label(14, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(theme.accent.gradient, in: Capsule())
        .shadow(color: theme.accent.opacity(0.35), radius: 10, y: 5)
    }
}

/// One-glance lunar date: day + month on the left, Can Chi of day and year on the right.
struct LunarPanel: View {
    let day: DayInfo
    let theme: SeasonTheme

    var body: some View {
        GlassCard {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Âm lịch")
                        .font(Typeface.label(12, weight: .semibold))
                        .foregroundStyle(theme.inkSoft)
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(day.lunar.day)")
                            .font(Typeface.numeral(44))
                            .foregroundStyle(theme.accent)
                            .contentTransition(.numericText())
                        Text(day.lunarMonthName)
                            .font(Typeface.title(20))
                    }
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Ngày \(day.canChiDay)")
                    Text("Năm \(day.canChiYear)")
                }
                .font(Typeface.title(16))
                .foregroundStyle(theme.inkSoft)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// The single nearest major holiday, as one slim line.
struct NextHolidayRow: View {
    let occurrence: HolidayOccurrence?
    let theme: SeasonTheme

    var body: some View {
        if let item = occurrence {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(theme.accent)
                Text(item.holiday.name)
                    .font(Typeface.label(15, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(item.countdownText)
                    .font(Typeface.label(13, weight: .bold))
                    .foregroundStyle(theme.accent)
            }
            .padding(.horizontal, 18)
            .frame(height: 50)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.white.opacity(0.6), lineWidth: 1))
            .accessibilityElement(children: .combine)
        }
    }
}
