import SwiftUI
import SwiftData

// MARK: - App Entry Point
// Audit result: No issues found.
// @StateObject is correct in ContentView (owned there), and the
// modelContainer is registered here at the scene level so the
// @Environment(\.modelContext) injection works throughout the hierarchy.
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: CreatureMemory.self)
    }
}

