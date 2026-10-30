
#if os(WASI)
import WebFoundation
#else
import Foundation
#endif

/// A row of a list, and the list, as a UIKit view in the row is in them.
public struct _ListCell {
    /// The list, and the row in it: what they are called for as long as they are there.
    public let list: ObjectIdentifier
    public let row: ObjectIdentifier
    /// The row's cell (the width of the list), and the list's scroll view (what it shows), in the page's coordinates.
    public let frame: CGRect
    public let viewport: CGRect
}

@MainActor
package protocol _ListCellProviding: AnyObject {
    /// The cell of the row `target` is in, if it is in a row of this list.
    func cell(containing target: ViewNode) -> _ListCell?
}

extension _FrameSource {
    /// The row of a list the view is in.
    public var cell: _ListCell? {
        guard let node else { return nil }
        var up = node.parent
        while let ancestor = up {
            if let list = ancestor as? _ListCellProviding, let found = list.cell(containing: node) { return found }
            up = ancestor.parent
        }
        return nil
    }
}
