import UIKit
import CoreHaptics

// MARK: - Haptic Manager
// Singleton para manejar todos los haptics de la app
@MainActor
class HapticManager {
    static let shared = HapticManager()

    // MARK: - Feedback Generators (UIKit)
    private let impactLight   = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium  = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy   = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft    = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid   = UIImpactFeedbackGenerator(style: .rigid)
    private let selection     = UISelectionFeedbackGenerator()
    private let notification  = UINotificationFeedbackGenerator()

    // MARK: - Core Haptics Engine (para patrones avanzados)
    private var engine: CHHapticEngine?
    private var heartbeatPlayer: CHHapticAdvancedPatternPlayer?
    private var stressPlayer: CHHapticAdvancedPatternPlayer?

    // MARK: - Initialization
    private init() {
        print("💓 HapticManager: Initializing...")
        
        // Preparar generadores UIKit
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selection.prepare()
        notification.prepare()
        
        // Inicializar Core Haptics
        prepareAdvancedHaptics()
        
        print("✅ HapticManager: Ready")
    }

    // MARK: - Advanced Haptics Setup
    private func prepareAdvancedHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("⚠️ Device does not support advanced haptics")
            return
        }

        do {
            engine = try CHHapticEngine()
            
            engine?.stoppedHandler = { reason in
                print("⚠️ Haptic engine stopped: \(reason.rawValue)")
            }

            engine?.resetHandler = { [weak self] in
                print("🔄 Haptic engine reset")
                Task { @MainActor in
                    do {
                        try self?.engine?.start()
                        print("✅ Haptic engine restarted")
                    } catch {
                        print("❌ Failed to restart haptic engine: \(error)")
                    }
                }
            }

            try engine?.start()
            print("✅ Advanced haptics engine started")
            
        } catch {
            print("❌ Failed to initialize Core Haptics: \(error)")
        }
    }

    // MARK: - Simple Haptics (UIKit Generators)

    /// Light selection feedback
    nonisolated func playSelection() {
        Task { @MainActor in
            selection.selectionChanged()
        }
    }

    /// Variable impact feedback
    nonisolated func playImpact(style: ImpactStyle = .medium) {
        Task { @MainActor in
            switch style {
            case .light:  impactLight.impactOccurred()
            case .medium: impactMedium.impactOccurred()
            case .heavy:  impactHeavy.impactOccurred()
            case .soft:   impactSoft.impactOccurred()
            case .rigid:  impactRigid.impactOccurred()
            }
        }
    }

    /// Notification feedback
    nonisolated func playNotification(type: NotificationType) {
        Task { @MainActor in
            switch type {
            case .success:
                notification.notificationOccurred(.success)
            case .warning:
                notification.notificationOccurred(.warning)
            case .error:
                notification.notificationOccurred(.error)
            }
        }
    }

    // MARK: - 💓 Advanced Haptics: Distressed Heartbeat Pattern

    /// Inicia un patrón continuo de "heartbeat distressed"
    /// La intensidad disminuye conforme progress aumenta (0.0 = max estrés, 1.0 = calma)
    func startDistressedHeartbeat(progress: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // Detener heartbeat existente
        stopHeartbeat()

        do {
            // Asegurar que el engine esté corriendo
            try engine?.start()
        } catch {
            print("❌ Failed to start haptic engine: \(error)")
            return
        }

        // Calcular intensidad basado en nivel de estrés (inverso de progress)
        // progress 0.0 (inicio) → intensity 1.0 (max estrés)
        // progress 1.0 (fin)    → intensity 0.2 (muy calmado)
        let stressLevel = 1.0 - progress
        let intensity   = Float(0.2 + (stressLevel * 0.8)) // Rango: 0.2 a 1.0
        let sharpness   = Float(0.3 + (stressLevel * 0.6)) // Rango: 0.3 a 0.9

        // Patrón de heartbeat: dos golpes rápidos con pausa
        // THUMP-thump.....THUMP-thump.....
        let events: [CHHapticEvent] = [
            // Primer golpe (más fuerte)
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0.0
            ),
            // Segundo golpe (más suave)
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness * 0.7)
                ],
                relativeTime: 0.15
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            heartbeatPlayer = try engine?.makeAdvancedPlayer(with: pattern)

            // Loop del patrón con timing apropiado para heartbeat estresado
            // Más rápido cuando estresado (progress bajo), más lento cuando calmado (progress alto)
            let loopInterval = 0.5 + (progress * 0.5) // Rango: 0.5s (rápido) a 1.0s (lento)
            heartbeatPlayer?.loopEnabled = true
            heartbeatPlayer?.loopEnd = loopInterval

            try heartbeatPlayer?.start(atTime: CHHapticTimeImmediate)
            
            print("💓 Heartbeat started | Intensity: \(String(format: "%.2f", intensity)) | Interval: \(String(format: "%.2f", loopInterval))s")
            
        } catch {
            print("❌ Failed to create heartbeat pattern: \(error)")
        }
    }

    /// Detiene el patrón de heartbeat
    func stopHeartbeat() {
        guard heartbeatPlayer != nil else { return }

        do {
            try heartbeatPlayer?.stop(atTime: CHHapticTimeImmediate)
            heartbeatPlayer = nil
            print("💓 Heartbeat stopped")
        } catch {
            print("❌ Failed to stop heartbeat: \(error)")
        }
    }

    /// Actualiza la intensidad del heartbeat en tiempo real conforme progress cambia
    /// Llamar esto continuamente mientras cocoonIntegrity disminuye
    func updateHeartbeatIntensity(progress: Double) {
        // Para actualizaciones continuas, simplemente reiniciar con nuevos parámetros
        // (CHHapticAdvancedPatternPlayer no soporta actualizaciones de parámetros en vivo fácilmente)
        startDistressedHeartbeat(progress: progress)
    }

    // MARK: - Legacy: Stress Haptic (mantenido por compatibilidad)
    
    func startStressHaptic(intensity: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        stopHaptics()
        
        do {
            try engine?.start()
        } catch {
            print("❌ Engine start error: \(error)")
            return
        }
        
        let intensityValue = Float(min(max(intensity, 0.1), 1.0))
        let sharpnessValue: Float = intensity > 0.6 ? 0.8 : 0.3
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityValue),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessValue)
            ],
            relativeTime: 0,
            duration: 3.0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            stressPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            
            if intensity > 0.7 {
                stressPlayer?.loopEnabled = true
                stressPlayer?.loopEnd = 3.0
            }
            
            try stressPlayer?.start(atTime: CHHapticTimeImmediate)
            
            print("🔔 Stress haptic started")
        } catch {
            print("❌ Haptic error: \(error)")
        }
    }
    
    func stopHaptics() {
        do {
            try stressPlayer?.stop(atTime: CHHapticTimeImmediate)
            stressPlayer = nil
        } catch {
            print("❌ Stop error: \(error)")
        }
    }

    // MARK: - Enums
    
    enum ImpactStyle {
        case light
        case medium
        case heavy
        case soft
        case rigid
    }
    
    enum NotificationType {
        case success
        case warning
        case error
    }
}
