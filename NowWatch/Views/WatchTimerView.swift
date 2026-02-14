import SwiftUI
import SwiftData

struct WatchTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Bindable var viewModel: WatchTimerViewModel
    var connectivityService: WatchPhoneConnectivityService
    var onDismiss: () -> Void

    var body: some View {
        Group {
            if isLuminanceReduced {
                alwaysOnView
            } else {
                activeTimerView
            }
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .completed {
                Task {
                    let elapsed = viewModel.totalDuration
                    await viewModel.saveSession(
                        elapsed: elapsed,
                        modelContext: modelContext,
                        connectivityService: connectivityService
                    )
                    try? await Task.sleep(for: .seconds(2))
                    onDismiss()
                }
            }
        }
    }

    private var activeTimerView: some View {
        VStack(spacing: 16) {
            // Countdown
            Text(viewModel.remainingFormatted)
                .font(.system(size: 42, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)

            // Mini progress
            ProgressView(value: viewModel.progress)
                .tint(.purple)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            // Controls
            HStack(spacing: 20) {
                switch viewModel.state {
                case .running:
                    Button {
                        viewModel.pause()
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        let elapsed = viewModel.stop()
                        Task {
                            await viewModel.saveSession(
                                elapsed: elapsed,
                                modelContext: modelContext,
                                connectivityService: connectivityService
                            )
                            onDismiss()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                case .paused:
                    Button {
                        viewModel.resume()
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        let elapsed = viewModel.stop()
                        Task {
                            await viewModel.saveSession(
                                elapsed: elapsed,
                                modelContext: modelContext,
                                connectivityService: connectivityService
                            )
                            onDismiss()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                case .completed:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)

                case .idle:
                    EmptyView()
                }
            }
        }
    }

    private var alwaysOnView: some View {
        VStack(spacing: 8) {
            Text(viewModel.remainingFormatted)
                .font(.system(size: 36, weight: .thin, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.purple.opacity(0.5), lineWidth: 3)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 60, height: 60)
        }
    }
}
