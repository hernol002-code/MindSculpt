import SwiftUI

struct ColorSelectionView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject private var audioManager = AudioManager.shared

    let colorOptions: [(color: Color, icon: String, name: String)] = [
        (.ventralTeal,                               "drop.fill",    "Calm"),
        (.lavenderMist,                              "cloud.fill",   "Peace"),
        (.mutedSunshine,                             "sun.max.fill", "Energy"),
        (.softCoral,                                 "heart.fill",   "Life"),
        (.deepSlate,                                 "moon.fill",    "Rest"),
        (Color(red: 0.52, green: 0.76, blue: 0.89), "wind",         "Flow"),
        (Color(red: 0.72, green: 0.88, blue: 0.82), "leaf.fill",    "Nature"),
        (Color(red: 0.96, green: 0.64, blue: 0.38), "flame.fill",   "Warmth")
    ]

    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            // FONDO
            Color.backgroundGradient.ignoresSafeArea()

            // CUADRÍCULA (Con scroll por si la pantalla es pequeña)
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 60)

                    Text("What Energy Do You Need?")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.lavenderMist)
                        .multilineTextAlignment(.center)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<colorOptions.count, id: \.self) { index in
                            ColorGridButton(
                                option: colorOptions[index],
                                isSelected: selectedIndex == index,
                                isDimmed: selectedIndex != nil && selectedIndex != index,
                                action: { selectColor(at: index) }
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Espacio en blanco al final para que el botón no tape colores
                    Spacer().frame(height: 120)
                }
            }

            // BOTÓN DE NARRACIÓN (Arriba a la derecha)
            VStack {
                HStack {
                    Spacer()
                    NarrationToggleButton(audioManager: audioManager)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
                Spacer()
            }

            // BOTÓN FLOTANTE (Aparece cuando seleccionas color)
            if let index = selectedIndex {
                VStack {
                    Spacer() // Lo empuja hasta abajo
                    
                    Button(action: { openCamera() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder").font(.system(size: 22, weight: .semibold))
                            Text("Open Camera to Scan").font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Capsule().fill(Color.ventralTeal))
                        .shadow(color: Color.ventralTeal.opacity(0.6), radius: 20, y: 8)
                        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 2))
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40) // Separación del borde inferior
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(2) // Asegura que SIEMPRE esté arriba de todo
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedIndex)
    }

    private func selectColor(at index: Int) {
        audioManager.playSelection()
        withAnimation(.spring()) {
            selectedIndex = index
        }
        engine.selectedColor = colorOptions[index].color
        engine.creatureColor = colorOptions[index].color
    }

    private func openCamera() {
        guard let index = selectedIndex else { return }
        audioManager.playTransition()
        withAnimation(.easeInOut(duration: 0.6)) {
            engine.selectTargetColor(colorOptions[index].color)
            engine.currentPhase = .scanning // <-- AQUÍ CORREGIMOS EL ERROR
        }
    }
}

// MARK: - Color Grid Button (¡No borrar!)
struct ColorGridButton: View {
    let option:     (color: Color, icon: String, name: String)
    let isSelected: Bool
    let isDimmed:   Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(option.color)
                        .frame(height: 130)
                        .shadow(color: option.color.opacity(0.6), radius: 15)

                    Image(systemName: option.icon)
                        .font(.system(size: 55, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.ventralTeal)
                                            .frame(width: 36, height: 36)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 5)
                                    .padding(8)
                            }
                            Spacer()
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(option.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.lavenderMist)
            }
            .opacity(isDimmed ? 0.4 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.ventralTeal : Color.clear, lineWidth: 4)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(option.name) color")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select this color")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
