import SwiftUI

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: NowDesign.Spacing.sm) {
            Image(systemName: streak > 0 ? "flame.fill" : "flame")
                .font(.system(size: 20))
                .foregroundStyle(streak > 0 ? Color.streakActive : Color.streakInactive)
                .symbolEffect(.bounce, value: streak)

            Text("\(streak)")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(streak > 0 ? Color.streakActive : Color.streakInactive)

            Text(streak == 1 ? "day" : "days")
                .font(NowDesign.Typography.body)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streak) day streak")
    }
}
