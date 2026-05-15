import SwiftUI
import SwiftData

// MARK: - Memory Garden View (Visual Archive)
struct MemoryGardenView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CreatureMemory.timestamp, order: .reverse) var memories: [CreatureMemory]

    @State private var selectedMemory: CreatureMemory?
    @State private var showMemoryDetail = false

    var body: some View {
        ZStack {
            Color.deepSlate
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.lavenderMist)
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
                .padding(.top, 50)
                .padding(.bottom, 20)

                // Title
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.mutedSunshine)

                    Text("Memory Garden")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.lavenderMist)

                    Text("\(memories.count) peaceful moment\(memories.count == 1 ? "" : "s")")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.lavenderMist.opacity(0.7))
                }
                .padding(.bottom, 30)

                // Content
                if memories.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.lavenderMist.opacity(0.3))

                        Text("No memories yet")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.lavenderMist.opacity(0.6))

                        Text("Complete a journey to create\nyour first glowing memory")
                            .font(.system(size: 16))
                            .foregroundColor(.lavenderMist.opacity(0.5))
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 30) {
                            ForEach(memories) { memory in
                                MemoryFirefly(memory: memory)
                                    .onTapGesture {
                                        selectedMemory  = memory
                                        showMemoryDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .sheet(isPresented: $showMemoryDetail) {
            if let memory = selectedMemory {
                MemoryDetailSheet(memory: memory)
            }
        }
    }
}

// MARK: - Memory Firefly (Glowing Orb)
struct MemoryFirefly: View {
    let memory: CreatureMemory

    @State private var pulse = false
    @State private var float = false

    var memoryColor: Color { Color.fromHex(memory.colorHex) }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            memoryColor.opacity(0.6),
                            memoryColor.opacity(0.2),
                            memoryColor.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .blur(radius: 10)
                .scaleEffect(pulse ? 1.2 : 1.0)

            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            memoryColor.opacity(0.9),
                            memoryColor.opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                .shadow(color: memoryColor.opacity(0.8), radius: 20)

            // Inner sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .scaleEffect(pulse ? 1.1 : 0.9)
        }
        .offset(y: float ? -5 : 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...1))
            ) {
                float = true
            }
        }
        .accessibilityLabel(
            "Memory from \(memory.timestamp.formatted(date: .abbreviated, time: .shortened))"
        )
        .accessibilityHint("Double tap to view details")
    }
}

// MARK: - Memory Detail Sheet
struct MemoryDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let memory: CreatureMemory

    var memoryColor: Color { Color.fromHex(memory.colorHex) }

    var body: some View {
        ZStack {
            Color.deepSlate.ignoresSafeArea()

            VStack(spacing: 30) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.lavenderMist.opacity(0.6))
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)

                Spacer()

                // Large glowing orb
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    memoryColor.opacity(0.6),
                                    memoryColor.opacity(0.2),
                                    memoryColor.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    memoryColor.opacity(0.9),
                                    memoryColor.opacity(0.6)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 3))
                        .shadow(color: memoryColor.opacity(0.8), radius: 30)
                }

                // Timestamp
                VStack(spacing: 8) {
                    Text(memory.timestamp.formatted(date: .long, time: .omitted))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.lavenderMist)

                    Text(memory.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.lavenderMist.opacity(0.7))
                }

                // Gratitude text
                if !memory.gratitudeText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 24))
                            .foregroundColor(.mutedSunshine.opacity(0.6))

                        Text(memory.gratitudeText)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.lavenderMist)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                        Image(systemName: "quote.closing")
                            .font(.system(size: 24))
                            .foregroundColor(.mutedSunshine.opacity(0.6))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.deepSlate.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(memoryColor.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 30)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct MemoryGardenView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGardenView()
            .modelContainer(for: CreatureMemory.self, inMemory: true)
    }
}
