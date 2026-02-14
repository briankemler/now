import SwiftUI
import SwiftData

@main
struct NowApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            MeditationSession.self,
            UserGoal.self,
            StreakRecord.self,
            AppSettings.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
