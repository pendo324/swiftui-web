// A view told when it is let go of (patched in by tools/ios/web/lazy-viewport.py).

/// What is run when the view it is on is let go of.
public final class _UnmountHandler {
    package let run: @MainActor () -> Void
    public init(_ run: @escaping @MainActor () -> Void) { self.run = run }
}

public struct _UnmountModifier: Equatable {
    package let handler: _UnmountHandler
    public init(handler: _UnmountHandler) { self.handler = handler }
    public static func == (a: _UnmountModifier, b: _UnmountModifier) -> Bool { a.handler === b.handler }
}

extension _UnmountModifier: ViewModifier {
    public typealias Body = Never

    public static func _makeNode<Content: View>(_ context: _NodeContext<ModifiedContent<Content, Self>>) -> TypedNode<ModifiedContent<Content, Self>> {
        UnmountNode(context)
    }
}

@MainActor
package final class UnmountNode<Content: View>: UnaryLayoutModifierNode<Content, _UnmountModifier> {
    override package func unmount() {
        view.modifier.handler.run()
        super.unmount()
    }
}

extension View {
    nonisolated public func _onUnmount(_ handler: _UnmountHandler) -> some View {
        modifier(_UnmountModifier(handler: handler))
    }
}
