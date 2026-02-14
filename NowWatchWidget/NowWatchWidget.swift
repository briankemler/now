import WidgetKit
import SwiftUI

struct NowComplicationEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let streak: Int
    let todayMinutes: Double
    let goalMinutes: Int
}

struct NowComplicationProvider: TimelineProvider {
    private let appGroupID = "group.com.now.meditation"

    func placeholder(in context: Context) -> NowComplicationEntry {
        NowComplicationEntry(
            date: Date(),
            progress: 0.5,
            streak: 3,
            todayMinutes: 4,
            goalMinutes: 8
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NowComplicationEntry) -> Void) {
        let entry = NowComplicationEntry(
            date: Date(),
            progress: 0.65,
            streak: 7,
            todayMinutes: 5,
            goalMinutes: 8
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NowComplicationEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: appGroupID)
        let progress = defaults?.double(forKey: "dailyProgress") ?? 0
        let streak = defaults?.integer(forKey: "currentStreak") ?? 0
        let todayMinutes = defaults?.double(forKey: "todayMinutes") ?? 0
        let goalMinutes = defaults?.integer(forKey: "goalMinutes") ?? 8

        let entry = NowComplicationEntry(
            date: Date(),
            progress: progress,
            streak: streak,
            todayMinutes: todayMinutes,
            goalMinutes: goalMinutes
        )

        let nextUpdate = Date().addingTimeInterval(15 * 60)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

@main
struct NowWatchWidget: Widget {
    let kind = "NowComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NowComplicationProvider()) { entry in
            ComplicationViews(entry: entry)
        }
        .configurationDisplayName("Now")
        .description("Meditation progress and streak")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}
