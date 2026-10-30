
/// Offered each touch: 0 it went down, 1 it moved, 2 it went up; at a point of the window, at a time in seconds. True once it is a recogniser's.
@MainActor public var _touchHook: (@MainActor (Int, CGPoint, Double) -> Bool)?

extension Runtime {
    /// The touch in flight is a recogniser's: a press under it is cancelled and nothing scrolls or is dragged by it.
    package func claimTouch() {
        pressedNode?.pressEnded(inside: false)
        pressedNode = nil
        for node in simultaneousPressNodes { node.pressEnded(inside: false) }
        simultaneousPressNodes = []
        focusPressNode = nil
        pendingDrag = nil
        if let state = pan {
            pan = nil
            state.nodes.first?.endTracking(velocity: .zero)
        }
    }
}
