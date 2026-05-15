import Foundation
import SwiftUI
import Combine
import NaturalLanguage

// MARK: - App Phase Enum
enum AppPhase: Equatable {
    case intro
    case tutorial
    case input
    case emotionalInsight // ✅ NEW: Validación emocional antes de jaula/árbol
    case treeLanding      // Sanctuary (DESTINO POSITIVO)
    case cocoonBreak      // Jaula (DESTINO NEGATIVO)
    case stabilization
    case celebration
    case colorSelection
    case scanning
}

// MARK: - Game Engine
@MainActor
class GameEngine: ObservableObject {

    // MARK: - Published States
    @Published var currentPhase:    AppPhase = .intro
    @Published var cocoonIntegrity: Double   = 100.0
    @Published var calmnessLevel:   Double   = 0.0
    @Published var userText:        String   = ""
    @Published var targetColor:     Color?   = nil
    @Published var selectedColor:   Color?   = nil
    @Published var detectedEmotion: String   = "neutral"
    @Published var creatureColor:   Color    = .lavenderMist
    @Published var sentimentScore:  Double   = 0.0
    @Published var companionColor:  Color    = Color(red: 1.0, green: 0.96, blue: 0.62)

    @Published var sentimentAnalyzer = SentimentAnalyzer()

    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupObservers()
    }

    // MARK: - Observers
    private func setupObservers() {
        // Forward sentimentAnalyzer changes to trigger SwiftUI updates
        sentimentAnalyzer.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        // Cocoon integrity → stabilization
        $cocoonIntegrity
            .removeDuplicates()
            .sink { [weak self] integrity in
                guard let self,
                      integrity <= 0,
                      self.currentPhase == .cocoonBreak else { return }
                print("🎯 Cage broken → stabilization")
                withAnimation(.easeInOut(duration: 0.8)) {
                    self.currentPhase = .stabilization
                }
            }
            .store(in: &cancellables)

        // Calmness → color selection
        $calmnessLevel
            .removeDuplicates()
            .sink { [weak self] calmness in
                guard let self,
                      calmness >= 100,
                      self.currentPhase == .stabilization else { return }
                print("🎯 Fully calm → color selection")
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.currentPhase = .colorSelection
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - App Start
    func startApp() {
        print("🚀 Starting MindSculpt...")
        withAnimation(.easeInOut(duration: 0.6)) {
            self.currentPhase = .tutorial
        }
    }

    // MARK: - Sentiment Analysis & Routing
    // ✅ UPDATED: Ahora va primero a .emotionalInsight antes de árbol/jaula
    func startJourney() {
        print("🚀 Starting emotional journey...")

        detectedEmotion = detectEmotion(from: userText)
        creatureColor   = Color.emotionColor(for: detectedEmotion)

        print("🧠 Detected emotion: \(detectedEmotion)")

        Task {
            await sentimentAnalyzer.analyze(userText)

            self.sentimentScore = self.sentimentAnalyzer.score

            print("📊 Sentiment score: \(self.sentimentScore)")

            // ✅ NEW: Ir primero a validación emocional
            // La vista EmotionalInsightView mostrará el mensaje contextual
            // y luego redirigirá al destino correcto (árbol o jaula)
            withAnimation(.easeInOut(duration: 0.6)) {
                self.currentPhase = .emotionalInsight
            }

            // Log del destino final (para debug)
            if self.sentimentScore > 0.15 {
                print("🌳 Final destination: treeLanding (after insight)")
            } else {
                print("😰 Final destination: cocoonBreak (after insight)")
            }
        }
    }

    // MARK: - Game Actions
    func hitCocoon() {
        guard currentPhase == .cocoonBreak, cocoonIntegrity > 0 else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            self.cocoonIntegrity = max(0, self.cocoonIntegrity - 10)
        }
        print("💥 Hit! Integrity: \(self.cocoonIntegrity)%")
    }

    func increaseCalm(amount: Double = 1.2) {
        guard currentPhase == .stabilization, calmnessLevel < 100 else { return }
        withAnimation(.linear(duration: 0.1)) {
            self.calmnessLevel = min(100, self.calmnessLevel + amount)
        }
    }

    func selectTargetColor(_ color: Color) {
        print("🎯 Target color selected")
        self.targetColor   = color
        self.selectedColor = color
        withAnimation(.easeInOut(duration: 0.6)) {
            self.currentPhase = .scanning
        }
    }

    // MARK: - Bridge to Sanctuary
    func completeColorJourney() {
        print("🌈 Color journey complete → sanctuary")
        if let selected = selectedColor {
            companionColor = selected
        }
        withAnimation(.easeInOut(duration: 0.8)) {
            self.currentPhase = .treeLanding
        }
    }

    func skipCamera() {
        print("⏭️ Camera skipped")
        completeScanning()
    }

    // MARK: - Reset
    func resetGame() {
        withAnimation(.easeInOut(duration: 0.6)) {
            self.currentPhase    = .intro
            self.cocoonIntegrity = 100
            self.calmnessLevel   = 0
            self.userText        = ""
            self.targetColor     = nil
            self.selectedColor   = nil
            self.detectedEmotion = "neutral"
            self.creatureColor   = .lavenderMist
            self.sentimentScore  = 0.0
            self.companionColor  = Color(red: 1.0, green: 0.96, blue: 0.62)
        }
    }

    func completeScanning() {
        print("✅ Mission complete → restarting")
        resetGame()
    }

    // MARK: - Keyword-based Emotion Detection
    private func detectEmotion(from text: String) -> String {
        let l = text.lowercased()

        if l.contains("happy")   || l.contains("joy")       ||
           l.contains("excited") || l.contains("great")     ||
           l.contains("amazing") || l.contains("wonderful") ||
           l.contains("love")    || l.contains("good") {
            return "joy"
        }

        if l.contains("sad")       || l.contains("down")    ||
           l.contains("depressed") || l.contains("lonely")  ||
           l.contains("tired")     || l.contains("blue")    ||
           l.contains("awful")     || l.contains("terrible") {
            return "sadness"
        }

        if l.contains("angry")       || l.contains("mad")      ||
           l.contains("frustrated")  || l.contains("annoyed")  ||
           l.contains("upset")       || l.contains("stress")   ||
           l.contains("hate")        || l.contains("furious") {
            return "anger"
        }

        return "neutral"
    }
}
