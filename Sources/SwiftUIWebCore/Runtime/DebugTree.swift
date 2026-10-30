extension Runtime {
    /// An indented dump of the node tree, one node per line.
    public func debugTree() -> String { root.dump() }
    /// How many frames were laid out in full (not just scrolled): what a bench of scrolling says it did.
    public var fullLayouts: UInt64 { fullLayoutCount }
}
