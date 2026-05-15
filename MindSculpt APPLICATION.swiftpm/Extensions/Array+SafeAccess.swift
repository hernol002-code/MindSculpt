import Foundation

// MARK: - Array Safe Access Extension
// Audit result: No issues found.
// Used by LavaLampBackground to safely index into the palette array
// without risking an out-of-bounds crash.
extension Array {
    /// Returns the element at `index` if it is within bounds, otherwise `nil`.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
