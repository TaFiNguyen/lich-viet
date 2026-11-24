import SwiftUI

struct DayCell: View {
    let day: DayInfo
    let theme: SeasonTheme
    let isToday: Bool
    let isSelected: Bool

    private var solarColor: Color {
        if isToday { return .white }
        return day.isSunday || day.isDayOff ? theme.accent : theme.ink
    }

    var body: some View {
        VStack(spacing: 1) {
            Text("\(day.solar.day)")
                .font(Typeface.title(19))
                .foregroundStyle(solarColor)
            Text(day.lunarCellText)
                .font(Typeface.label(10, weight: day.lunar.day == 1 ? .bold : .medium))
                .foregroundStyle(isToday ? .white.opacity(0.85) : (day.lunar.day == 1 ? theme.accent : theme.inkSoft))
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isToday ? AnyShapeStyle(theme.accent.gradient) : AnyShapeStyle(.white.opacity(isSelected ? 0.75 : 0)))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? theme.ink.opacity(0.7) : .clear, lineWidth: 1.5)
        }
        .overlay(alignment: .top) {
            if !day.holidays.isEmpty {
                Circle()
                    .fill(isToday ? .white : theme.accent)
                    .frame(width: 5, height: 5)
                    .padding(.top, 4)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var accessibilityText: String {
        let holidays = day.holidays.map(\.name).joined(separator: ", ")
        let base = "\(day.weekdayName) ngày \(day.solar.day) tháng \(day.solar.month), âm lịch \(day.lunar.day) \(day.lunarMonthName)"
        return holidays.isEmpty ? base : "\(base). \(holidays)"
    }
}

struct SelectedDayCard: View {
    let day: DayInfo
    let theme: SeasonTheme
    let onOpen: () -> Void

    var body: some View {
        GlassCard(padding: 16) {
            HStack(alignment: .center, spacing: 14) {
                VStack(spacing: 0) {
                    Text("\(day.solar.day)").font(Typeface.numeral(32)).contentTransition(.numericText())
                    Text(day.lunarShort).font(Typeface.label(12, weight: .bold)).foregroundStyle(theme.accent)
                }
                .frame(width: 64, height: 64)
                .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(day.weekdayName), \(day.solar.day)/\(day.solar.month)")
                        .font(Typeface.label(16, weight: .semibold))
                    Text(day.holidays.first?.name ?? "Ngày \(day.canChiDay)")
                        .font(Typeface.label(13, weight: day.holidays.isEmpty ? .regular : .semibold))
                        .foregroundStyle(day.holidays.isEmpty ? theme.inkSoft : theme.accent)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Button(action: onOpen) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(theme.ink.opacity(0.88), in: Circle())
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel("Xem chi tiết ngày này")
            }
        }
    }
}

struct MonthHolidayList: View {
    let occurrences: [HolidayOccurrence]
    let theme: SeasonTheme
    let onSelect: (DayInfo) -> Void

    var body: some View {
        if !occurrences.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("NGÀY LỄ TRONG THÁNG")
                    .font(Typeface.label(11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(theme.inkSoft)
                    .padding(.leading, 4)
                ForEach(occurrences) { item in
                    Button { onSelect(item.day) } label: { row(item) }
                        .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func row(_ item: HolidayOccurrence) -> some View {
        HStack(spacing: 12) {
            Text("\(item.day.solar.day)/\(item.day.solar.month)")
                .font(Typeface.title(15))
                .frame(width: 52, alignment: .leading)
            Text(item.holiday.name)
                .font(Typeface.label(15, weight: .semibold))
                .multilineTextAlignment(.leading)
            Spacer(minLength: 4)
            if item.holiday.isDayOff {
                Text("Nghỉ")
                    .font(Typeface.label(11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(theme.accent, in: Capsule())
            }
        }
        .foregroundStyle(theme.ink)
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
