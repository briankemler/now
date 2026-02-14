import SwiftUI
import SwiftData

@main
struct NowWatchApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([WatchMeditationSession.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create Watch ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
        .modelContainer(container)
    }
}
