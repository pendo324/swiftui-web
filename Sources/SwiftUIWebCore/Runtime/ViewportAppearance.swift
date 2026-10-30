// Appearing in a scroll view's viewport (patched in by tools/ios/web/lazy-viewport.py).
//
// A view in the elements of a lazy container (a row of a list, an item of a lazy stack) appears when it comes into the scroll view's viewport and disappears
// when it leaves, as a cell of a list does, and not when the container makes it: the container makes some of what is past the screen, to be ready.

/// A `ForEach` that is in a lazy container.
@MainActor
package protocol _LazyElementHost: AnyObject {
    var hostsLazyElements: Bool { get }
}

extension ForEachNode: _LazyElementHost {
    package var hostsLazyElements: Bool { lazyAxis != nil }
}

/// A node that appears and disappears as its place comes into and goes out of a scroll view's viewport.
@MainActor
package protocol _ViewportAppearing: AnyObject {
    var viewportScroll: (any _ScrollViewport)? { get }
    /// Where the node's views are, in the window; nil when it has none to be seen.
    var appearanceFrame: CGRect? { get }
    func viewportVisibilityChanged(_ visible: Bool)
}

extension _ViewportAppearing where Self: ViewNode {
    package var appearanceFrame: CGRect? {
        var frame: CGRect?
        for node in layoutChildren {
            let found = node.frameInRoot
            frame = frame.map { $0.union(found) } ?? found
        }
        return frame
    }
}

/// The viewport a view appears in, when it is in the elements of a lazy container: the nearest scroll view above the container. Nil for any other view,
/// which appears when it is made.
@MainActor
package func _viewportOfLazyContent(_ node: ViewNode) -> (any _ScrollViewport)? {
    var lazy = false
    var current = node.parent
    while let ancestor = current {
        if let host = ancestor as? any _LazyElementHost, host.hostsLazyElements { lazy = true }
        if lazy, let scroll = ancestor as? any _ScrollViewport { return scroll }
        current = ancestor.parent
    }
    return nil
}

extension Runtime {
    /// Tells each node that appears in a viewport whether it is in it, after a frame: a view of no size is where its corner is, and a node with no view is
    /// there at once.
    package func updateViewportAppearance() {
        guard !viewportAppearers.isEmpty else { return }
        viewportAppearers.removeAll { $0.node?.isMounted != true }
        for entry in viewportAppearers {
            guard let node = entry.node as? any _ViewportAppearing, let scroll = node.viewportScroll else { continue }
            let viewport = scroll.frameInRoot
            let visible: Bool
            if let frame = node.appearanceFrame {
                if frame.width <= 0 || frame.height <= 0 {
                    visible = viewport.contains(frame.origin)
                } else {
                    visible = frame.maxX > viewport.minX && frame.minX < viewport.maxX && frame.maxY > viewport.minY && frame.minY < viewport.maxY
                }
            } else {
                visible = true
            }
            node.viewportVisibilityChanged(visible)
        }
    }
}
