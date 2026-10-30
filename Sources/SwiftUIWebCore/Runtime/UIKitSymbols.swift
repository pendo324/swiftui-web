
import CoreGraphics

/// A symbol as a UIKit image draws it: the box it occupies, and what draws it.
public struct _UIKitSymbol {
    public let size: CGSize
    let symbol: (glyph: SymbolGlyph, outline: SymbolGlyphOutline)
    let weight: Int

    /// The commands that draw the symbol in `color` into the box `(0, 0, size)`, y down.
    @MainActor public func commands(color: RGBA) -> [DisplayCommand] {
        var list = DisplayList()
        _SymbolPainter.paint(symbol, in: CGRect(origin: .zero, size: size), weight: weight, color: color, into: &list)
        return list.commands
    }
}

/// `name` at `pointSize` (0: 17), `weight` (UIImage.SymbolWeight's raw value, 0: regular) and `scale` (UIImage.SymbolScale's, 0: medium); nil for a name with no glyph.
@MainActor public func _uiKitSymbol(named name: String, pointSize: CGFloat, weight: Int, scale: Int) -> _UIKitSymbol? {
    var environment = EnvironmentValues()
    environment.platformProfile = PlatformProfile.iOS
    let fontWeight: Font.Weight
    switch weight {
    case 1: fontWeight = .ultraLight
    case 2: fontWeight = .thin
    case 3: fontWeight = .light
    case 5: fontWeight = .medium
    case 6: fontWeight = .semibold
    case 7: fontWeight = .bold
    case 8: fontWeight = .heavy
    case 9: fontWeight = .black
    default: fontWeight = .regular
    }
    let imageScale: Image.Scale = scale == 1 ? .small : scale == 3 ? .large : .medium
    environment.font = Font.system(size: pointSize > 0 ? pointSize : 17, weight: fontWeight)
    environment.imageScale = imageScale
    let font = environment._resolvedFont
    let measured = SystemSymbolMetrics.size(named: name, pointSize: font.size, weight: font.weight, scale: imageScale, legacy: true)
    guard let symbol = SystemSymbolGlyphs.glyph(named: name, font: font, imageScale: imageScale, box: measured) ?? SystemSymbolGlyphs.glyph(named: name) else { return nil }
    let box: SystemSymbolMetrics.Size
    if let measured {
        box = measured
    } else {
        // A glyph with no measurement takes the star's size at this font, as an image's does.
        let star = SystemSymbolMetricsTable.values(named: "star", legacy: true) ?? []
        box = star.count >= 36 ? SystemSymbolMetrics.size(values: star, pointSize: font.size, weight: font.weight, scale: imageScale) : SystemSymbolMetrics.fallback
    }
    return _UIKitSymbol(size: CGSize(width: box.width, height: box.height), symbol: symbol, weight: font.weight.value)
}
