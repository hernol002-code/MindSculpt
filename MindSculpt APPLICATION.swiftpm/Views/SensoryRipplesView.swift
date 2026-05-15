import SwiftUI

// MARK: - Sensory Ripples View (Stimming Toy)
struct SensoryRipplesView: View {
    @Environment(\.dismiss) private var dismiss

    // FIX BP-01: AudioManager.shared is a pre-existing singleton — this view
    // does not create or own it. @ObservedObject is the correct wrapper.
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var ripples: [Ripple] = []
    @State private var lastSoundTime: Date = .distantPast

    var body: some View {
        ZStack {
            // Canvas
            Color.deepSlate
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            spawnRipple(at: value.location)
                        }
                )

            // Ripples
            ForEach(ripples) { ripple in
                RippleCircle(ripple: ripple)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)

                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.lavenderMist)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                }

                Spacer()
            }

            // Instructions
            VStack {
                Spacer()

                Text("Tap or drag to create ripples")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.lavenderMist.opacity(0.6))
                    .padding(.bottom, 50)
            }
        }
        .accessibilityLabel("Sensory Ripples canvas")
        .accessibilityHint("Tap or drag anywhere to create soothing visual ripples")
    }

    // MARK: - Spawn Ripple
    private func spawnRipple(at location: CGPoint) {
        let ripple = Ripple(
            position: location,
            color: Bool.random() ? .ventralTeal : .lavenderMist
        )

        withAnimation(.easeOut(duration: 2.0)) {
            ripples.append(ripple)
        }

        // Throttle audio (max 1 sound per 0.1 seconds)
        let now = Date()
        if now.timeIntervalSince(lastSoundTime) > 0.1 {
            audioManager.playSelection()
            lastSoundTime = now
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                ripples.removeAll { $0.id == ripple.id }
            }
        }
    }
}

// MARK: - Ripple Model
struct Ripple: Identifiable {
    let id       = UUID()
    let position: CGPoint
    let color:    Color
}

// MARK: - Ripple Circle Component
struct RippleCircle: View {
    let ripple: Ripple

    @State private var scale:   CGFloat = 0.1
    @State private var opacity: Double  = 0.8

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        ripple.color.opacity(0.6),
                        ripple.color.opacity(0.2),
                        ripple.color.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(ripple.position)
            .blur(radius: 10)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    scale   = 3.0
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Preview
struct SensoryRipplesView_Previews: PreviewProvider {
    static var previews: some View {
        SensoryRipplesView()
    }
}
