#if DEBUG
import SwiftUI
import WidgetKit

/// DEBUG-only preview of every widget family, rendered in-app so they can be screenshotted.
/// Launch with `-widgetGallery`. Sizes match a 6.3" iPhone home screen.
struct WidgetGalleryView: View {
    private let entries = [
        DayEntry.make(for: .today, at: .now),
        DayEntry.make(for: DayInfo(solar: SolarDate(day: 17, month: 2, year: 2026)), at: .now),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                tile(entries[0], wash: .strong, size: CGSize(width: 364, height: 382)) {
                    MonthWidgetView(entry: entries[0])
                }
                ForEach(entries, id: \.day.julianDay) { entry in
                    HStack(spacing: 18) {
                        tile(entry, size: CGSize(width: 170, height: 170)) {
                            TodayWidgetView(entry: entry, family: .systemSmall)
                        }
                        lockScreen(entry)
                    }
                    tile(entry, size: CGSize(width: 364, height: 170)) {
                        TodayWidgetView(entry: entry, family: .systemMedium)
                    }
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
        }
        .background {
            // Painted "wallpaper" so App Store screenshots look like a home screen.
            SceneryView(theme: .tet)
                .blur(radius: 18)
                .overlay(Color.black.opacity(0.18))
                .ignoresSafeArea()
        }
    }

    private func tile<Content: View>(
        _ entry: DayEntry, wash: SceneryView.Wash = .soft, size: CGSize, @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(16)
            .frame(width: size.width, height: size.height)
            .background(SceneryView(theme: .of(entry.day), wash: wash))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func lockScreen(_ entry: DayEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TodayWidgetView(entry: entry, family: .accessoryInline)
                .frame(width: 172, alignment: .leading)
            HStack(spacing: 10) {
                TodayWidgetView(entry: entry, family: .accessoryCircular)
                    .frame(width: 64, height: 64)
                    .background(.white.opacity(0.15), in: Circle())
            }
            TodayWidgetView(entry: entry, family: .accessoryRectangular)
                .frame(width: 172, height: 72)
        }
        .foregroundStyle(.white)
        .frame(width: 176, height: 170, alignment: .leading)
    }
}
#endif
