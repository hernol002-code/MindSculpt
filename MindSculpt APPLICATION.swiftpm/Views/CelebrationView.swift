import SwiftUI

// MARK: - Celebration View (Positive Path)
//
// NOTE DC-02 / BUG-07: This view is currently unreachable at runtime because
// GameEngine.startJourney() never sets currentPhase = .celebration.
// The view itself is valid Swift. It will become reachable once BUG-07
// is addressed in GameEngine.swift.
//
struct CelebrationView: View {
    @ObservedObject var engine: GameEngine

    @State private var particleScale = 0.0
    @State private var textOpacity = 0.0
    @State private var buttonScale = 0.8

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)

                // Title
                VStack(spacing: 20) {
                    Text("✨")
                        .font(.system(size: 80))
                        .scaleEffect(particleScale)

                    Text("Your Energy is Radiant")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.deepSlate)
                        .shadow(color: .white.opacity(0.5), radius: 15)
                        .multilineTextAlignment(.center)

                    Text("Keep blooming")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.deepSlate.opacity(0.8))
                        .shadow(color: .white.opacity(0.3), radius: 8)
                }
                .padding(.horizontal, 40)
                .opacity(textOpacity)

                Spacer()

                FlowerParticleView()
                    .frame(height: 300)
                    .scaleEffect(particleScale)

                Spacer()

                // Continue to Color Selection
                VStack(spacing: 15) {
                    Text("Want to explore calming colors?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.deepSlate.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Button(action: {
                        HapticManager.shared.playImpact(style: .medium)
                        withAnimation {
                            engine.currentPhase = .colorSelection
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 22, weight: .semibold))

                            Text("Explore Colors")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.mutedSunshine,
                                            Color.ventralTeal
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.mutedSunshine.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .scaleEffect(buttonScale)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear { startAnimations() }
    }

    // MARK: - Entrance Animations
    private func startAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            particleScale = 1.0
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            textOpacity = 1.0
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.0)) {
            buttonScale = 1.0
        }

        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            HapticManager.shared.playNotification(type: .success)
        }
    }
}

// MARK: - Flower Particle View
struct FlowerParticleView: View {
    @State private var particles: [ParticleData] = []

    struct ParticleData: Identifiable {
        let id = UUID()
        var offset: CGSize
        var opacity: Double
        var scale: CGFloat
        var rotation: Double
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "sparkle")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mutedSunshine, .lavenderMist, .ventralTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(particle.offset)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .onAppear { startParticles() }
    }

    private func startParticles() {
        for i in 0..<12 {
            let angle  = Double(i) * (.pi * 2 / 12)
            let radius: CGFloat = 100

            let particle = ParticleData(
                offset: CGSize(
                    width:  cos(angle) * radius,
                    height: sin(angle) * radius
                ),
                opacity:  0.8,
                scale:    1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
            animateParticle(at: i)
        }
    }

    private func animateParticle(at index: Int) {
        let angle = Double(index) * (.pi * 2 / 12)

        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.1)
        ) {
            particles[index].offset  = CGSize(width: cos(angle) * 150, height: sin(angle) * 150)
            particles[index].opacity = 0.3
            particles[index].scale   = 1.5
        }

        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            particles[index].rotation += 360
        }
    }
}

// MARK: - Preview
struct CelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        CelebrationView(engine: GameEngine())
    }
}
