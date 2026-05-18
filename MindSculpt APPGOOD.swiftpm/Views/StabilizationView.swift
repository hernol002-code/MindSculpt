import SwiftUI
import CoreHaptics

// MARK: - Stabilization View
struct StabilizationView: View {
    @ObservedObject var engine: GameEngine

    @State private var isTouching      = false
    @State private var hapticsEngine:  CHHapticEngine?
    @State private var timer:          Timer?
    @State private var breathingScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Calm Your Emotion")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.lavenderMist)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .padding(.top, 50)

                // Calmness bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.ventralTeal)

                        Text("Calmness Level")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.lavenderMist)
                            .shadow(color: .black.opacity(0.5), radius: 5)

                        Spacer()

                        Text("\(Int(engine.calmnessLevel))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.ventralTeal)
                            .shadow(color: .black.opacity(0.5), radius: 5)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))

                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.lavenderMist,
                                            Color.ventralTeal
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * (engine.calmnessLevel / 100))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 30)
                .opacity(isTouching ? 1 : 0.6)

                Spacer()

                // Blob
                FreeBlobView(
                    calmnessProgress: engine.calmnessLevel / 100,
                    isTouching:       isTouching,
                    breathingScale:   breathingScale,
                    creatureColor:    engine.creatureColor
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in if !isTouching { startCalming() } }
                        .onEnded   { _ in stopCalming() }
                )

                Spacer()

                // Instruction panel
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Image(systemName: isTouching ? "hand.point.down.fill" : "hand.tap.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.ventralTeal)

                        Text(isTouching ? "Keep holding..." : "Touch and hold")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.lavenderMist)
                            .shadow(color: .black.opacity(0.5), radius: 5)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.ventralTeal.opacity(0.5), lineWidth: 2)
                    )

                    if isTouching {
                        Text("Sync your breathing")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.lavenderMist.opacity(0.7))
                            .shadow(color: .black.opacity(0.5), radius: 5)
                            .transition(.opacity)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            prepareHaptics()
            startBreathingAnimation()
        }
        .onDisappear {
            stopCalming()
            hapticsEngine?.stop()
        }
    }

    // MARK: - Calming Control
    func startCalming() {
        isTouching = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            engine.increaseCalm()
            playHeartbeat()
        }
    }

    func stopCalming() {
        isTouching = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Breathing Animation
    func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.15
        }
    }

    // MARK: - Haptics Setup
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticsEngine = try CHHapticEngine()
            try hapticsEngine?.start()
            hapticsEngine?.resetHandler = {
                Task { @MainActor in try? self.hapticsEngine?.start() }
            }
        } catch {}
    }

    func playHeartbeat() {
        guard let engine = hapticsEngine else { return }

        let calmnessProgress = self.engine.calmnessLevel / 100
        let intensityVal     = Float(1.0 - (calmnessProgress * 0.7))
        let sharpnessVal     = Float(1.0 - (calmnessProgress * 0.8))

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityVal)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessVal)

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
    }
}

// MARK: - Free Blob Component
struct FreeBlobView: View {
    let calmnessProgress: Double
    let isTouching:       Bool
    let breathingScale:   CGFloat
    let creatureColor:    Color

    var shakeAmount: Double {
        isTouching ? 0 : (1.0 - calmnessProgress) * 8.0
    }

    var body: some View {
        ZStack {
            // Rings
            ForEach(0..<3) { index in
                let size:    CGFloat = 200 + (CGFloat(index) * 30)
                let opacity: Double  = 0.3 - (Double(index) * 0.1)
                let scale:   CGFloat = breathingScale + (CGFloat(index) * 0.1)

                Circle()
                    .stroke(Color.ventralTeal.opacity(opacity), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(scale)
            }

            // Body
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                creatureColor.opacity(0.9),
                                creatureColor.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                // Eyes
                HStack(spacing: 40) {
                    ZStack {
                        Circle().fill(.white).frame(width: 40, height: 40)
                        Circle().fill(.black).frame(width: 15, height: 15)
                            .offset(y: isTouching ? 0 : 3)
                    }
                    ZStack {
                        Circle().fill(.white).frame(width: 40, height: 40)
                        Circle().fill(.black).frame(width: 15, height: 15)
                            .offset(y: isTouching ? 0 : 3)
                    }
                }
                .offset(y: -20)

                // Smile (appears at 50 %+ calmness)
                if calmnessProgress > 0.5 {
                    Path { path in
                        path.move(to: CGPoint(x: 60, y: 30))
                        path.addQuadCurve(
                            to:      CGPoint(x: 140, y: 30),
                            control: CGPoint(x: 100, y: 45)
                        )
                    }
                    .stroke(Color.white, lineWidth: 3)
                    .opacity((calmnessProgress - 0.5) * 2)
                }
            }
            .modifier(ShakeEffect(shakeAmount: shakeAmount))
            .scaleEffect(isTouching ? 0.95 : 1.0)
            .shadow(color: creatureColor.opacity(0.5), radius: 20)
        }
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: ViewModifier {
    let shakeAmount: Double

    @State private var offset: CGSize = .zero
    @State private var timer:  Timer?

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .onAppear  { startShaking() }
            .onChange(of: shakeAmount) { _ in startShaking() }
            .onDisappear { stopShaking() }
    }

    func startShaking() {
        stopShaking()
        guard shakeAmount > 0.1 else { offset = .zero; return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if shakeAmount > 0.1 {
                offset = CGSize(
                    width:  CGFloat.random(in: -shakeAmount...shakeAmount),
                    height: CGFloat.random(in: -shakeAmount...shakeAmount)
                )
            } else {
                offset = .zero
                stopShaking()
            }
        }
    }

    func stopShaking() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview
struct StabilizationView_Previews: PreviewProvider {
    static var previews: some View {
        StabilizationView(engine: GameEngine())
    }
}
