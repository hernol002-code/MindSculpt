import SwiftUI

// MARK: - Focus Menu View (Sensory Games Launcher)
struct FocusMenuView: View {
    @Environment(\.dismiss) private var dismiss

    // FIX BP-01: AudioManager.shared is a pre-existing singleton — this view
    // does not create or own it. @ObservedObject is the correct wrapper.
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var showRipples   = false
    @State private var showBreathing = false

    var body: some View {
        ZStack {
            Color.deepSlate.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50))
                        .foregroundColor(.ventralTeal)

                    Text("Focus & Calm")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.lavenderMist)

                    Text("Choose a grounding exercise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.lavenderMist.opacity(0.7))
                }
                .padding(.top, 60)

                Spacer()

                // Exercises
                VStack(spacing: 25) {
                    // Sensory Ripples
                    Button(action: {
                        audioManager.playSelection()
                        HapticManager.shared.playImpact(style: .medium)
                        showRipples = true
                    }) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.ventralTeal.opacity(0.2))
                                    .frame(width: 60, height: 60)

                                Image(systemName: "water.waves")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.ventralTeal)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Sensory Ripples")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.lavenderMist)

                                Text("Tap to create soothing waves")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.lavenderMist.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.ventralTeal)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.ventralTeal.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    .accessibilityLabel("Sensory Ripples")
                    .accessibilityHint("Tap to create soothing visual ripples")

                    // Breathing Sync
                    Button(action: {
                        audioManager.playSelection()
                        HapticManager.shared.playImpact(style: .medium)
                        showBreathing = true
                    }) {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.mutedSunshine.opacity(0.2))
                                    .frame(width: 60, height: 60)

                                Image(systemName: "lungs.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.mutedSunshine)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Breathing Sync")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.lavenderMist)

                                Text("2-minute coherence breathing")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.lavenderMist.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.mutedSunshine)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.mutedSunshine.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    .accessibilityLabel("Breathing Sync")
                    .accessibilityHint("Start a 2-minute guided breathing exercise")
                }
                .padding(.horizontal, 30)

                Spacer()

                // Close
                Button(action: { dismiss() }) {
                    Text("Close")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.lavenderMist.opacity(0.7))
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showRipples)   { SensoryRipplesView() }
        .fullScreenCover(isPresented: $showBreathing) { BreathingSyncView()  }
    }
}

// MARK: - Preview
struct FocusMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FocusMenuView()
    }
}
