import SwiftUI
import NaturalLanguage

// MARK: - Sentiment Analyzer
@MainActor //
class SentimentAnalyzer: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Double = 0.0
    @Published var isAnalyzing: Bool = false
    @Published var stressLevel: Double = 0.5 // 0.0 = calm, 1.0 = maximum stress
    
    // MARK: - Main Analysis Function
    func analyze(_ text: String) {
        guard !text.isEmpty else {
            self.score = 0.0
            self.stressLevel = 0.5
            return
        }
        
        self.isAnalyzing = true
        
        // Execute in background to avoid freezing UI
        DispatchQueue.global(qos: .userInitiated).async {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            
            // Analyze complete paragraph
            let (sentiment, _) = tagger.tag(
                at: text.startIndex,
                unit: .paragraph,
                scheme: .sentimentScore
            )
            
            // Return to main thread to update UI
            DispatchQueue.main.async {
                self.isAnalyzing = false
                
                if let scoreStr = sentiment?.rawValue,
                   let scoreDouble = Double(scoreStr) {
                    self.score = scoreDouble
                    self.stressLevel = self.calculateStressLevel(from: scoreDouble)
                    
                    print("🧠 AI Score: \(scoreDouble)")
                    print("😰 Stress Level: \(self.stressLevel)")
                } else {
                    self.score = 0.0 // Neutral by default
                    self.stressLevel = 0.5
                    print("😐 AI Score: Neutral or Error")
                }
            }
        }
    }
    
    // MARK: - Convert Sentiment to Stress Level
    private func calculateStressLevel(from sentimentScore: Double) -> Double {
        // sentimentScore ranges from -1 (very negative) to +1 (very positive)
        // Convert to stressLevel from 0 (calm) to 1 (maximum stress)
        
        // Very negative sentiment (-1) → high stress (0.9-1.0)
        // Neutral sentiment (0) → medium stress (0.5)
        // Very positive sentiment (+1) → low stress (0.1-0.2)
        
        let normalizedStress = (1.0 - sentimentScore) / 2.0
        
        // Clamp between 0.2 and 0.95 to always have some deformation
        return max(0.2, min(0.95, normalizedStress))
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
        let red = 0.3 + (stressLevel * 0.6) // From 0.3 to 0.9
        let green = 0.1 * (1.0 - stressLevel) // From 0.1 to 0.0
        let blue = 0.1 * (1.0 - stressLevel) // From 0.1 to 0.0
        
        return Color(red: red, green: green, blue: blue)
    }
}
