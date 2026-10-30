
// A navigation stack as UIKit sees it: see tools/ios/web/build.sh.

/// A screen of a stack: the root, or an entry pushed on it. UIKit has a view controller for each.
public final class _ScreenToken {}

/// Where the two screens of a transition are: how far each has been moved sideways, and how much of the lower one the upper covers (from 0
/// to 1), which the bars and the dimming follow.
public struct _StackSlide {
    public var lowerShift: CGFloat
    public var upperShift: CGFloat
    public var cover: Double

    public init(lowerShift: CGFloat, upperShift: CGFloat, cover: Double) {
        self.lowerShift = lowerShift
        self.upperShift = upperShift
        self.cover = cover
    }
}

@MainActor
public protocol _StackBridge: AnyObject {
    /// The stack exists: its screens are about to be made (the views of a screen look for the screen they are in).
    func stackMounted(_ stack: _StackHandle)
    /// The stack has its first screens.
    func stackDidMount(_ stack: _StackHandle)
    /// A tab view exists: its tabs are about to be made.
    func tabsMounted(_ tabs: _TabsHandle)
    func tabsUnmounted(_ tabs: _TabsHandle)
    func stackUnmounted(_ stack: _StackHandle)
    /// The stack's frame, in the window, changed.
    func stack(_ stack: _StackHandle, placedAt frame: CGRect)
    /// The stack's screens changed from `before` to `after` (bottom first). When UIKit animates the change, the answer says where the
    /// screens are at each frame until the bridge calls `endSlide()`.
    func stack(_ stack: _StackHandle, from before: [AnyObject], to after: [AnyObject], animated: Bool) -> (@MainActor () -> _StackSlide)?
}

extension _StackBridge {
    public func tabsMounted(_ tabs: _TabsHandle) {}
    public func tabsUnmounted(_ tabs: _TabsHandle) {}
}

@MainActor public var _stackBridge: (any _StackBridge)?

/// A tab view, for its bridge.
@MainActor
public final class _TabsHandle {
    package unowned let node: TabViewNode
    public var userData: AnyObject?

    package init(node: TabViewNode) { self.node = node }

    public var titles: [String] { node.tabs.map(\.title) }
    public var badges: [String?] { node.tabs.map(\.badge) }
    public var selectedIndex: Int? { node.selectedIndex }
    public var frame: CGRect { node.frameInRoot }
    /// The tab bar, in the window.
    public var barFrame: CGRect {
        let origin = node.frameInRoot.origin
        return node.bar.offsetBy(dx: origin.x, dy: origin.y)
    }
    public var isIOS: Bool { node.environment.platformProfile.isIOS }

    /// The person (or the app) selects the tab.
    public func select(index: Int) { node.selectTab(at: index) }
}

/// The screen a view is in, in its environment: which screen of which stack.
public struct _ScreenLocation {
    public let token: AnyObject
    public let stack: _StackHandle
}

private struct _ScreenLocationKey: EnvironmentKey {
    static var defaultValue: _ScreenLocation? { nil }
}

extension EnvironmentValues {
    public var _screen: _ScreenLocation? {
        get { self[_ScreenLocationKey.self] }
        set { self[_ScreenLocationKey.self] = newValue }
    }
}

/// A stack, for its bridge.
@MainActor
public final class _StackHandle {
    package unowned let node: NavigationStackNode
    public var userData: AnyObject?

    package init(node: NavigationStackNode) { self.node = node }

    /// The stack's screens, bottom first.
    public var screens: [AnyObject] { node.screenTokens }
    public var frame: CGRect { node.frameInRoot }
    public var isIOS: Bool { node.environment.platformProfile.isIOS }

    /// The tab view the stack is in, and the tab of it.
    public var tab: (tabs: _TabsHandle, index: Int)? {
        var up = node.parent
        while let ancestor = up {
            if let tabView = ancestor as? TabViewNode, let handle = tabView.tabsHandle {
                for (index, tab) in tabView.tabs.enumerated() {
                    var inside: ViewNode? = node
                    while let candidate = inside, candidate !== tab.node { inside = candidate.parent }
                    if inside != nil { return (handle, index) }
                }
                return nil
            }
            up = ancestor.parent
        }
        return nil
    }

    /// A transition began that UIKit started: the top screen goes over `lower`. Nothing in the stack has changed yet.
    public func beginSlide(lower: AnyObject, provider: @escaping @MainActor () -> _StackSlide) {
        node.beginExternalSlide(lower: lower, provider: provider)
    }

    public func endSlide() { node.finishSlide() }

    /// The stack drops the screens on top of it that are not in `keeping` (UIKit popped them), without a slide.
    public func reconcile(keeping screens: [AnyObject]) { node.reconcile(keepingScreens: screens) }
}

/// Called after each layout of the whole page (a tab was selected, a screen was pushed).
@MainActor public var _layoutObserver: (@MainActor () -> Void)?

/// Where a view is, asked for when it is wanted (`frameInRoot`) and not recorded after each layout: the place of a hosted UIKit view.
@MainActor
public final class _FrameSource {
    package weak var node: ViewNode?
    public init() {}
    public var frame: CGRect? { node.map { $0.frameInRoot } }
}

public struct _FrameSourceModifier: Equatable {
    public let source: _FrameSource
    public init(source: _FrameSource) { self.source = source }
    public static func == (a: _FrameSourceModifier, b: _FrameSourceModifier) -> Bool { a.source === b.source }
}

extension _FrameSourceModifier: ViewModifier {
    public typealias Body = Never

    public static func _makeNode<Content: View>(_ context: _NodeContext<ModifiedContent<Content, Self>>) -> TypedNode<ModifiedContent<Content, Self>> {
        FrameSourceNode(context)
    }
}

extension View {
    nonisolated public func _frameSource(_ source: _FrameSource) -> some View {
        modifier(_FrameSourceModifier(source: source))
    }
}

@MainActor
package final class FrameSourceNode<Content: View>: UnaryLayoutModifierNode<Content, _FrameSourceModifier> {
    override package func placeTarget(_ target: ViewNode, in bounds: CGRect, proposal: ProposedViewSize, by placer: ViewNode) {
        super.placeTarget(target, in: bounds, proposal: proposal, by: placer)
        modifier.source.node = target
    }
}
