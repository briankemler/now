import Foundation
import WatchKit
import HealthKit
import SwiftData
import Combine

@Observable
final class WatchTimerViewModel {
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
    var selectedDuration: Int = 480
    private(set) var currentStreak: Int = 0
    private(set) var todayMinutes: Double = 0
    private(set) var dailyGoalMinutes: Int = 8

    private var startTime: Date?
    private var totalPauseDuration: TimeInterval = 0
    private var pausedTime: Date?
    private var timerCancellable: AnyCancellable?
    private var extendedSession: WKExtendedRuntimeSession?

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalDuration)
    }

    var dailyProgress: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(todayMinutes / Double(dailyGoalMinutes), 1.0)
    }

    var remainingFormatted: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    let timerPresets = [300, 480, 600, 900, 1200, 1800]

    func start(duration: Int) {
        totalDuration = duration
        selectedDuration = duration
        remainingSeconds = duration
        elapsedSeconds = 0
        totalPauseDuration = 0
        startTime = Date()
        state = .running

        // Start extended runtime session
        startExtendedSession()

        // Haptic cue
        WKInterfaceDevice.current().play(.start)

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
        extendedSession?.invalidate()
        extendedSession = nil
        let elapsed = elapsedSeconds
        state = .idle
        WKInterfaceDevice.current().play(.stop)
        return elapsed
    }

    func saveSession(
        elapsed: Int,
        modelContext: ModelContext,
        connectivityService: WatchPhoneConnectivityService
    ) async {
        guard let startDate = startTime, elapsed > 0 else { return }
        let endDate = startDate.addingTimeInterval(TimeInterval(elapsed))

        let session = WatchMeditationSession(
            startDate: startDate,
            durationSeconds: selectedDuration
        )
        session.endDate = endDate
        session.actualDurationSeconds = elapsed
        session.completed = elapsed >= selectedDuration
        modelContext.insert(session)

        // Write to HealthKit
        await writeToHealthKit(start: startDate, end: endDate)

        // Sync to phone
        let payload = SessionSyncPayload(
            sessionID: session.sessionID,
            startDate: startDate,
            endDate: endDate,
            durationSeconds: selectedDuration,
            actualDurationSeconds: elapsed,
            completed: session.completed,
            source: "appleWatch"
        )
        connectivityService.sendSession(payload)

        todayMinutes += Double(elapsed) / 60.0
        startTime = nil
    }

    func applyContextUpdate(goalMinutes: Int, streak: Int, minutes: Double) {
        dailyGoalMinutes = goalMinutes
        currentStreak = streak
        todayMinutes = minutes
    }

    // MARK: - Private

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
            WKInterfaceDevice.current().play(.success)
            extendedSession?.invalidate()
            extendedSession = nil
        }
    }

    private func startExtendedSession() {
        extendedSession = WKExtendedRuntimeSession()
        extendedSession?.start()
    }

    private func writeToHealthKit(start: Date, end: Date) async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        let mindfulType = HKCategoryType(.mindfulSession)

        do {
            try await store.requestAuthorization(
                toShare: [mindfulType],
                read: [mindfulType]
            )
            let sample = HKCategorySample(
                type: mindfulType,
                value: HKCategoryValue.notApplicable.rawValue,
                start: start,
                end: end
            )
            try await store.save(sample)
        } catch {
            // HealthKit not available or denied
        }
    }
}
