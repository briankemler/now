import Foundation
import Combine

@Observable
final class TimerService {
    enum TimerState: Equatable {
        case idle
        case running
        case paused
        case completed
    }

    private(set) var state: TimerState = .idle
    private(set) var remainingSeconds: Int = 0
    private(set) var elapsedSeconds: Int = 0
    private(set) var totalDuration: Int = 0

    private var startTime: Date?
    private var pausedTime: Date?
    private var totalPauseDuration: TimeInterval = 0
    private var timerCancellable: AnyCancellable?

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalDuration)
    }

    func start(duration: Int) {
        totalDuration = duration
        remainingSeconds = duration
        elapsedSeconds = 0
        totalPauseDuration = 0
        startTime = Date()
        state = .running
        startTicking()
    }

    func pause() {
        guard state == .running else { return }
        pausedTime = Date()
        state = .paused
        timerCancellable?.cancel()
    }

    func resume() {
        guard state == .paused, let pausedTime else { return }
        totalPauseDuration += Date().timeIntervalSince(pausedTime)
        self.pausedTime = nil
        state = .running
        startTicking()
    }

    func stop() -> Int {
        timerCancellable?.cancel()
        let elapsed = elapsedSeconds
        state = .idle
        return elapsed
    }

    func recalculateAfterBackground() {
        guard state == .running, let startTime else { return }
        let wallElapsed = Date().timeIntervalSince(startTime) - totalPauseDuration
        let newElapsed = min(Int(wallElapsed), totalDuration)
        elapsedSeconds = newElapsed
        remainingSeconds = max(totalDuration - newElapsed, 0)

        if remainingSeconds <= 0 {
            timerCancellable?.cancel()
            elapsedSeconds = totalDuration
            remainingSeconds = 0
            state = .completed
        }
    }

    private func startTicking() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard state == .running, let startTime else { return }

        let wallElapsed = Date().timeIntervalSince(startTime) - totalPauseDuration
        elapsedSeconds = min(Int(wallElapsed), totalDuration)
        remainingSeconds = max(totalDuration - elapsedSeconds, 0)

        if remainingSeconds <= 0 {
            timerCancellable?.cancel()
            elapsedSeconds = totalDuration
            remainingSeconds = 0
            state = .completed
        }
    }
}
