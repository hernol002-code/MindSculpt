import SwiftUI

// MARK: - Narration Toggle Button (FIXED)
struct NarrationToggleButton: View {
    @ObservedObject var audioManager: AudioManager  // ✅ Changed from @StateObject
    
    var body: some View {
        Button(action: {
            toggleNarration()
        }) {
            ZStack {
                // Background circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.2), radius: 8)
                
                // Icon
                Image(systemName: audioManager.isNarrationEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(audioManager.isNarrationEnabled ? .ventralTeal : .deepSlate.opacity(0.6))
            }
        }
        .accessibilityLabel(audioManager.isNarrationEnabled ? "Narration enabled" : "Narration disabled")
        .accessibilityHint("Double tap to toggle voice narration")
        .accessibilityAddTraits(.isButton)
    }
    
    private func toggleNarration() {
        audioManager.isNarrationEnabled.toggle()
        
        // Haptic feedback
        HapticManager.shared.playSelection()
        
        // Announce state
        if audioManager.isNarrationEnabled {
            audioManager.speak("Narration enabled")
        } else {
            // Play sound since narration is now off
            audioManager.playSelection()
        }
        
        print("🔊 Narration: \(audioManager.isNarrationEnabled ? "ON" : "OFF")")
    }
}

// MARK: - Preview
struct NarrationToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        NarrationToggleButton(audioManager: AudioManager.shared)
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
