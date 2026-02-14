import SwiftUI
import WidgetKit

struct ComplicationViews: View {
    let entry: NowComplicationEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    // MARK: - Circular Complication

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)

                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(
                            entry.progress >= 1.0 ? Color.green : Color.purple,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 36, height: 36)
                .overlay {
                    VStack(spacing: -2) {
                        Text("\(entry.streak)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Image(systemName: "flame.fill")
                            .font(.system(size: 8))
                    }
                }
            }
        }
        .widgetAccentable()
    }

    // MARK: - Corner Complication

    private var cornerView: some View {
        ZStack {
            AccessoryWidgetBackground()

            Gauge(value: entry.progress) {
                VStack(spacing: -2) {
                    Text("\(entry.streak)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: "flame.fill")
                        .font(.system(size: 8))
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(entry.progress >= 1.0 ? .green : .purple)
        }
        .widgetAccentable()
    }

    // MARK: - Inline Complication

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(Int(entry.todayMinutes)) min")

            Text("|")
                .foregroundStyle(.secondary)

            Text("\(entry.streak) day streak")
        }
        .widgetAccentable()
    }
}
