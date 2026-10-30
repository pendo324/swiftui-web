import Foundation
let _traceLayoutOn = getenv("SWIFTUI_TRACE_LAYOUT") != nil
/// `SWIFTUI_FULL_LAYOUT=1`: every frame is laid out in full, as a check of what a frame that only scrolled shows.
let _forceFullLayout = getenv("SWIFTUI_FULL_LAYOUT") != nil
func _traceLayout(_ message: @autoclosure () -> String) {
    if _traceLayoutOn { fputs("SwiftUI: layout: \(message())\n", stderr) }
}
/// `SWIFTUI_TRACE_WALKS=1`: where each whole-subtree search (`descendants(where:)`) of a frame was asked for, with how many.
let _traceWalks = getenv("SWIFTUI_TRACE_WALKS") != nil
nonisolated(unsafe) var _walkCounts: [String: Int] = [:]
func _flushWalks() {
    guard _traceWalks, !_walkCounts.isEmpty else { return }
    let top = _walkCounts.sorted { $0.value > $1.value }.prefix(8).map { "\($0.value)x \($0.key)" }.joined(separator: ", ")
    fputs("SwiftUI: walks: \(_walkCounts.values.reduce(0, +)) [\(top)]\n", stderr)
    _walkCounts.removeAll()
}
let _dumpFrames = getenv("SWIFTUI_TREE_FRAMES") != nil
/// `SWIFTUI_VERIFY_STRUCTURE=1`: what is remembered of the tree's shape (`layoutChildren`, `firstDescendant`) is made again each time it is used, and a
/// difference is said: the tree changed in a way `treeVersion` did not hear of.
let _verifyStructure = getenv("SWIFTUI_VERIFY_STRUCTURE") != nil
@MainActor func _checkKept(_ kept: [ViewNode], _ fresh: [ViewNode], _ what: @autoclosure () -> String) {
    guard kept.count != fresh.count || !zip(kept, fresh).allSatisfy({ $0 === $1 }) else { return }
    fputs("SwiftUI: stale: \(what()) was \(kept.map { $0.nodeDescription }) and is \(fresh.map { $0.nodeDescription })\n", stderr)
}
func _dumpNumber(_ value: CGFloat) -> Int { value.isFinite ? Int(value.rounded()) : -1 }
