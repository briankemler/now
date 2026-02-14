import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NowDesign.Spacing.lg) {
                    WeeklySummaryView(
                        totalMinutes: viewModel.weeklyTotalMinutes,
                        sessionCount: viewModel.weeklySessionCount,
                        previousWeekMinutes: viewModel.previousWeekMinutes
                    )
                    .padding(.horizontal, NowDesign.Spacing.md)

                    CalendarHeatMapView(
                        data: viewModel.heatMapData,
                        intensityForMinutes: viewModel.intensityLevel
                    )
                    .padding(.horizontal, NowDesign.Spacing.md)
                }
                .padding(.top, NowDesign.Spacing.md)
            }
            .navigationTitle("History")
            .onAppear {
                viewModel.refresh(modelContext: modelContext)
            }
        }
    }
}
