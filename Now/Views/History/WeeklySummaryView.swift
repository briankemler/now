import SwiftUI

struct WeeklySummaryView: View {
    let totalMinutes: Double
    let sessionCount: Int
    let previousWeekMinutes: Double

    private var trend: Trend {
        if previousWeekMinutes == 0 && totalMinutes == 0 { return .neutral }
        if totalMinutes > previousWeekMinutes { return .up }
        if totalMinutes < previousWeekMinutes { return .down }
        return .neutral
    }

    private enum Trend {
        case up, down, neutral
    }

    var body: some View {
        VStack(spacing: NowDesign.Spacing.md) {
            Text("This Week")
                .font(NowDesign.Typography.subheading)
                .foregroundStyle(Color.nowPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: NowDesign.Spacing.xl) {
                // Total minutes
                VStack(spacing: NowDesign.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(totalMinutes))")
                            .font(.system(size: 36, weight: .light, design: .rounded))
                            .foregroundStyle(Color.nowPrimary)

                        trendIndicator
                    }

                    Text("minutes")
                        .font(NowDesign.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 40)

                // Sessions
                VStack(spacing: NowDesign.Spacing.xs) {
                    Text("\(sessionCount)")
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundStyle(Color.nowPrimary)

                    Text(sessionCount == 1 ? "session" : "sessions")
                        .font(NowDesign.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(NowDesign.Spacing.md)
        .background(Color.nowSurface)
        .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.card))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "This week: \(Int(totalMinutes)) minutes, \(sessionCount) sessions"
        )
    }

    @ViewBuilder
    private var trendIndicator: some View {
        switch trend {
        case .up:
            Image(systemName: "arrow.up.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.nowSuccess)
        case .down:
            Image(systemName: "arrow.down.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.streakActive)
        case .neutral:
            EmptyView()
        }
    }
}
