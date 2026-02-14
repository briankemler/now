import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let goalMinutes: Int
    let currentMinutes: Double
    var size: CGFloat = 220
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.ringBackground, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(NowDesign.Anim.slow, value: progress)

            // Center content
            VStack(spacing: NowDesign.Spacing.xs) {
                Text("\(Int(currentMinutes))")
                    .font(NowDesign.Typography.statLarge)
                    .foregroundStyle(Color.nowPrimary)

                Text("of \(goalMinutes) min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(Int(currentMinutes)) of \(goalMinutes) minutes, \(Int(progress * 100)) percent complete"
        )
        .accessibilityValue("\(Int(progress * 100)) percent")
    }

    private var progressGradient: some ShapeStyle {
        if progress >= 1.0 {
            return AnyShapeStyle(Color.nowSuccess)
        }
        return AnyShapeStyle(Color.ringForeground)
    }
}
