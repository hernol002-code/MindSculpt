import SwiftUI

// MARK: - Intro View (Cleaned Up - No Sparkles)
struct IntroView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var textOpacity    = 0.0
    @State private var creditsOpacity = 0.0
    @State private var buttonScale    = 0.8
    @State private var avatarPulse    = false
    @State private var showMemoryGarden = false

    var body: some View {
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                // Welcoming Avatar
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.softCoral.opacity(0.4),
                                    Color.softCoral.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(avatarPulse ? 1.2 : 1.0)

                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.softCoral)
                        .shadow(color: .softCoral.opacity(0.6), radius: 20)
                        .scaleEffect(avatarPulse ? 1.1 : 1.0)
                        .accessibilityLabel("Welcoming face")
                }
                .padding(.top, 40)

                // Main Quote
                VStack(spacing: 20) {
                    Text("For those who feel everything")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.lavenderMist)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 10)

                    Text("but can't always find the words")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.lavenderMist.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .padding(.horizontal, 40)
                .opacity(textOpacity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("For those who feel everything but can't always find the words")

                Spacer()

                // Credits
                VStack(spacing: 12) {
                    Text("Based on")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.lavenderMist.opacity(0.7))

                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16))
                            Text("Affective Computing (Dr. Picard)")
                                .font(.system(size: 15, weight: .semibold))
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 16))
                            Text("Polyvagal Theory")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.lavenderMist.opacity(0.8))
                }
                .opacity(creditsOpacity)
                .padding(.bottom, 30)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Based on Affective Computing by Doctor Picard and Polyvagal Theory")

                // ✨ CLEANED: Simple "Start" button (no sparkles)
                Button(action: { startApp() }) {
                    Text("Start")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.buttonGradient)
                        )
                        .shadow(color: Color.ventralTeal.opacity(0.6), radius: 25, x: 0, y: 12)
                }
                .scaleEffect(buttonScale)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .accessibilityLabel("Start")
                .accessibilityHint("Double tap to begin your journey")
            }

            // Top bar: Memory Garden (left) + Narration Toggle (right)
            VStack {
                HStack {
                    // Memory Garden Button
                    Button(action: { showMemoryGarden = true }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .shadow(color: .black.opacity(0.2), radius: 8)

                            Image(systemName: "sparkles")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.mutedSunshine)
                        }
                    }
                    .padding(.leading, 20)
                    .accessibilityLabel("Memory Garden")
                    .accessibilityHint("Double tap to view your saved peaceful moments")

                    Spacer()

                    // Narration Toggle
                    NarrationToggleButton(audioManager: audioManager)
                        .padding(.trailing, 20)
                }
                .padding(.top, 50)

                Spacer()
            }
        }
        .sheet(isPresented: $showMemoryGarden) {
            MemoryGardenView()
        }
        .onAppear {
            startAnimations()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                audioManager.speak("For those who feel everything but can't always find the words")
            }
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            avatarPulse = true
        }
        withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
            textOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 1.2).delay(1.0)) {
            creditsOpacity = 1.0
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.5)) {
            buttonScale = 1.0
        }
    }

    private func startApp() {
        HapticManager.shared.playImpact(style: .medium)
        audioManager.playTransition()
        
        // ✅ UPDATED: Navigate to tutorial instead of input
        engine.startApp()
    }
}

// MARK: - Preview
struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(engine: GameEngine())
    }
}
