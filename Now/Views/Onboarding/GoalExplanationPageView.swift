import SwiftUI

struct GoalExplanationPageView: View {
    var body: some View {
        VStack(spacing: NowDesign.Spacing.xl) {
            Spacer()

            // Mini progress ring illustration
            ZStack {
                Circle()
                    .stroke(Color.ringBackground, lineWidth: 8)

                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        Color.ringForeground,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("8")
                        .font(.system(size: 32, weight: .light, design: .rounded))
                    Text("min")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)

            Text("Your Daily Goal")
                .font(NowDesign.Typography.heading)
                .foregroundStyle(Color.nowPrimary)

            Text("Research suggests just 8 minutes of daily meditation can reduce stress and improve focus.\n\nBuild a streak by meditating every day. Every session counts toward your goal.")
                .font(NowDesign.Typography.body)
                .foregroundStyle(Color.nowSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("You can adjust this anytime in settings.")
                .font(NowDesign.Typography.caption)
                .foregroundStyle(.tertiary)

            Spacer()
            Spacer()
        }
        .padding(NowDesign.Spacing.lg)
    }
}
