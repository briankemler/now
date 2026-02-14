import SwiftUI

struct CalendarHeatMapView: View {
    let data: [Date: Double]
    let intensityForMinutes: (Double) -> Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
    private let calendar = Calendar.current

    private var days: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<90).compactMap { offset in
            calendar.date(byAdding: .day, value: -89 + offset, to: today)
        }
    }

    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: NowDesign.Spacing.sm) {
            Text("Last 90 Days")
                .font(NowDesign.Typography.subheading)
                .foregroundStyle(Color.nowPrimary)

            // Weekday headers
            HStack(spacing: 3) {
                ForEach(weekdayLabels.indices, id: \.self) { index in
                    Text(weekdayLabels[index])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Heat map grid
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(days, id: \.self) { day in
                    let minutes = data[calendar.startOfDay(for: day)] ?? 0
                    let level = intensityForMinutes(minutes)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(colorForLevel(level))
                        .aspectRatio(1, contentMode: .fit)
                        .accessibilityLabel(accessibilityLabel(for: day, minutes: minutes))
                }
            }

            // Legend
            HStack(spacing: NowDesign.Spacing.sm) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)

                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(level))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, NowDesign.Spacing.xs)
        }
        .padding(NowDesign.Spacing.md)
        .background(Color.nowSurface)
        .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.card))
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.heatmap0
        case 1: return Color.heatmap1
        case 2: return Color.heatmap2
        case 3: return Color.heatmap3
        default: return Color.heatmap4
        }
    }

    private func accessibilityLabel(for day: Date, minutes: Double) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateStr = formatter.string(from: day)
        if minutes > 0 {
            return "\(dateStr): \(Int(minutes)) minutes"
        }
        return "\(dateStr): no meditation"
    }
}
