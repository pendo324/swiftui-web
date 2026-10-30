
import CoreGraphics

package struct InIOSBarItemKey: EnvironmentKey {
    package static let defaultValue = false
}

extension EnvironmentValues {
    /// The view is an item of an iOS navigation bar that is not a SwiftUI button (a button is sized by its style).
    public var _inIOSBarItem: Bool {
        get { self[InIOSBarItemKey.self] }
        set { self[InIOSBarItemKey.self] = newValue }
    }
}

package struct IOSBarItemHeightKey: EnvironmentKey {
    package static let defaultValue: CGFloat = 36
}

extension EnvironmentValues {
    /// How tall the items of the bar a view is in are: a push's bar is as tall as its back button, a sheet's smaller.
    public var _iosBarItemHeight: CGFloat {
        get { self[IOSBarItemHeightKey.self] }
        set { self[IOSBarItemHeightKey.self] = newValue }
    }
}

/// The size a bar item that is not a button has: what it is with a button's padding, and at least a button's height.
public func _iosBarItemSize(_ content: CGSize, height: CGFloat) -> CGSize {
    CGSize(width: max(height, content.width + 2 * PlatformMetrics.navigationBarItemPadding), height: max(height, content.height))
}

/// A button of a bar: its label with a button's padding, at least a button's size.
struct _IOSBarButtonBody<Label: View>: View {
    @Environment(\._iosBarItemHeight) private var height
    let label: Label
    let isPressed: Bool
    let prominent: Bool

    var body: some View {
        label
            .environment(\._inIOSBarItem, false)
            .fontWeight(prominent ? .semibold : nil)
            .padding(.horizontal, PlatformMetrics.navigationBarItemPadding)
            .frame(minWidth: height, minHeight: height, maxHeight: height)
            .opacity(isPressed ? 0.6 : 1)
    }
}

extension NavigationStackNode {
    /// The presentation the stack is in (a sheet's), if any.
    var presentationAncestor: PresentationNode? {
        var current = parent
        while let node = current {
            if let presentation = node as? PresentationNode { return presentation }
            current = node.parent
        }
        return nil
    }
}

/// The glass pane of a group of items in an iOS bar.
struct _IOSBarGlass<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        let dark = scheme == .dark
        content
            .background(
                Capsule()
                    .fill(dark ? Color(.sRGB, white: 0.14, opacity: 0.88) : Color(.sRGB, white: 1, opacity: 0.45))
                    .shadow(color: Color(.sRGB, white: 0, opacity: dark ? 0.35 : 0.08), radius: 4, y: 2)
            )
            .overlay(Capsule().strokeBorder(dark ? Color(.sRGB, white: 1, opacity: 0.13) : Color(.sRGB, white: 0, opacity: 0.06), lineWidth: 0.5))
    }
}
