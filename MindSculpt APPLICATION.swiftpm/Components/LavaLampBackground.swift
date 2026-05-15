import SwiftUI

// MARK: - Lava Lamp Background
struct LavaLampBackground: View {
    let palette: [Color]
    
    @State private var blob1Position: CGSize = CGSize(width: -100, height: -150)
    @State private var blob2Position: CGSize = CGSize(width: 120, height: 100)
    @State private var blob3Position: CGSize = CGSize(width: -80, height: 180)
    
    @State private var blob1Scale: CGFloat = 1.0
    @State private var blob2Scale: CGFloat = 1.0
    @State private var blob3Scale: CGFloat = 1.0
    
    init(palette: [Color] = [.ventralTeal, .lavenderMist, .mutedSunshine]) {
        self.palette = palette
    }
    
    var body: some View {
        ZStack {
            // Base dark background
            Color.deepSlate.opacity(0.3).ignoresSafeArea()
            
            // Blob 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            palette[safe: 0] ?? .ventralTeal,
                            palette[safe: 1] ?? .lavenderMist
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(blob1Position)
                .scaleEffect(blob1Scale)
                .blur(radius: 60)
            
            // Blob 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            palette[safe: 1] ?? .lavenderMist,
                            palette[safe: 2] ?? .mutedSunshine
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(blob2Position)
                .scaleEffect(blob2Scale)
                .blur(radius: 60)
            
            // Blob 3
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            palette[safe: 2] ?? .mutedSunshine,
                            palette[safe: 0] ?? .ventralTeal
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 190
                    )
                )
                .frame(width: 380, height: 380)
                .offset(blob3Position)
                .scaleEffect(blob3Scale)
                .blur(radius: 60)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(
            .easeInOut(duration: 10.0)
            .repeatForever(autoreverses: true)
        ) {
            blob1Position = CGSize(width: 100, height: 150)
            blob1Scale = 1.3
        }
        
        withAnimation(
            .easeInOut(duration: 12.0)
            .repeatForever(autoreverses: true)
        ) {
            blob2Position = CGSize(width: -120, height: -100)
            blob2Scale = 0.8
        }
        
        withAnimation(
            .easeInOut(duration: 8.0)
            .repeatForever(autoreverses: true)
        ) {
            blob3Position = CGSize(width: 80, height: -180)
            blob3Scale = 1.2
        }
    }
}
