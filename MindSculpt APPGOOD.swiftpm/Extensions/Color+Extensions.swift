import SwiftUI

// MARK: - Color Extensions (Polyvagal Theory Scientific Palette)
// Audit result: No issues found.
// Note: toHex() and fromHex() live in MemoryModel.swift (co-located with
// CreatureMemory) to keep persistence logic together. All other color
// utilities are defined here.
extension Color {

    // MARK: - Semantic Palette

    /// Ventral Vagal State — Safety & Regulation
    static let ventralTeal   = Color(hex: "76A5AF")
    /// Stress Reduction
    static let lavenderMist  = Color(hex: "E6E6FA")
    /// Text & Contrast
    static let deepSlate     = Color(hex: "2C3E50")
    /// Dopamine Accents
    static let mutedSunshine = Color(hex: "F7DC6F")
    /// Heart & Life
    static let softCoral     = Color(hex: "F1948A")

    // MARK: - Predefined Palettes

    static let calmPalette:       [Color] = [ventralTeal, lavenderMist, mutedSunshine]
    static let regulationPalette: [Color] = [deepSlate,   ventralTeal,  lavenderMist]
    static let emotionPalette:    [Color] = [mutedSunshine, softCoral,  ventralTeal]

    // MARK: - Gradient Helpers

    /// Background gradient: Dark → Calm
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [deepSlate, ventralTeal]),
            startPoint: .topLeading,
            endPoint:   .bottomTrailing
        )
    }

    /// Button gradient
    static var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [ventralTeal, lavenderMist]),
            startPoint: .topLeading,
            endPoint:   .bottomTrailing
        )
    }

    // MARK: - Emotion Color Mapping

    /// Returns a palette color that best represents the detected emotion keyword.
    static func emotionColor(for keyword: String) -> Color {
        let word = keyword.lowercased()

        if word.contains("happy")  || word.contains("joy")       ||
           word.contains("excited") || word.contains("great")    ||
           word.contains("amazing") || word.contains("wonderful") {
            return .mutedSunshine
        }

        if word.contains("sad")   || word.contains("down")   ||
           word.contains("depressed") || word.contains("blue") ||
           word.contains("lonely") || word.contains("tired") {
            return .ventralTeal
        }

        if word.contains("angry") || word.contains("mad")       ||
           word.contains("frustrated") || word.contains("annoyed") ||
           word.contains("upset") || word.contains("stress") {
            return .softCoral
        }

        return .lavenderMist
    }

    // MARK: - Hex Initializer

    /// Initialize a Color from a hex string (e.g. `"76A5AF"` or `"#76A5AF"`).
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
