/// What an engine that has the symbol font offers: whether it has a symbol, and its outline for a font, an
/// image scale (0 small, 1 medium, 2 large) and the box the measured size gives (width, height and how far
/// the box's bottom is below the baseline).
public struct NativeSymbolProvider {
    public var has: @MainActor (String) -> Bool
    public var glyph: @MainActor (_ name: String, _ font: ResolvedFont, _ scale: Int, _ box: (width: Double, height: Double, descent: Double)?) -> (outline: [Double], width: Double, height: Double)?

    public init(has: @escaping @MainActor (String) -> Bool,
                glyph: @escaping @MainActor (_ name: String, _ font: ResolvedFont, _ scale: Int, _ box: (width: Double, height: Double, descent: Double)?) -> (outline: [Double], width: Double, height: Double)?) {
        self.has = has
        self.glyph = glyph
    }
}

extension SystemSymbolGlyphs {
    public static var native: NativeSymbolProvider?

    /// Whether `name` has a glyph, the stand-in's or the font's.
    public static func hasGlyph(_ name: String) -> Bool { table[name] != nil || native?.has(name) == true }

    /// Whether the symbol font has `name` (whether or not it could be had from it just now).
    public static func hasNativeGlyph(_ name: String) -> Bool { native?.has(name) == true }

    /// The font's glyph for `name`: filled (mode 3), its outline's coordinates those of the box.
    public static func nativeGlyph(named name: String, font: ResolvedFont, scale: Int, box: (width: Double, height: Double, descent: Double)?) -> (SymbolGlyph, SymbolGlyphOutline)? {
        guard let found = native?.glyph(name, font, scale, box), !found.outline.isEmpty else { return nil }
        return (SymbolGlyph(icon: name, mode: 3),
                SymbolGlyphOutline(firstElement: found.outline.count, bounds: (0, 0, found.width, found.height), ops: found.outline))
    }
}
