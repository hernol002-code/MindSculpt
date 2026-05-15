import SwiftUI

// MARK: - Breathing Sync View (Coherence Breathing)
struct BreathingSyncView: View {
    @Environment(\.dismiss) private var dismiss

    // FIX BP-01: AudioManager.shared is a pre-existing singleton — this view
    // does not create or own it. @StateObject would give SwiftUI false ownership
    // semantics. @ObservedObject is the correct wrapper for injected/shared objects.
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var isHolding = false
    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var circleScale: CGFloat = 1.0
    @State private var timeRemaining: TimeInterval = 120
    @State private var timer: Timer?

    enum BreathingPhase {
        case inhale
        case hold
        case exhale

        var duration: TimeInterval {
            switch self {
            case .inhale: return 4.0
            case .hold:   return 7.0
            case .exhale: return 8.0
            }
        }

        var instruction: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold:   return "Hold"
            case .exhale: return "Breathe Out"
            }
        }

        var targetScale: CGFloat {
            switch self {
            case .inhale: return 1.5
            case .hold:   return 1.5
            case .exhale: return 1.0
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.deepSlate, Color.deepSlate.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                // Timer
                VStack(spacing: 10) {
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(.lavenderMist.opacity(0.7))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.lavenderMist.opacity(0.2))

                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.ventralTeal, Color.mutedSunshine],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(1 - (timeRemaining / 120)))
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Breathing Circle
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.mutedSunshine.opacity(0.4),
                                    Color.ventralTeal.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 20)
                        .scaleEffect(circleScale)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.96, blue: 0.62),
                                    Color.ventralTeal
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 3)
                        )
                        .shadow(color: Color.mutedSunshine.opacity(0.6), radius: 30)
                        .scaleEffect(circleScale)

                    if isHolding {
                        Text(breathingPhase.instruction)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Text("Hold to Continue")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isHolding { startBreathing() }
                        }
                        .onEnded { _ in
                            pauseBreathing()
                        }
                )

                Spacer()

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.point.down.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.lavenderMist)

                        Text("Hold your thumb on the circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.lavenderMist.opacity(0.8))
                    }

                    Text("4s In • 7s Hold • 8s Out")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.lavenderMist.opacity(0.6))
                }
                .padding(.bottom, 30)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()

                    Button(action: {
                        stopBreathing()
                        dismiss()
                    }) {
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
        }
        .onDisappear {
            stopBreathing()
        }
        .accessibilityLabel("Breathing sync exercise")
        .accessibilityHint("Hold your finger on the circle to follow the breathing rhythm")
    }

    // MARK: - Time String Formatter
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Start Breathing
    private func startBreathing() {
        isHolding = true

        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    stopBreathing()
                    audioManager.playSuccess()
                    audioManager.speak("Breathing exercise complete. Well done.")

                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        await MainActor.run { dismiss() }
                    }
                }
            }
        }

        animateBreathingCycle()
    }

    // MARK: - Pause / Stop Breathing
    private func pauseBreathing() {
        isHolding = false
        timer?.invalidate()
        timer = nil
    }

    private func stopBreathing() {
        isHolding = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Animate Breathing Cycle
    private func animateBreathingCycle() {
        guard isHolding else { return }

        // Inhale (4s)
        breathingPhase = .inhale
        withAnimation(.easeInOut(duration: breathingPhase.duration)) {
            circleScale = breathingPhase.targetScale
        }

        Task {
            try? await Task.sleep(nanoseconds: UInt64(breathingPhase.duration * 1_000_000_000))
            guard isHolding else { return }

            // Hold (7s)
            await MainActor.run { breathingPhase = .hold }
            try? await Task.sleep(nanoseconds: UInt64(breathingPhase.duration * 1_000_000_000))
            guard isHolding else { return }

            // Exhale (8s)
            await MainActor.run {
                breathingPhase = .exhale
                withAnimation(.easeInOut(duration: breathingPhase.duration)) {
                    circleScale = breathingPhase.targetScale
                }
            }
            try? await Task.sleep(nanoseconds: UInt64(breathingPhase.duration * 1_000_000_000))

            // Repeat cycle
            await MainActor.run { animateBreathingCycle() }
        }
    }
}

// MARK: - Preview
struct BreathingSyncView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingSyncView()
    }
}
