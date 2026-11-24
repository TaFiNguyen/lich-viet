import SwiftUI
import UIKit

/// Seasonal painted backdrop (public-domain museum art via Unsplash, see README credits) with a pastel wash so text stays readable.
struct SceneryView: View {
    enum Wash {
        /// Light veil, strongest at the top where the date sits.
        case soft
        /// Heavier veil for dense content such as month grids.
        case strong
    }

    let theme: SeasonTheme
    var wash: Wash = .soft
    var isAnimated = false

    @State private var isZoomed = false
    private static let zoomDuration: Double = 24
    private static let cache = NSCache<NSString, UIImage>()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [theme.skyTop, theme.skyBottom], startPoint: .top, endPoint: .bottom)
                if let image = Self.photo(named: theme.photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .scaleEffect(isZoomed ? 1.08 : 1)
                        .clipped()
                    // Re-tint aged museum paper toward the season's pastel palette.
                    LinearGradient(colors: [theme.skyTop, theme.skyBottom], startPoint: .top, endPoint: .bottom)
                        .blendMode(.color)
                        .opacity(0.4)
                }
                veil
            }
        }
        .accessibilityHidden(true)
        .onAppear {
            guard isAnimated else { return }
            withAnimation(.easeInOut(duration: Self.zoomDuration).repeatForever(autoreverses: true)) {
                isZoomed = true
            }
        }
    }

    private var veil: some View {
        let top = wash == .strong ? 0.7 : 0.5
        let middle = wash == .strong ? 0.45 : 0.12
        let bottom = wash == .strong ? 0.35 : 0
        return ZStack {
            theme.skyBottom.opacity(wash == .strong ? 0.25 : 0.18)
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(top), location: 0),
                    .init(color: .white.opacity(middle), location: 0.55),
                    .init(color: .white.opacity(bottom), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    /// Loads a bundled JPEG once per process; app and widget each ship their own size.
    private static func photo(named name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        let url = Bundle.main.url(forResource: name, withExtension: "jpg")
            ?? Bundle.main.url(forResource: name, withExtension: "jpg", subdirectory: "Backgrounds")
        guard let url, let image = UIImage(contentsOfFile: url.path) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }
}
