import SwiftUI

// MARK: - Main Content View (Router)
struct ContentView: View {
    @StateObject private var engine = GameEngine()

    var body: some View {
        ZStack {
            // DYNAMIC BACKGROUND (Lava Lamp)
            Group {
                switch engine.currentPhase {
                case .intro, .tutorial, .input, .emotionalInsight, .treeLanding, .celebration, .colorSelection:
                    // ✅ emotionalInsight usa calmPalette (transición suave desde input)
                    LavaLampBackground(palette: Color.calmPalette)
                        .ignoresSafeArea()

                case .cocoonBreak, .stabilization:
                    LavaLampBackground(palette: Color.regulationPalette)
                        .ignoresSafeArea()

                case .scanning:
                    Color.black
                        .ignoresSafeArea()
                }
            }
            .animation(.easeInOut(duration: 1.0), value: engine.currentPhase)

            // PHASE ROUTER
            Group {
                switch engine.currentPhase {
                case .intro:
                    IntroView(engine: engine)
                        .transition(.opacity)

                case .tutorial:
                    TutorialView(engine: engine)
                        .transition(.opacity)

                case .input:
                    InputView(engine: engine)
                        .transition(.opacity)

                case .emotionalInsight:
                    // ✅ NEW: Validación emocional con mensaje contextual
                    EmotionalInsightView(engine: engine)
                        .transition(.opacity)

                case .treeLanding:
                    TreeLandingView(engine: engine)
                        .transition(.opacity)

                case .cocoonBreak:
                    CocoonBreakView(engine: engine)
                        .transition(.opacity)

                case .stabilization:
                    StabilizationView(engine: engine)
                        .transition(.opacity)

                case .celebration:
                    CelebrationView(engine: engine)
                        .transition(.opacity)

                case .colorSelection:
                    ColorSelectionView(engine: engine)
                        .transition(.opacity)

                case .scanning:
                    CameraScannerView(engine: engine)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: engine.currentPhase)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
