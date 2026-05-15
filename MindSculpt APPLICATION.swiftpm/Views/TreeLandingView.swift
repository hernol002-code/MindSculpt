import SwiftUI
import SceneKit
import SwiftData

// MARK: - Tree Landing View (Sanctuary) - ENHANCED UX
struct TreeLandingView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var audioManager = AudioManager.shared
    @Environment(\.modelContext) private var modelContext

    @State private var treeRotation:          Double = 0.0
    @State private var treeScale             = 1.0
    @State private var flowers:              [FlowerData]    = []
    @State private var gratitudes:           [GratitudeData] = []
    @State private var showGratitudeInput    = false
    @State private var gratitudeText         = ""
    @State private var showFinishConfirmation = false
    @State private var showFocusMenu         = false
    
    // ✨ NEW: Animated glow for Focus button
    @State private var focusButtonGlow       = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.84, green: 0.92, blue: 0.97),
                    Color.ventralTeal
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture { location in
                plantFlower(at: location)
            }
            .accessibilityLabel("Sanctuary. Tap anywhere to plant flowers")
            .accessibilityHint("Tap to plant a flower. Swipe to explore")

            // Tree
            VStack {
                Spacer()

                ZStack {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 200))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.7, blue: 0.4),
                                    Color(red: 0.35, green: 0.25, blue: 0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .white.opacity(0.5), radius: 20)
                        .rotationEffect(.degrees(treeRotation))
                        .scaleEffect(treeScale)
                        .accessibilityLabel("Tree swaying gently in the breeze")

                    ForEach(gratitudes) { gratitude in
                        GratitudeFruit(text: gratitude.text)
                            .position(gratitude.position)
                    }
                }
                .frame(height: 400)

                Spacer()
            }

            // Planted Flowers
            ForEach(flowers) { flower in
                Image(systemName: "flower.fill")
                    .font(.system(size: 30))
                    .foregroundColor(flower.color)
                    .position(flower.position)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityHidden(true)
            }

            // Companion Creature
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    SceneView(
                        scene: makeCompanionScene(),
                        options: [.autoenablesDefaultLighting, .allowsCameraControl]
                    )
                    .frame(width: 150, height: 150)
                    .padding(.trailing, 20)
                    .padding(.bottom, 130)
                    .accessibilityLabel("Your companion creature")
                }
            }

            // ✨ ENHANCED FOCUS BUTTON (Primary Focal Point)
            VStack {
                HStack {
                    Spacer()

                    Button(action: {
                        // Heavy impact for "physical weight"
                        HapticManager.shared.playImpact(style: .heavy)
                        audioManager.playSelection()
                        showFocusMenu = true
                    }) {
                        ZStack {
                            // Animated glow layer (breathing effect)
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.ventralTeal.opacity(0.6),
                                            Color.ventralTeal.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: focusButtonGlow ? 60 : 50
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .blur(radius: 15)
                                .scaleEffect(focusButtonGlow ? 1.15 : 1.0)

                            // Main button background
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.ventralTeal.opacity(0.4), radius: 20, x: 0, y: 8)

                            // Icon
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.ventralTeal)
                                .shadow(color: Color.ventralTeal.opacity(0.3), radius: 5)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                    .accessibilityLabel("Focus and Grounding Exercises")
                    .accessibilityHint("Double tap to open sensory games menu")
                }

                Spacer()
            }

            // ✨ UPDATED BOTTOM BUTTONS (New icons, integrated haptics)
            VStack {
                Spacer()

                HStack(spacing: 15) {
                    // Add Gratitude (new icon: heart.text.square.fill)
                    Button(action: {
                        HapticManager.shared.playSelection()
                        audioManager.playSelection()
                        showGratitudeInput = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Add Gratitude")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.deepSlate, Color.ventralTeal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.ventralTeal.opacity(0.5), radius: 15)
                    }
                    .accessibilityLabel("Add Gratitude")
                    .accessibilityHint("Double tap to add something you're grateful for")

                    // Rest (new icon: house.and.flag.fill)
                    Button(action: {
                        HapticManager.shared.playSelection()
                        audioManager.playSelection()
                        showFinishConfirmation = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.and.flag.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Rest")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.mutedSunshine, Color.softCoral],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.mutedSunshine.opacity(0.5), radius: 15)
                    }
                    .accessibilityLabel("Finish Journey and Rest")
                    .accessibilityHint("Double tap to save this memory and return home")
                }
                .padding(.bottom, 50)
            }
        }
        // Gratitude input alert
        .alert("Add Gratitude", isPresented: $showGratitudeInput) {
            TextField("What are you grateful for?", text: $gratitudeText)
            Button("Cancel", role: .cancel) { }
            Button("Add") { addGratitude() }
        }
        // Finish confirmation alert
        .alert("Save This Memory?", isPresented: $showFinishConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Save & Rest") { finishJourney() }
        } message: {
            Text("Your companion will rest in the Memory Garden")
        }
        // Focus Menu Sheet
        .sheet(isPresented: $showFocusMenu) {
            FocusMenuView()
        }
        .onAppear {
            startAnimations()
            audioManager.startHappyAmbience()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                audioManager.speak("Your roots are strong. Breathe and observe.")
            }
        }
        .onDisappear {
            audioManager.stopAmbience()
        }
    }

    // MARK: - Companion Scene
    private func makeCompanionScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let creature = CreatureNode()
        creature.updateColor(engine.companionColor)
        creature.scale    = SCNVector3(0.5, 0.5, 0.5)
        creature.position = SCNVector3(0, -0.5, 0)

        scene.rootNode.addChildNode(creature)
        return scene
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            treeRotation = 3.0
        }
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            treeScale = 1.05
        }
        
        // ✨ NEW: Focus button breathing glow animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            focusButtonGlow = true
        }
    }

    // MARK: - Plant Flower (with haptic feedback)
    private func plantFlower(at location: CGPoint) {
        let randomColor = [
            Color.mutedSunshine, Color.softCoral, Color.lavenderMist,
            Color.ventralTeal,
            Color(red: 1.0, green: 0.75, blue: 0.8),
            Color(red: 0.8, green: 0.6, blue: 0.9)
        ].randomElement() ?? .mutedSunshine

        let flower = FlowerData(position: location, color: randomColor)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            flowers.append(flower)
        }

        // ✨ NEW: Haptic feedback for planting
        HapticManager.shared.playSelection()
        audioManager.playSelection()
    }

    // MARK: - Add Gratitude
    private func addGratitude() {
        guard !gratitudeText.isEmpty else { return }

        let position = CGPoint(
            x: CGFloat.random(in: 50...350),
            y: CGFloat.random(in: 100...300)
        )
        let gratitude = GratitudeData(text: gratitudeText, position: position)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            gratitudes.append(gratitude)
        }

        HapticManager.shared.playNotification(type: .success)
        audioManager.playSuccess()
        audioManager.speak("Gratitude added: \(gratitudeText)")

        gratitudeText = ""
    }

    // MARK: - Finish Journey (Save Memory)
    private func finishJourney() {
        let allGratitudes  = gratitudes.map { $0.text }.joined(separator: ", ")
        let finalGratitude = allGratitudes.isEmpty ? "A peaceful moment" : allGratitudes
        let colorHex       = engine.companionColor.toHex()

        let memory = CreatureMemory(colorHex: colorHex, gratitudeText: finalGratitude)
        modelContext.insert(memory)

        UserDefaults.standard.set(true, forKey: "hasRelaxedCreature")

        audioManager.playSuccess()
        audioManager.speak("Memory saved. Sweet dreams.")
        HapticManager.shared.playNotification(type: .success)

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.8)) {
                engine.resetGame()
            }
        }
    }
}

// MARK: - Flower Data Model
struct FlowerData: Identifiable {
    let id       = UUID()
    let position: CGPoint
    let color:    Color
}

// MARK: - Gratitude Data Model
struct GratitudeData: Identifiable {
    let id       = UUID()
    let text:     String
    let position: CGPoint
}

// MARK: - Gratitude Fruit View
struct GratitudeFruit: View {
    let text: String
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.mutedSunshine.opacity(0.8),
                            Color.mutedSunshine.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .blur(radius: 5)
                .scaleEffect(pulse ? 1.2 : 1.0)

            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 30, height: 30)

            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.mutedSunshine)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .onTapGesture {
            print("💡 Gratitude: \(text)")
        }
    }
}

// MARK: - Preview
struct TreeLandingView_Previews: PreviewProvider {
    static var previews: some View {
        TreeLandingView(engine: GameEngine())
            .modelContainer(for: CreatureMemory.self, inMemory: true)
    }
}
