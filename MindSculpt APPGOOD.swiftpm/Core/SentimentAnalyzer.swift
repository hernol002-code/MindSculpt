import SwiftUI
import NaturalLanguage

// MARK: - Sentiment Analyzer
//
// FIX BUG-02:
//
//
@MainActor
final class SentimentAnalyzer: ObservableObject {
    @Published var score: Double = 0.0
    @Published var isAnalyzing: Bool = false
    @Published var stressLevel: Double = 0.5

    /// Analiza el sentimiento del texto y actualiza `score` y `stressLevel`.
    /// Ahora es propiamente `async` — el caller puede hacer `await` y leer
    /// los valores con confianza después.
    func analyze(_ text: String) async {
        guard !text.isEmpty else {
            score = 0.0
            stressLevel = 0.5
            return
        }

        isAnalyzing = true
        defer { isAnalyzing = false }

        // Computación pesada fuera del main actor para no bloquear UI.
        // Devuelve el valor para asignarlo de vuelta en main.
        let computed = await Task.detached(priority: .userInitiated) {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text

            // Detección automática de idioma → mejor accuracy en español/inglés.
            if let lang = NLLanguageRecognizer.dominantLanguage(for: text) {
                tagger.setLanguage(lang, range: text.startIndex..<text.endIndex)
            }

            let (sentiment, _) = tagger.tag(
                at: text.startIndex,
                unit: .paragraph,
                scheme: .sentimentScore
            )

            return Double(sentiment?.rawValue ?? "0") ?? 0.0
        }.value

        score = computed
        stressLevel = max(0.2, min(0.95, (1.0 - computed) / 2.0))

        print("🧠 AI Score: \(computed) | Stress Level: \(stressLevel)")
    }

    // MARK: - Helper Methods

    /// Get emotional state description
    func getEmotionalState() -> String {
        if stressLevel < 0.3 {
            return "Calm"
        } else if stressLevel < 0.5 {
            return "Slightly Tense"
        } else if stressLevel < 0.7 {
            return "Stressed"
        } else {
            return "Very Stressed"
        }
    }

    /// Get color based on stress level
    func getStressColor() -> Color {
        let red = 0.3 + (stressLevel * 0.6)
        let green = 0.1 * (1.0 - stressLevel)
        let blue = 0.1 * (1.0 - stressLevel)
        return Color(red: red, green: green, blue: blue)
    }
}
