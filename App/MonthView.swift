import SwiftUI

/// Full-month grid with lunar dates under each solar date. Tapping a day previews it below the grid.
struct MonthView: View {
    let today: DayInfo
    let onOpenDay: (DayInfo) -> Void

    @State private var month: MonthModel
    @State private var selected: DayInfo
    @State private var slideForward = true
    @Environment(\.dismiss) private var dismiss

    private static let swipeThreshold: CGFloat = 50
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private var theme: SeasonTheme { .of(month.days.first ?? selected) }

    init(start: DayInfo, today: DayInfo, onOpenDay: @escaping (DayInfo) -> Void) {
        self.today = today
        self.onOpenDay = onOpenDay
        _month = State(initialValue: MonthModel(containing: start))
        _selected = State(initialValue: start)
    }

    var body: some View {
        ZStack {
            SceneryView(theme: theme, wash: .strong)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    calendarCard
                    SelectedDayCard(day: selected, theme: theme) {
                        onOpenDay(selected)
                        dismiss()
                    }
                    MonthHolidayList(occurrences: month.holidayOccurrences, theme: theme) { day in
                        withAnimation(.snappy) { selected = day }
                    }
                }
                .padding(20)
            }
        }
        .foregroundStyle(theme.ink)
        .animation(.easeInOut(duration: 0.5), value: theme)
        .sensoryFeedback(.selection, trigger: selected.julianDay)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(34)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Tháng \(month.month)")
                    .font(Typeface.numeral(38))
                    .contentTransition(.numericText())
                Text("\(String(month.year)) · \(month.days.last?.canChiYear ?? "")")
                    .font(Typeface.label(14))
                    .foregroundStyle(theme.inkSoft)
            }
            Spacer()
            HStack(spacing: 8) {
                if !isShowingTodayMonth {
                    Button { jumpToToday() } label: {
                        Text("Hôm nay")
                            .font(Typeface.label(13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .fixedSize()
                            .padding(.horizontal, 12)
                            .frame(height: 42)
                            .background(theme.accent, in: Capsule())
                    }
                    .buttonStyle(PressableStyle())
                    .transition(.scale.combined(with: .opacity))
                }
                roundButton("chevron.left", label: "Tháng trước") { move(by: -1) }
                roundButton("chevron.right", label: "Tháng sau") { move(by: 1) }
            }
        }
        .padding(.top, 14)
    }

    private var calendarCard: some View {
        GlassCard(padding: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(Array(VietText.weekdayColumns.enumerated()), id: \.offset) { index, label in
                        Text(label)
                            .font(Typeface.label(12, weight: .bold))
                            .foregroundStyle(index == 6 ? theme.accent : theme.inkSoft)
                            .frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<month.leadingBlanks, id: \.self) { _ in
                        Color.clear.frame(height: 54)
                    }
                    ForEach(month.days) { day in
                        DayCell(
                            day: day,
                            theme: theme,
                            isToday: day.julianDay == today.julianDay,
                            isSelected: day.julianDay == selected.julianDay
                        )
                        .onTapGesture { withAnimation(.snappy) { selected = day } }
                    }
                }
                .id(month.id)
                .transition(.push(from: slideForward ? .trailing : .leading))
            }
            .clipped()
        }
        .gesture(monthSwipe)
    }

    private var monthSwipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > Self.swipeThreshold, abs(dx) > abs(value.translation.height) else { return }
                move(by: dx < 0 ? 1 : -1)
            }
    }

    private var isShowingTodayMonth: Bool {
        month.year == today.solar.year && month.month == today.solar.month
    }

    private func jumpToToday() {
        let target = MonthModel(containing: today)
        slideForward = target.id > month.id
        withAnimation(.snappy) {
            month = target
            selected = today
        }
    }

    private func move(by months: Int) {
        slideForward = months > 0
        withAnimation(.snappy) {
            month = month.shifted(by: months)
            selected = isShowingTodayMonth ? today : (month.days.first ?? selected)
        }
    }

    private func roundButton(_ icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.6), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel(label)
    }
}
