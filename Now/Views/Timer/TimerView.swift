import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var viewModel: TimerViewModel
    var healthKitService: HealthKitService
    var streakService: StreakService
    @Query private var settingsArray: [AppSettings]
    var onDismiss: () -> Void

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: NowDesign.Spacing.xl) {
                Spacer()

                // Timer display
                Text(viewModel.remainingFormatted)
                    .font(NowDesign.Typography.timerDisplay)
                    .foregroundStyle(Color.timerText)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityLabel(timerAccessibilityLabel)

                // Progress arc
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 4)

                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            Color.ringForeground,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.progress)
                }
                .frame(width: 200, height: 200)

                Spacer()

                // Controls
                TimerControlsView(
                    state: viewModel.state,
                    onPause: { viewModel.pauseSession() },
                    onResume: { viewModel.resumeSession() },
                    onEnd: {
                        Task {
                            await viewModel.endSession(
                                settings: settings,
                                modelContext: modelContext,
                                healthKitService: healthKitService,
                                streakService: streakService
                            )
                            onDismiss()
                        }
                    }
                )

                Spacer()
                    .frame(height: NowDesign.Spacing.xxl)
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhaseChange(isActive: newPhase == .active)
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .completed {
                Task {
                    await viewModel.handleCompletion(
                        settings: settings,
                        modelContext: modelContext,
                        healthKitService: healthKitService,
                        streakService: streakService
                    )
                    onDismiss()
                }
            }
        }
        .onChange(of: viewModel.elapsedSeconds) { _, _ in
            viewModel.checkIntervalBell(settings: settings)
        }
    }

    private var timerAccessibilityLabel: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        return "\(minutes) minutes \(seconds) seconds remaining"
    }
}
