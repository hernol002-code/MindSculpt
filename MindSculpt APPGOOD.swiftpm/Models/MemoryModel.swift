import Foundation
import SwiftData
import SwiftUI

// MARK: - Creature Memory Model
// Audit result: No issues found. SwiftData usage is correct —
// @Model is applied to a final class, all properties are value types,
// and the modelContainer is registered in MyApp (not here).
@Model
final class CreatureMemory {
    var id:            UUID
    var timestamp:     Date
    var colorHex:      String
    var gratitudeText: String

    init(
        id:            UUID   = UUID(),
        timestamp:     Date   = Date(),
        colorHex:      String,
        gratitudeText: String
    ) {
        self.id            = id
        self.timestamp     = timestamp
        self.colorHex      = colorHex
        self.gratitudeText = gratitudeText
    }
}

// MARK: - Color ↔ Hex Conversion
extension Color {
    /// Convert a SwiftUI Color to a hex string (e.g. "#76A5AF").
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red   * 255)
        let g = Int(green * 255)
        let b = Int(blue  * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// Create a SwiftUI Color from a hex string (e.g. "#76A5AF" or "76A5AF").
    static func fromHex(_ hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 3:  (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }

        return Color(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: 1.0
        )
    }
}
