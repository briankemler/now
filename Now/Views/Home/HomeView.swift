import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var timerViewModel = TimerViewModel()
    @State private var healthKitService = HealthKitService()
    @State private var streakService = StreakService()
    @State private var showTimer = false
    @State private var showDurationPicker = false
    @State private var selectedDuration: Int = 480
    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: NowDesign.Spacing.lg) {
                Spacer()

                // Progress Ring
                ProgressRingView(
                    progress: viewModel.progressFraction,
                    goalMinutes: viewModel.dailyGoalMinutes,
                    currentMinutes: viewModel.todayMinutes
                )

                // Streak
                StreakBadgeView(streak: viewModel.currentStreak)
                    .padding(.top, NowDesign.Spacing.sm)

                // Status message
                statusMessage
                    .padding(.top, NowDesign.Spacing.sm)

                Spacer()

                // Begin button
                Button {
                    startMeditation(duration: settings.lastSelectedDuration)
                } label: {
                    Text("Begin")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NowDesign.Spacing.md)
                        .background(Color.nowAccent)
                        .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.lg))
                }
                .padding(.horizontal, NowDesign.Spacing.xxl)
                .accessibilityLabel("Begin \(settings.lastSelectedDuration.asMinutesFormatted) meditation")

                // Duration selector
                Button {
                    showDurationPicker = true
                } label: {
                    HStack(spacing: NowDesign.Spacing.xs) {
                        Image(systemName: "clock")
                        Text(settings.lastSelectedDuration.asMinutesFormatted)
                    }
                    .font(NowDesign.Typography.body)
                    .foregroundStyle(Color.nowSecondary)
                }
                .padding(.bottom, NowDesign.Spacing.lg)
            }
            .navigationTitle("Now")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showTimer) {
            TimerView(
                viewModel: timerViewModel,
                healthKitService: healthKitService,
                streakService: streakService,
                onDismiss: {
                    showTimer = false
                    Task {
                        await viewModel.refresh(
                            modelContext: modelContext,
                            streakService: streakService,
                            healthKitService: healthKitService
                        )
                    }
                }
            )
        }
        .sheet(isPresented: $showDurationPicker) {
            DurationPickerView(
                selectedDuration: $selectedDuration,
                onStart: { duration in
                    showDurationPicker = false
                    startMeditation(duration: duration)
                }
            )
            .presentationDetents([.medium])
        }
        .task {
            healthKitService.checkAuthorizationStatus()
            await viewModel.refresh(
                modelContext: modelContext,
                streakService: streakService,
                healthKitService: healthKitService
            )
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        if viewModel.goalMet {
            HStack(spacing: NowDesign.Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                Text("Daily goal complete")
            }
            .font(NowDesign.Typography.body)
            .foregroundStyle(Color.nowSuccess)
        } else if viewModel.todayMinutes > 0 {
            Text("\(String(format: "%.0f", viewModel.remainingMinutes)) min remaining")
                .font(NowDesign.Typography.body)
                .foregroundStyle(Color.nowSecondary)
        } else {
            Text("Start your practice")
                .font(NowDesign.Typography.body)
                .foregroundStyle(Color.nowSecondary)
        }
    }

    private func startMeditation(duration: Int) {
        selectedDuration = duration
        timerViewModel.startSessionWithDuration(
            duration,
            settings: settings,
            modelContext: modelContext
        )
        showTimer = true
    }
}
