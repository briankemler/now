import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: NowDesign.Spacing.xl) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(Color.nowAccent)
                .symbolEffect(.pulse, options: .repeating)

            Text("Welcome to Now")
                .font(NowDesign.Typography.heading)
                .foregroundStyle(Color.nowPrimary)

            Text("A simple space for meditation.\nNo subscriptions. No complexity.\nJust you and the present moment.")
                .font(NowDesign.Typography.body)
                .foregroundStyle(Color.nowSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(NowDesign.Spacing.lg)
    }
}
