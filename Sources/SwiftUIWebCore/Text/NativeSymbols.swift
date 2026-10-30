extension SystemSymbolGlyphs {
    /// The symbol font's glyph for `name` at `font` and `imageScale`, in the box of the measured `size`.
    package static func glyph(named name: String, font: ResolvedFont, imageScale: Image.Scale, box size: SystemSymbolMetrics.Size?) -> (glyph: SymbolGlyph, outline: SymbolGlyphOutline)? {
        let scale = imageScale == .small ? 0 : imageScale == .large ? 2 : 1
        guard let found = nativeGlyph(named: name, font: font, scale: scale, box: size.map { (Double($0.width), Double($0.height), Double($0.descent)) }) else { return nil }
        return (found.0, found.1)
    }
}
