import SwiftUI

// MARK: - Input View (Journal Entry)
//
// NOTE BUG-04: This view reads `engine.sentimentAnalyzer.isAnalyzing` to drive
// the "Analyzing…" spinner. The fix for that not triggering redraws lives in
// GameEngine.swift (making `sentimentAnalyzer` a @Published property), not here.
// Once that change lands, the spinner and button-disable logic will work correctly.
//
struct InputView: View {
    @ObservedObject var engine: GameEngine

    @State private var isButtonPressed = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)

                // Logo
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.05)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.deepSlate)
                        .shadow(color: .white.opacity(0.5), radius: 20)
                }

                // Title
                VStack(spacing: 12) {
                    Text("MindSculpt")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.deepSlate)
                        .shadow(color: .white.opacity(0.5), radius: 10)

                    Text("Shape your stress.\nSculpt your calm.")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.deepSlate.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 30)

                Spacer()
                    .frame(height: 20)

                // Input Section
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How was your day?")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.deepSlate)
                            .padding(.leading, 8)

                        ZStack(alignment: .topLeading) {
                            // Placeholder
                            if engine.userText.isEmpty {
                                Text("Tell me about your day...")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.deepSlate.opacity(0.4))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }

                            // Text Editor
                            TextEditor(text: $engine.userText)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.deepSlate)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(height: 120)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .focused($isTextFieldFocused)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.7))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.deepSlate.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    }

                    // Materialize Button
                    Button(action: { handleMaterialize() }) {
                        HStack(spacing: 12) {
                            if engine.sentimentAnalyzer.isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20, weight: .semibold))
                            }

                            Text(engine.sentimentAnalyzer.isAnalyzing ? "Analyzing..." : "Materialize")
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
                                            Color.deepSlate,
                                            Color.deepSlate.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.deepSlate.opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                    .disabled(engine.userText.isEmpty || engine.sentimentAnalyzer.isAnalyzing)
                    .opacity(engine.userText.isEmpty ? 0.5 : 1.0)
                    .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                }
                .padding(.horizontal, 40)

                Spacer()
                    .frame(height: 60)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture { isTextFieldFocused = false }
    }

    // MARK: - Button Handler
    private func handleMaterialize() {
        isTextFieldFocused = false
        HapticManager.shared.playImpact(style: .medium)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isButtonPressed = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isButtonPressed = false
            }
        }

        engine.startJourney()
    }
}

// MARK: - Preview
struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(engine: GameEngine())
    }
}
