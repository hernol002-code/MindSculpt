import SwiftUI
import UIKit
import SceneKit
import CoreMotion
import CoreHaptics
import AVFoundation
// MARK: - Kawaii Slime Scene (Using CreatureNode)
class KawaiiSlimeScene: SCNScene {
    var creatureNode: CreatureNode!
    var cageNode: SCNNode!

    override init() {
        super.init()
        setupScene()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScene() {
        background.contents = UIColor.clear

        // Lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1.0)
        ambientLight.light?.intensity = 800
        rootNode.addChildNode(ambientLight)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .omni
        keyLight.light?.intensity = 1200
        keyLight.position = SCNVector3(x: 3, y: 5, z: 10)
        rootNode.addChildNode(keyLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.color = UIColor(white: 0.8, alpha: 1.0)
        fillLight.light?.intensity = 500
        fillLight.position = SCNVector3(x: -3, y: 3, z: 5)
        rootNode.addChildNode(fillLight)

        // Camera
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(x: 0, y: 1, z: 10)
        camera.camera?.fieldOfView = 40
        rootNode.addChildNode(camera)

        // Creature
        creatureNode = CreatureNode()
        creatureNode.position = SCNVector3(x: 0, y: 0, z: 0)
        rootNode.addChildNode(creatureNode)

        // Cage (Wireframe)
        let cageGeometry = SCNSphere(radius: 2.3)
        let cageMaterial = SCNMaterial()
        cageMaterial.diffuse.contents = UIColor(Color.lavenderMist)
        cageMaterial.transparency = 0.6
        cageMaterial.fillMode = .lines
        cageGeometry.materials = [cageMaterial]

        cageNode = SCNNode(geometry: cageGeometry)
        rootNode.addChildNode(cageNode)

        let rotate = SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 25)
        )
        cageNode.runAction(rotate)
    }

    func updateCreatureColor(_ color: Color) {
        creatureNode?.updateColor(color)
    }

    func updateCageIntegrity(_ integrity: Double) {
        guard let cageNode = cageNode else { return }
        cageNode.opacity = CGFloat(integrity / 100.0)
    }

    func shakeCage() {
        guard let cageNode = cageNode else { return }
        let shake = SCNAction.sequence([
            SCNAction.moveBy(x: 0.15, y: 0, z: 0, duration: 0.05),
            SCNAction.moveBy(x: -0.3,  y: 0, z: 0, duration: 0.05),
            SCNAction.moveBy(x: 0.15,  y: 0, z: 0, duration: 0.05)
        ])
        cageNode.runAction(shake)
    }

    func breakCage(completion: @escaping () -> Void) {
        guard let cageNode = cageNode else {
            completion()
            return
        }
        cageNode.runAction(
            SCNAction.group([
                SCNAction.scale(to: 2.5, duration: 0.6),
                SCNAction.fadeOut(duration: 0.6)
            ])
        ) {
            cageNode.removeFromParentNode()
            completion()
        }
        creatureNode?.celebrate()
    }
}

// MARK: - SceneView Wrapper
struct KawaiiSlimeSceneView: UIViewRepresentable {
    @Binding var cageIntegrity: Double
    @Binding var shouldShake: Bool
    @Binding var creatureColor: Color
    var onTap: () -> Void

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        view.antialiasingMode = .multisampling4X

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.tap)
        )
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.scene.updateCageIntegrity(cageIntegrity)
        context.coordinator.scene.updateCreatureColor(creatureColor)
        if shouldShake { context.coordinator.scene.shakeCage() }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject {
        let scene = KawaiiSlimeScene()
        let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func tap() { onTap() }
    }
}

// MARK: - Motion Manager
@MainActor
class MotionManager: ObservableObject {
    private var manager: CMMotionManager?
    var onShake: (() -> Void)?

    func start() {
        manager = CMMotionManager()
        guard let m = manager, m.isAccelerometerAvailable else { return }

        m.accelerometerUpdateInterval = 0.1
        m.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            let total = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            if total > 2.5 { self?.onShake?() }
        }
    }

    func stop() {
        manager?.stopAccelerometerUpdates()
        manager = nil
    }
}

// MARK: - CocoonBreakView - ENHANCED WITH HEARTBEAT HAPTICS
struct CocoonBreakView: View {
    @ObservedObject var engine: GameEngine

    @StateObject private var motion = MotionManager()
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var shouldShake = false

    var body: some View {
        ZStack {
            Color.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Trapped Emotion")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.lavenderMist)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .padding(.top, 60)
                    .accessibilityLabel("Trapped Emotion. Break the cage to free your feelings")

                // Progress bar
                VStack {
                    HStack {
                        Text("Cage Integrity: \(Int(engine.cocoonIntegrity))%")
                            .foregroundColor(.lavenderMist)
                            .font(.system(size: 18, weight: .semibold))
                            .shadow(color: .black.opacity(0.5), radius: 5)
                        Spacer()
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.deepSlate.opacity(0.3))

                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.ventralTeal, .lavenderMist],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * (engine.cocoonIntegrity / 100))
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Cage integrity at \(Int(engine.cocoonIntegrity)) percent")

                // 3D Scene
                KawaiiSlimeSceneView(
                    cageIntegrity: $engine.cocoonIntegrity,
                    shouldShake: $shouldShake,
                    creatureColor: $engine.creatureColor,
                    onTap: { hit() }
                )
                .frame(height: 400)
                .padding()
                .accessibilityLabel("Trapped creature in cage")
                .accessibilityHint("Tap or shake device to break the cage")

                Spacer()

                // Instructions
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.mutedSunshine)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tap the cage")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("to break it free")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.lavenderMist)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )

                    Text("Or shake your device")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.lavenderMist.opacity(0.7))
                }
                .padding(.bottom, 50)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tap the cage or shake your device to break it free")
            }
        }
        .onAppear {
            motion.start()
            motion.onShake = { hit() }
            audioManager.startSadAmbience()
            
            // ✨ NEW: Start distressed heartbeat (high stress at 100% integrity)
            startHeartbeat()
        }
        .onDisappear {
            motion.stop()
            audioManager.stopAmbience()
            
            // ✨ NEW: Stop heartbeat when leaving view
            HapticManager.shared.stopHeartbeat()
        }
        // ✨ NEW: Update heartbeat as cage breaks
        .onChange(of: engine.cocoonIntegrity) { newIntegrity in
            updateHeartbeat(integrity: newIntegrity)
        }
    }

    // MARK: - Hit Action
    private func hit() {
        guard engine.cocoonIntegrity > 0 else { return }

        engine.hitCocoon()
        shouldShake = true
        
        // Heavy impact for hitting cage
        HapticManager.shared.playImpact(style: .heavy)
        audioManager.playCageBreak()

        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            shouldShake = false
        }
    }

    // MARK: - 💓 Heartbeat Haptic System
    
    /// Starts the distressed heartbeat pattern
    /// At 100% integrity (start), heartbeat is fast and intense (stressed)
    private func startHeartbeat() {
        // Convert integrity to progress (100% integrity = 0% progress = max stress)
        let progress = 1.0 - (engine.cocoonIntegrity / 100.0)
        HapticManager.shared.startDistressedHeartbeat(progress: progress)
        print("💓 Heartbeat started | Integrity: \(Int(engine.cocoonIntegrity))% | Stress: \(String(format: "%.0f", (1.0 - progress) * 100))%")
    }
    
    /// Updates heartbeat intensity as cage integrity decreases
    /// Lower integrity = calmer heartbeat (physical sensation of success)
    private func updateHeartbeat(integrity: Double) {
        // Convert integrity to progress
        // 100% integrity → 0% progress → max stress (fast, intense heartbeat)
        // 0% integrity   → 100% progress → calm (slow, gentle heartbeat)
        let progress = 1.0 - (integrity / 100.0)
        
        HapticManager.shared.updateHeartbeatIntensity(progress: progress)
        print("💓 Heartbeat updated | Integrity: \(Int(integrity))% | Progress: \(String(format: "%.0f", progress * 100))%")
        
        // When cage is fully broken, stop heartbeat
        if integrity <= 0 {
            HapticManager.shared.stopHeartbeat()
            print("💓 Cage broken → Heartbeat stopped")
        }
    }
}

// MARK: - Preview
struct CocoonBreakView_Previews: PreviewProvider {
    static var previews: some View {
        CocoonBreakView(engine: GameEngine())
    }
}
