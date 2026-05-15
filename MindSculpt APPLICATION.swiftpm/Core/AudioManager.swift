import Foundation
import AVFoundation
import SwiftUI

@MainActor
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    @Published var isNarrationEnabled: Bool = true
    
    private var sfxPlayers: [AVAudioPlayer] = []
    private var ambientPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
        print("🎵 AudioManager: Initializing...")
        setupAudioSession()
        speechSynthesizer.delegate = self
        debugBundleContents()
        print("✅ AudioManager: Ready\n")
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("✅ Audio Session: Active")
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }
    
    private func debugBundleContents() {
        print("\n📦 Bundle Debug:")
        
        // Check if Sounds folder exists in bundle
        if let resourcePath = Bundle.main.resourcePath {
            print("   Resource Path: \(resourcePath)")
            
            let soundsPath = (resourcePath as NSString).appendingPathComponent("Sounds")
            if FileManager.default.fileExists(atPath: soundsPath) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: soundsPath)
                    print("   ✅ Sounds/ folder found with \(files.count) files:")
                    for file in files {
                        print("      → \(file)")
                    }
                } catch {
                    print("   ❌ Error reading Sounds/: \(error)")
                }
            } else {
                print("   ⚠️ Sounds/ folder NOT in bundle")
                
                // Check root for audio files
                do {
                    let rootFiles = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    let audioFiles = rootFiles.filter { 
                        $0.hasSuffix(".wav") || $0.hasSuffix(".mp3") || $0.hasSuffix(".m4a")
                    }
                    if !audioFiles.isEmpty {
                        print("   ✅ Audio files in root: \(audioFiles.count)")
                        for file in audioFiles {
                            print("      → \(file)")
                        }
                    }
                } catch {
                    print("   ❌ Error reading root: \(error)")
                }
            }
        }
        print("")
    }
    
    // MARK: - SFX
    
    func playSelection() {
        playSFX(filename: "ui_seleccion_suave")
    }
    
    func playError() {
        playSFX(filename: "ui_error_sutil")
    }
    
    func playTransition() {
        playSFX(filename: "navegacion_transicion")
    }
    
    func playCageBreak() {
        playSFX(filename: "accion_romper_capullo")
    }
    
    func playSuccess() {
        playSFX(filename: "feedback_escaneo_exito")
    }
    
    private func playSFX(filename: String) {
        print("🔊 SFX: \(filename)")
        
        // Strategy 1: Try Sounds/ subdirectory
        for ext in ["wav", "mp3", "m4a", ""] {
            if let url = findAudioFile(filename: filename, extension: ext, subdirectory: "Sounds") {
                print("   ✅ Found in Sounds/: \(url.lastPathComponent)")
                playSFXFromURL(url)
                return
            }
        }
        
        // Strategy 2: Try root
        for ext in ["wav", "mp3", "m4a", ""] {
            if let url = findAudioFile(filename: filename, extension: ext, subdirectory: nil) {
                print("   ✅ Found in root: \(url.lastPathComponent)")
                playSFXFromURL(url)
                return
            }
        }
        
        // Strategy 3: Manual path construction (Swift Playgrounds fallback)
        if let resourcePath = Bundle.main.resourcePath {
            let paths = [
                "\(resourcePath)/Sounds/\(filename).wav",
                "\(resourcePath)/Sounds/\(filename).mp3",
                "\(resourcePath)/Sounds/\(filename)",
                "\(resourcePath)/\(filename).wav",
                "\(resourcePath)/\(filename).mp3",
                "\(resourcePath)/\(filename)"
            ]
            
            for path in paths {
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    print("   ✅ Found via manual path: \(url.lastPathComponent)")
                    playSFXFromURL(url)
                    return
                }
            }
        }
        
        print("   ❌ NOT FOUND: \(filename)")
    }
    
    private func findAudioFile(filename: String, extension ext: String, subdirectory: String?) -> URL? {
        let extToUse = ext.isEmpty ? nil : ext
        return Bundle.main.url(forResource: filename, withExtension: extToUse, subdirectory: subdirectory)
    }
    
    private func playSFXFromURL(_ url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7
            player.prepareToPlay()
            
            if player.play() {
                print("   ▶️ PLAYING (\(String(format: "%.1f", player.duration))s)")
                sfxPlayers.append(player)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) { [weak self] in
                    self?.sfxPlayers.removeAll { $0 == player }
                }
            } else {
                print("   ❌ play() failed")
            }
        } catch {
            print("   ❌ Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Ambient
    
    func startHappyAmbience() {
        startAmbience(filename: "ambiente_feliz_arbol")
    }
    
    func startSadAmbience() {
        startAmbience(filename: "ambiente_triste_marron")
    }
    
    func stopAmbience() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        
        guard let player = ambientPlayer, player.isPlaying else {
            ambientPlayer = nil
            return
        }
        
        fadeVolume(to: 0.0, duration: 1.5) { [weak self] in
            player.stop()
            if self?.ambientPlayer === player {
                self?.ambientPlayer = nil
            }
        }
    }
    
    private func startAmbience(filename: String) {
        stopAmbience()
        
        // Try same strategies as SFX
        for ext in ["mp3", "wav", "m4a", ""] {
            if let url = findAudioFile(filename: filename, extension: ext, subdirectory: "Sounds") ?? 
                findAudioFile(filename: filename, extension: ext, subdirectory: nil) {
                startAmbienceFromURL(url)
                return
            }
        }
        
        // Manual path fallback
        if let resourcePath = Bundle.main.resourcePath {
            let paths = [
                "\(resourcePath)/Sounds/\(filename).mp3",
                "\(resourcePath)/Sounds/\(filename).wav",
                "\(resourcePath)/\(filename).mp3",
                "\(resourcePath)/\(filename).wav"
            ]
            
            for path in paths {
                if FileManager.default.fileExists(atPath: path) {
                    startAmbienceFromURL(URL(fileURLWithPath: path))
                    return
                }
            }
        }
    }
    
    private func startAmbienceFromURL(_ url: URL) {
        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = ambientPlayer else { return }
            
            player.numberOfLoops = -1
            player.volume = 0.0
            player.prepareToPlay()
            
            if player.play() {
                print("🎵 Ambient: \(url.lastPathComponent) (looping)")
                fadeVolume(to: 0.4, duration: 2.0)
            }
        } catch {
            print("❌ Ambient error: \(error)")
        }
    }
    
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        fadeTimer = nil
        
        guard let player = ambientPlayer else {
            completion?()
            return
        }
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let startVolume = player.volume
        let volumeStep = (targetVolume - startVolume) / Float(steps)
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self, weak player] timer in
            guard let player = player else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            player.volume = startVolume + (volumeStep * Float(currentStep))
            
            if currentStep >= steps {
                timer.invalidate()
                self?.fadeTimer = nil
                player.volume = targetVolume
                completion?()
            }
        }
    }
    
    func speak(_ text: String) {
        guard isNarrationEnabled else { return }
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        utterance.volume = 0.8
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
}

extension AudioManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            print("✅ Speech done")
        }
    }
}
