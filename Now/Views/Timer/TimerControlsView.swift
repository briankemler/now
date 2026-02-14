import SwiftUI

struct TimerControlsView: View {
    let state: TimerService.TimerState
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: NowDesign.Spacing.xl) {
            switch state {
            case .running:
                controlButton(
                    icon: "pause.fill",
                    label: "Pause",
                    action: onPause
                )
                controlButton(
                    icon: "stop.fill",
                    label: "End",
                    tint: .red.opacity(0.8),
                    action: onEnd
                )

            case .paused:
                controlButton(
                    icon: "play.fill",
                    label: "Resume",
                    action: onResume
                )
                controlButton(
                    icon: "stop.fill",
                    label: "End",
                    tint: .red.opacity(0.8),
                    action: onEnd
                )

            default:
                EmptyView()
            }
        }
    }

    private func controlButton(
        icon: String,
        label: String,
        tint: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: NowDesign.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .frame(width: 64, height: 64)
                    .background(tint.opacity(0.2))
                    .clipShape(Circle())

                Text(label)
                    .font(NowDesign.Typography.caption)
            }
            .foregroundStyle(tint)
        }
        .accessibilityLabel(label)
        .frame(minWidth: 44, minHeight: 44)
    }
}
