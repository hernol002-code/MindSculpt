import SwiftUI

// MARK: - Tutorial View (3-Slide Onboarding)
struct TutorialView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip / Begin Button (Top Right)
                HStack {
                    Spacer()

                    Button(action: { skipOrBegin() }) {
                        Text(currentPage == 2 ? "Begin Journey" : "Skip")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.lavenderMist)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)

                // TabView with 3 Slides
                TabView(selection: $currentPage) {
                    // SLIDE 1: Expression
                    TutorialSlide(
                        icon: "bubble.left.and.exclamationmark.bubble.right.fill",
                        iconColor: .ventralTeal,
                        title: "Express Yourself",
                        description: "Type how you truly feel. Our AI will analyze your emotional state to guide your journey."
                    )
                    .tag(0)

                    // SLIDE 2: Scanning
                    TutorialSlide(
                        icon: "camera.viewfinder",
                        iconColor: .mutedSunshine,
                        title: "Find Your Energy",
                        description: "You will be asked to scan colors in your physical environment to ground your senses."
                    )
                    .tag(1)

                    // SLIDE 3: Sanctuary
                    TutorialSlide(
                        icon: "tree.fill",
                        iconColor: .softCoral,
                        title: "Build Your Sanctuary",
                        description: "Each memory and color you find helps your digital garden grow. Find your peace."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .onAppear {
            audioManager.speak("Welcome. Let me show you how this works.")
        }
        .onChange(of: currentPage) { newPage in
            // Play selection haptic when swiping between pages
            HapticManager.shared.playSelection()
        }
    }

    // MARK: - Skip or Begin
    private func skipOrBegin() {
        HapticManager.shared.playImpact(style: .medium)
        audioManager.playTransition()

        if currentPage == 2 {
            audioManager.speak("Let's begin your journey")
        }

        // Navigate to input phase
        withAnimation(.easeInOut(duration: 0.6)) {
            engine.currentPhase = .input
        }
    }
}

// MARK: - Tutorial Slide Component
struct TutorialSlide: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Large Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.4),
                                iconColor.opacity(0.1),
                                iconColor.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 15)

                Image(systemName: icon)
                    .font(.system(size: 80, weight: .semibold))
                    .foregroundColor(iconColor)
                    .shadow(color: iconColor.opacity(0.6), radius: 20)
            }

            // Title
            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.lavenderMist)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.5), radius: 10)
                .padding(.horizontal, 40)

            // Description
            Text(description)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.lavenderMist.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 50)

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
}

// MARK: - Preview
struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(engine: GameEngine())
    }
}
