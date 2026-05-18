import SwiftUI

// MARK: - Emotional Insight View (Validación Emocional)
// Aparece después del análisis de IA, antes de la jaula o árbol
struct EmotionalInsightView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var messageOpacity = 0.0
    @State private var iconScale = 0.5
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Emotional Icon
                ZStack {
                    // Animated glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    emotionalColor.opacity(0.6),
                                    emotionalColor.opacity(0.2),
                                    emotionalColor.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: glowPulse ? 120 : 100
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                        .scaleEffect(glowPulse ? 1.15 : 1.0)

                    // Main icon
                    Image(systemName: emotionalIcon)
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundColor(emotionalColor)
                        .shadow(color: emotionalColor.opacity(0.7), radius: 25)
                        .scaleEffect(iconScale)
                }
                .padding(.top, 40)

                // Emotional Message
                VStack(spacing: 20) {
                    Text(emotionalTitle)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.lavenderMist)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 10)

                    Text(emotionalMessage)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.lavenderMist.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .opacity(messageOpacity)

                Spacer()

                // Continue prompt
                HStack(spacing: 8) {
                    Text("Tap to continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.lavenderMist.opacity(0.6))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.lavenderMist.opacity(0.6))
                }
                .opacity(messageOpacity)
                .padding(.bottom, 50)
            }
        }
        .onTapGesture {
            continueJourney()
        }
        .onAppear {
            startAnimations()
            speakMessage()
            
            // Auto-continue después de 4 segundos
            Task {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                continueJourney()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(emotionalTitle). \(emotionalMessage). Tap to continue")
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            iconScale = 1.0
        }
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            messageOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            glowPulse = true
        }
    }

    private func speakMessage() {
        audioManager.speak(emotionalMessage)
    }

    private func continueJourney() {
        HapticManager.shared.playImpact(style: .medium)
        audioManager.playTransition()
        
        // Continuar al destino correcto basado en el score
        withAnimation(.easeInOut(duration: 0.8)) {
            if engine.sentimentScore > 0.15 {
                engine.currentPhase = .treeLanding
            } else {
                engine.currentPhase = .cocoonBreak
            }
        }
    }

    // MARK: - Emotional Content (basado en detectedEmotion)

    private var emotionalIcon: String {
        switch engine.detectedEmotion {
        case "joy":
            return "sun.max.fill"
        case "sadness":
            return "cloud.rain.fill"
        case "anger":
            return "flame.fill"
        default: // neutral, stress, anxiety
            return "wind"
        }
    }

    private var emotionalColor: Color {
        switch engine.detectedEmotion {
        case "joy":
            return .mutedSunshine
        case "sadness":
            return .ventralTeal
        case "anger":
            return .softCoral
        default:
            return .lavenderMist
        }
    }

    private var emotionalTitle: String {
        switch engine.detectedEmotion {
        case "joy":
            return "I See Your Joy"
        case "sadness":
            return "I Hear Your Sadness"
        case "anger":
            return "I Feel Your Anger"
        default:
            return "I Sense Your Stress"
        }
    }

    private var emotionalMessage: String {
        switch engine.detectedEmotion {
        case "joy":
            return "Joy is your spirit celebrating life. This positive energy is powerful and real. Let's capture and grow this feeling in your sanctuary."
            
        case "sadness":
            return "Sadness is a natural response to loss and disappointment. It's your mind's way of processing what matters to you. Let's work through this together."
            
        case "anger":
            return "Anger is energy that wants to protect your boundaries. It's telling you something important. Let's channel this feeling constructively."
            
        default: // neutral, stress, anxiety
            return "Stress is your body's alarm system responding to pressure. You're not alone in this feeling. Let's find your calm together."
        }
    }
}

// MARK: - Preview
struct EmotionalInsightView_Previews: PreviewProvider {
    static var previews: some View {
        let engine = GameEngine()
        engine.detectedEmotion = "sadness"
        return EmotionalInsightView(engine: engine)
    }
}
