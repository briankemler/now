import SwiftUI
import SwiftData

struct WatchHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WatchTimerViewModel()
    @State private var connectivityService = WatchPhoneConnectivityService()
    @State private var showTimer = false
    @State private var showDurationPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Progress ring
                    WatchProgressRingView(
                        progress: viewModel.dailyProgress,
                        streak: viewModel.currentStreak
                    )

                    // Streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(viewModel.currentStreak > 0 ? .orange : .gray)
                        Text("\(viewModel.currentStreak) days")
                            .font(.system(size: 14, design: .rounded))
                    }

                    // Start button
                    Button {
                        viewModel.start(duration: viewModel.selectedDuration)
                        showTimer = true
                    } label: {
                        Text("Begin")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)

                    // Duration
                    Button {
                        showDurationPicker = true
                    } label: {
                        Text("\(viewModel.selectedDuration / 60) min")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Now")
            .fullScreenCover(isPresented: $showTimer) {
                WatchTimerView(
                    viewModel: viewModel,
                    connectivityService: connectivityService,
                    onDismiss: { showTimer = false }
                )
            }
            .sheet(isPresented: $showDurationPicker) {
                WatchDurationPickerView(viewModel: viewModel)
            }
            .onAppear {
                connectivityService.activate()
                connectivityService.onGoalUpdate = { goalMinutes, streak, minutes in
                    viewModel.applyContextUpdate(
                        goalMinutes: goalMinutes,
                        streak: streak,
                        minutes: minutes
                    )
                }
            }
        }
    }
}
