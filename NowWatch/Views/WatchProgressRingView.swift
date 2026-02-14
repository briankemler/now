import SwiftUI

struct WatchProgressRingView: View {
    let progress: Double
    let streak: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.2), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress >= 1.0 ? Color.green : Color.purple,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 0) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
            }
        }
        .frame(width: 100, height: 100)
        .accessibilityLabel("\(Int(progress * 100)) percent of daily goal complete")
    }
}
