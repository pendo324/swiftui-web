
import CoreGraphics

package struct IOSBarGroupedKey: EnvironmentKey {
    package static let defaultValue = false
}

extension EnvironmentValues {
    /// The view is in a stack of a bar item, whose buttons are the glyphs' boxes and not each a circle.
    public var _iosBarGrouped: Bool {
        get { self[IOSBarGroupedKey.self] }
        set { self[IOSBarGroupedKey.self] = newValue }
    }
}

/// A stack that is in a bar item: its buttons are a group of the pane's, 2.5 pt in from the pane's ends.
public struct _IOSBarGroup: View {
    @Environment(\._inIOSBarItem) private var inBar
    let content: AnyView

    public init(_ content: AnyView) { self.content = content }

    @ViewBuilder
    public var body: some View {
        if inBar {
            content.padding(.horizontal, 2.5).environment(\._iosBarGrouped, true)
        } else {
            content
        }
    }
}

/// The padding of a bar button: 2.25 pt in a group, 7 pt either side of a glyph and 12 either side of a title.
public struct _BarButtonPadding: Equatable {
    package let grouped: Bool
    public init(grouped: Bool) { self.grouped = grouped }
}

extension _BarButtonPadding: ViewModifier {
    public typealias Body = Never

    public static func _makeNode<Content: View>(_ context: _NodeContext<ModifiedContent<Content, Self>>) -> TypedNode<ModifiedContent<Content, Self>> {
        BarButtonPaddingNode(context)
    }
}

@MainActor
package final class BarButtonPaddingNode<Content: View>: UnaryLayoutModifierNode<Content, _BarButtonPadding> {
    override package var changesChildSize: Bool { true }

    private var padding: CGFloat {
        if modifier.grouped { return 2.25 }
        return child.descendants(where: { $0 is TextNode }).isEmpty ? 7 : PlatformMetrics.navigationBarItemPadding
    }

    override package func childProposal(_ proposal: ProposedViewSize) -> ProposedViewSize {
        let padding = padding
        return ProposedViewSize(width: proposal.width.map { max(0, $0 - 2 * padding) }, height: proposal.height)
    }

    override package func size(forChild childSize: CGSize, proposal: ProposedViewSize) -> CGSize {
        CGSize(width: childSize.width + 2 * padding, height: childSize.height)
    }

    override package func childOrigin(_ child: ViewDimensions, in size: CGSize) -> CGPoint {
        CGPoint(x: padding, y: 0)
    }
}
