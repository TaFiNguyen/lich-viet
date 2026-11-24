import SwiftUI

/// Home screen: today's date shown large, lunar details below, and a button into the month view.
struct TodayView: View {
    @State private var today = DayInfo.today
    @State private var shown = Self.launchDay ?? DayInfo.today
    @State private var isMonthPresented = false
    #if DEBUG
    @State private var isGalleryPresented = false
    #endif
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let swipeThreshold: CGFloat = 50
    private var theme: SeasonTheme { .of(shown) }
    private var isShowingToday: Bool { shown.julianDay == today.julianDay }

    var body: some View {
        ZStack {
            SceneryView(theme: theme, isAnimated: !reduceMotion)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: theme)

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .frame(minHeight: geo.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .foregroundStyle(theme.ink)
        .simultaneousGesture(daySwipe)
        .sensoryFeedback(.selection, trigger: shown.julianDay)
        .sheet(isPresented: $isMonthPresented) {
            MonthView(start: shown, today: today) { picked in
                withAnimation(.snappy) { shown = picked }
            }
        }
        #if DEBUG
        .fullScreenCover(isPresented: $isGalleryPresented) { WidgetGalleryView() }
        .onAppear {
            // Lets screenshot automation open the month sheet: `simctl launch … -openMonth`.
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-openMonth") { isMonthPresented = true }
            if args.contains("-widgetGallery") { isGalleryPresented = true }
        }
        #endif
        .onOpenURL(perform: handle)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            refreshToday()
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            topBar
            Spacer(minLength: 16)
            DateHero(day: shown, theme: theme)
            Spacer(minLength: 20)
            VStack(spacing: 14) {
                LunarPanel(day: shown, theme: theme)
                NextHolidayRow(occurrence: HolidayBook.upcoming(from: shown, firstOffset: 1, limit: 1).first, theme: theme)
                monthButton
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()

            if !isShowingToday {
                Button {
                    withAnimation(.snappy) { shown = today }
                } label: {
                    Text("Hôm nay")
                        .font(Typeface.label(14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(theme.accent, in: Capsule())
                }
                .buttonStyle(PressableStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 44)
        .padding(.top, 8)
        .animation(.snappy, value: isShowingToday)
    }

    private var monthButton: some View {
        Button { isMonthPresented = true } label: {
            HStack {
                Image(systemName: "square.grid.3x3")
                Text("Xem cả tháng")
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(Typeface.label(16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 54)
            .background(theme.ink.opacity(0.88), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: theme.ink.opacity(0.25), radius: 14, y: 8)
        }
        .buttonStyle(PressableStyle())
    }

    private var daySwipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > Self.swipeThreshold, abs(dx) > abs(value.translation.height) * 1.5 else { return }
                withAnimation(.snappy) { shown = shown.adding(days: dx < 0 ? 1 : -1) }
            }
    }

    /// DEBUG only: `simctl launch … -date 15/4/2026` opens on that day (for screenshots of each season).
    private static var launchDay: DayInfo? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-date"), index + 1 < args.count else { return nil }
        let parts = args[index + 1].split(separator: "/").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return DayInfo(solar: SolarDate(day: parts[0], month: parts[1], year: parts[2]))
        #else
        return nil
        #endif
    }

    /// Widget taps: `lichviet://today` shows today, `lichviet://month` also opens the month sheet.
    private func handle(_ url: URL) {
        guard url.scheme == "lichviet" else { return }
        refreshToday()
        shown = today
        isMonthPresented = url.host == "month"
    }

    private func refreshToday() {
        let current = DayInfo.today
        guard current.julianDay != today.julianDay else { return }
        let wasShowingToday = isShowingToday
        today = current
        if wasShowingToday { shown = current }
    }
}

/// Gentle press feedback shared by all buttons.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
