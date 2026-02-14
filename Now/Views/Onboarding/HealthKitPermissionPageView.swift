import SwiftUI

struct HealthKitPermissionPageView: View {
    @Binding var requestHealthKit: Bool
    let isAvailable: Bool

    var body: some View {
        VStack(spacing: NowDesign.Spacing.xl) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.nowSuccess)

            Text("Apple Health")
                .font(NowDesign.Typography.heading)
                .foregroundStyle(Color.nowPrimary)

            if isAvailable {
                Text("Connect with Apple Health to save your meditation sessions as Mindful Minutes.\n\nSessions from other mindfulness apps can also count toward your daily goal.")
                    .font(NowDesign.Typography.body)
                    .foregroundStyle(Color.nowSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Toggle(isOn: $requestHealthKit) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(Color.nowSuccess)
                        Text("Connect Health")
                            .font(NowDesign.Typography.subheading)
                    }
                }
                .tint(Color.nowAccent)
                .padding(.horizontal, NowDesign.Spacing.lg)
                .padding(.vertical, NowDesign.Spacing.md)
                .background(Color.nowSurface)
                .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
            } else {
                Text("Apple Health is not available on this device. Your sessions will be tracked locally within Now.")
                    .font(NowDesign.Typography.body)
                    .foregroundStyle(Color.nowSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
            Spacer()
        }
        .padding(NowDesign.Spacing.lg)
    }
}
