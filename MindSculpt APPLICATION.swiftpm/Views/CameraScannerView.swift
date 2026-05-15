import SwiftUI
import UIKit
import AVFoundation

// MARK: - Camera Scanner View
//
// FIX BUG-01: The file previously contained TWO declarations of
// `struct CameraScannerView`. The second block was appended as update
// instructions but never integrated, causing a build failure
// ("invalid redeclaration of CameraScannerView").
//
// Resolution: the audio additions and accessibility labels from the
// second block have been merged into this single, definitive struct.
// The duplicate declaration has been deleted entirely.
//
struct CameraScannerView: View {
    @ObservedObject var engine: GameEngine

    @StateObject private var cameraManager = CameraManager()

    // FIX BP-01: AudioManager.shared is a pre-existing singleton.
    // @ObservedObject is correct — this view does not own the object.
    @ObservedObject private var audioManager = AudioManager.shared

    @State private var detectedColor: Color = .gray
    @State private var isColorMatch = false
    @State private var captureSuccess = false
    @State private var permissionDenied = false
    @State private var showSanctuaryButton = false

    // MARK: - Target Color Name
    var targetColorName: String {
        let colorNames: [(Color, String)] = [
            (.ventralTeal,                              "Calm Teal"),
            (.lavenderMist,                             "Peaceful Lavender"),
            (.mutedSunshine,                            "Joyful Yellow"),
            (.softCoral,                                "Warm Coral"),
            (.deepSlate,                                "Deep Slate"),
            (Color(red: 0.52, green: 0.76, blue: 0.89), "Flow Blue"),
            (Color(red: 0.72, green: 0.88, blue: 0.82), "Nature Green"),
            (Color(red: 0.96, green: 0.64, blue: 0.38), "Warm Orange")
        ]

        if let target = engine.targetColor {
            for (color, name) in colorNames {
                if colorsAreSimilar(color, target, threshold: 0.2) {
                    return name
                }
            }
        }
        return "the selected color"
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            if !permissionDenied {
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack {
                // Header
                HStack {
                    Button(action: { engine.skipCamera() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Skip")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(.ultraThinMaterial))
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
                .padding(.top, 50)

                Spacer()

                // Reticle
                VStack(spacing: 25) {
                    Text("Find something")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 12)

                    Text(targetColorName)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(engine.targetColor ?? .white)
                        .shadow(color: .black.opacity(0.8), radius: 12)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(.ultraThinMaterial))

                    // Crosshair
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 200, height: 200)

                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 230, height: 230)

                        VStack(spacing: 0) {
                            Rectangle().fill(Color.white).frame(width: 4, height: 50)
                            Spacer().frame(height: 100)
                            Rectangle().fill(Color.white).frame(width: 4, height: 50)
                        }
                        .frame(height: 200)

                        HStack(spacing: 0) {
                            Rectangle().fill(Color.white).frame(width: 50, height: 4)
                            Spacer().frame(width: 100)
                            Rectangle().fill(Color.white).frame(width: 50, height: 4)
                        }
                        .frame(width: 200)

                        Circle()
                            .fill(detectedColor)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Circle()
                                    .stroke(isColorMatch ? Color.green : Color.white, lineWidth: 5)
                            )
                            .shadow(color: detectedColor.opacity(0.8), radius: 25)

                        if isColorMatch {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .shadow(color: .black.opacity(0.6), radius: 12)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                Spacer()

                // Buttons
                VStack(spacing: 15) {
                    if permissionDenied {
                        VStack(spacing: 10) {
                            Text("Camera Permission Denied")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)

                            Text("Go to Settings to enable")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
                        .padding(.horizontal, 30)
                    }

                    // Capture button
                    if !showSanctuaryButton {
                        Button(action: { captureColor() }) {
                            HStack(spacing: 12) {
                                Image(systemName: captureSuccess ? "checkmark.circle.fill" : "camera.fill")
                                    .font(.system(size: 24, weight: .semibold))

                                Text(captureSuccess
                                     ? "Captured!"
                                     : (isColorMatch ? "Capture Color" : "Searching..."))
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial)
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    isColorMatch
                                                        ? Color.green.opacity(0.7)
                                                        : Color.white.opacity(0.2),
                                                    isColorMatch
                                                        ? Color.green.opacity(0.4)
                                                        : Color.white.opacity(0.05)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        isColorMatch ? Color.green : Color.white.opacity(0.6),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(
                                color: isColorMatch
                                    ? Color.green.opacity(0.6)
                                    : Color.black.opacity(0.4),
                                radius: 20, x: 0, y: 12
                            )
                        }
                        .disabled(!isColorMatch || captureSuccess)
                        .opacity(isColorMatch ? 1.0 : 0.6)
                        .padding(.horizontal, 30)
                    }

                    // Take to Sanctuary button
                    if showSanctuaryButton {
                        Button(action: { takeToSanctuary() }) {
                            HStack(spacing: 12) {
                                Image(systemName: "tree.fill")
                                    .font(.system(size: 24, weight: .semibold))

                                Text("Take to Sanctuary")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.ventralTeal,
                                                Color(red: 0.84, green: 0.92, blue: 0.97)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.ventralTeal.opacity(0.6), radius: 25, x: 0, y: 12)
                        }
                        .padding(.horizontal, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .accessibilityLabel("Take to Sanctuary")
                        .accessibilityHint("Double tap to bring your companion to the peaceful sanctuary")
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear { requestCameraPermission() }
        .onDisappear { cameraManager.stopSession() }
        .onChange(of: cameraManager.currentColor) { newColor in
            detectedColor = newColor
            checkColorMatch()
        }
    }

    // MARK: - Camera Permission
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    cameraManager.startSession()
                } else {
                    permissionDenied = true
                }
            }
        }
    }

    // MARK: - Color Matching
    private func checkColorMatch() {
        guard let target = engine.targetColor else {
            isColorMatch = false
            return
        }

        let match = colorsAreSimilar(detectedColor, target, threshold: 0.25)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isColorMatch = match
        }

        if match {
            HapticManager.shared.playNotification(type: .success)
        }
    }

    // MARK: - Capture Color
    // Integrated from the second (now-deleted) struct block:
    // plays success SFX and speaks feedback before showing the sanctuary button.
    private func captureColor() {
        guard isColorMatch else { return }

        captureSuccess = true
        HapticManager.shared.playNotification(type: .success)
        audioManager.playSuccess()
        audioManager.speak("Captured. Take to Sanctuary")

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSanctuaryButton = true
            }
        }
    }

    // MARK: - Take to Sanctuary
    // Integrated from the second (now-deleted) struct block:
    // plays transition SFX before navigating.
    private func takeToSanctuary() {
        HapticManager.shared.playImpact(style: .medium)
        audioManager.playTransition()
        engine.completeColorJourney()
    }

    // MARK: - Color Similarity Helper
    private func colorsAreSimilar(_ color1: Color, _ color2: Color, threshold: Double) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
        return distance < threshold
    }
}

// MARK: - Camera Manager
@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var currentColor: Color = .gray

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let videoQueue = DispatchQueue(label: "videoQueue")

    func startSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        guard let session = captureSession,
              let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back
              ) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) { session.addInput(input) }

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: videoQueue)
            if let output = videoOutput, session.canAddOutput(output) {
                session.addOutput(output)
            }

            Task { session.startRunning() }
        } catch {
            print("❌ Camera error: \(error)")
        }
    }

    func stopSession() {
        captureSession?.stopRunning()
        captureSession = nil
    }

    func getCaptureSession() -> AVCaptureSession? { captureSession }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        let color = getPixelColor(
            cgImage: cgImage,
            x: cgImage.width / 2,
            y: cgImage.height / 2
        )

        Task { @MainActor in self.currentColor = Color(color) }
    }

    nonisolated private func getPixelColor(cgImage: CGImage, x: Int, y: Int) -> UIColor {
        guard let data  = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return .gray }

        let bytesPerPixel = 4
        let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)

        return UIColor(
            red:   CGFloat(bytes[offset])     / 255.0,
            green: CGFloat(bytes[offset + 1]) / 255.0,
            blue:  CGFloat(bytes[offset + 2]) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        if let session = cameraManager.getCaptureSession() {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)
            context.coordinator.previewLayer = previewLayer
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Preview
struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView(engine: GameEngine())
    }
}
