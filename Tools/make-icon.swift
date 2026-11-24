// Renders the 1024px app icon: Tết painting + calendar page with a soft Fraunces "1" and a crescent moon.
// Usage: swift Tools/make-icon.swift App/Backgrounds/bg-tet.jpg Shared/Fonts/Fraunces.ttf App/Assets.xcassets/AppIcon.appiconset/icon-1024.png
import AppKit
import CoreText

let args = CommandLine.arguments
let bgPath = args[1], fontPath = args[2], out = args[3]
let S = 1024.0
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 4096, bitsPerPixel: 32)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
func c(_ h: UInt32, _ a: CGFloat = 1) -> NSColor { NSColor(srgbRed: CGFloat((h>>16)&255)/255, green: CGFloat((h>>8)&255)/255, blue: CGFloat(h&255)/255, alpha: a) }

// 1. Painted background: square crop from the upper-middle of the Tết painting
let bg = NSImage(contentsOfFile: bgPath)!
let bw = bg.size.width, bh = bg.size.height
let crop = NSRect(x: 0, y: bh * 0.30, width: bw, height: bw)
bg.draw(in: NSRect(x: 0, y: 0, width: S, height: S), from: crop, operation: .copy, fraction: 1)
// pastel veil: warm cream at bottom, pink at top
NSGradient(colors: [c(0xFFF1D8, 0.35), c(0xFFC6BF, 0.25)])!.draw(in: NSRect(x: 0, y: 0, width: S, height: S), angle: 90)
NSGradient(colors: [c(0xFFFFFF, 0.0), c(0xFFFFFF, 0.28), c(0xFFFFFF, 0.0)])!
  .draw(fromCenter: NSPoint(x: 512, y: 500), radius: 0, toCenter: NSPoint(x: 512, y: 500), radius: 520, options: [])

// 2. Calendar page card
let card = NSRect(x: 232, y: 196, width: 560, height: 620)
let cardPath = NSBezierPath(roundedRect: card, xRadius: 96, yRadius: 96)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -22), blur: 60, color: c(0x631915, 0.28).cgColor)
c(0xFFFBF3).setFill(); cardPath.fill()
ctx.restoreGState()
// red header band
ctx.saveGState(); cardPath.addClip()
NSGradient(colors: [c(0xD93A4F), c(0xC4122F)])!.draw(in: NSRect(x: card.minX, y: card.maxY - 150, width: card.width, height: 150), angle: -90)
ctx.restoreGState()
// binding rings
for x in [card.minX + 170, card.maxX - 170] {
  let ring = NSBezierPath(roundedRect: NSRect(x: x - 22, y: card.maxY - 60, width: 44, height: 110), xRadius: 22, yRadius: 22)
  c(0xFFFBF3).setFill(); ring.fill()
  c(0x8E3F33, 0.35).setStroke(); ring.lineWidth = 4; ring.stroke()
}

// 3. Big soft serif "1" in Fraunces (SOFT 100, wght 640)
let descs = CTFontManagerCreateFontDescriptorsFromURL(URL(fileURLWithPath: fontPath) as CFURL) as! [CTFontDescriptor]
func tag(_ s: String) -> Int { s.unicodeScalars.reduce(0) { ($0 << 8) | Int($1.value) } }
let variation: [Int: CGFloat] = [tag("wght"): 760, tag("opsz"): 144, tag("SOFT"): 100, tag("WONK"): 0]
let vdesc = CTFontDescriptorCreateCopyWithAttributes(descs[0], [kCTFontVariationAttribute: variation] as CFDictionary)
let font = CTFontCreateWithFontDescriptor(vdesc, 360, nil) as NSFont
let num = NSAttributedString(string: "1", attributes: [.font: font, .foregroundColor: c(0x631915)])
// Center the glyph's ink box inside the paper area (between moon and header band).
let line = CTLineCreateWithAttributedString(num)
let ink = CTLineGetImageBounds(line, ctx)
let paperTop = card.maxY - 150 - 40, paperBottom = 330.0
let originY = paperBottom + (paperTop - paperBottom - ink.height) / 2 - ink.minY
ctx.textPosition = CGPoint(x: 512 - ink.width / 2 - ink.minX, y: originY)
CTLineDraw(line, ctx)

// 4. Small red crescent moon under the numeral
let mc = NSPoint(x: 512, y: 275), r = 42.0
ctx.saveGState()
let moon = NSBezierPath(ovalIn: NSRect(x: mc.x - r, y: mc.y - r, width: 2*r, height: 2*r))
moon.addClip()
c(0xC4122F).setFill(); moon.fill()
c(0xFFFBF3).setFill(); NSBezierPath(ovalIn: NSRect(x: mc.x - r - 26, y: mc.y - r + 10, width: 2*r, height: 2*r)).fill()
ctx.restoreGState()

NSGraphicsContext.current?.flushGraphics()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
