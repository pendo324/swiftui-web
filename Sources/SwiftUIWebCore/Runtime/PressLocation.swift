import Foundation

/// Where the press that the gesture being recognized began, in the space of its node, and the host's time for it.
@MainActor public var _lastPressLocation = CGPoint.zero
@MainActor public var _lastPressTime = 0.0
