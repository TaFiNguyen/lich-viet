import CoreText
import SwiftUI
import UIKit

/// Two-family type system:
/// - Fraunces (soft, optical-size serif) for numerals and titles.
/// - Be Vietnam Pro (built for Vietnamese diacritics) for everything else.
enum Typeface {
    private static let serifFile = "Fraunces"
    private static let sansFiles = ["BeVietnamPro-Regular", "BeVietnamPro-Medium", "BeVietnamPro-SemiBold", "BeVietnamPro-Bold"]

    /// Registers the bundled fonts for this process. Call once from the app and the widget extension.
    static func register() {
        for name in [serifFile] + sansFiles {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Missing bundled font \(name).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                // Already-registered is expected on re-entry; anything else falls back to system fonts.
                error?.release()
            }
        }
    }

    /// Big display numbers: heavier, fully soft.
    static func numeral(_ size: CGFloat) -> Font { serif(size, weight: 620) }
    /// Headings such as month names and lunar month labels.
    static func title(_ size: CGFloat) -> Font { serif(size, weight: 520) }

    static func label(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .custom(sansName(for: weight), size: size)
    }

    private static func sansName(for weight: Font.Weight) -> String {
        switch weight {
        case .regular, .light, .thin, .ultraLight: return "BeVietnamPro-Regular"
        case .semibold: return "BeVietnamPro-SemiBold"
        case .bold, .heavy, .black: return "BeVietnamPro-Bold"
        default: return "BeVietnamPro-Medium"
        }
    }

    /// Fraunces with explicit variation axes: weight, optical size matched to point size, max softness.
    private static func serif(_ size: CGFloat, weight: CGFloat) -> Font {
        let axes: [Int: CGFloat] = [
            fourCC("wght"): weight,
            fourCC("opsz"): min(max(size, 9), 144),
            fourCC("SOFT"): 100,
            fourCC("WONK"): 0,
        ]
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: "Fraunces-Regular",
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): axes,
        ])
        return Font(UIFont(descriptor: descriptor, size: size) as CTFont)
    }

    private static func fourCC(_ tag: String) -> Int {
        tag.unicodeScalars.reduce(0) { ($0 << 8) | Int($1.value) }
    }
}
