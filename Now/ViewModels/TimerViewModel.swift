import SwiftUI
import SwiftData
import Combine

@MainActor @Observable
final class TimerViewModel {
    let timerService = TimerService()
    let screenDimmingService = ScreenDimmingService()
    let hapticService = HapticService()
    let soundService = SoundService()
    let audioSessionService = AudioSessionService()

    private(set) var sessionStartDate: Date?
    private(set) var selectedDuration: Int = 480
    private(set) var showingCompletionAnimation = false

    // Interval bell tracking
    private var lastIntervalBellAt: Int = 0

    var state: TimerService.TimerState {
        timerService.state
    }

    var remainingSeconds: Int {
        timerService.remainingSeconds
    }

    var elapsedSeconds: Int {
        timerService.elapsedSeconds
    }

    var progress: Double {
        timerService.progress
    }

    var remainingFormatted: String {
        remainingSeconds.asMinutesSeconds
    }

    func selectDuration(_ seconds: Int) {
        selectedDuration = seconds
    }

    func startSession(
        settings: AppSettings,
        modelContext: ModelContext
    ) {
        sessionStartDate = Date()
        selectedDuration = settings.lastSelectedDuration

        hapticService.playSessionStart(enabled: settings.vibrationEnabled)
        soundService.playChime(enabled: settings.soundEnabled)
        screenDimmingService.dim()
        timerService.start(duration: selectedDuration)
        lastIntervalBellAt = 0
    }

    func startSessionWithDuration(
        _ duration: Int,
        settings: AppSettings,
        modelContext: ModelContext
    ) {
        sessionStartDate = Date()
        selectedDuration = duration
        settings.lastSelectedDuration = duration

        hapticService.playSessionStart(enabled: settings.vibrationEnabled)
        soundService.playChime(enabled: settings.soundEnabled)
        screenDimmingService.dim()
        timerService.start(duration: duration)
        lastIntervalBellAt = 0
    }

    func pauseSession() {
        timerService.pause()
    }

    func resumeSession() {
        timerService.resume()
    }

    func endSession(
        settings: AppSettings,
        modelContext: ModelContext,
        healthKitService: HealthKitService,
        streakService: StreakService
    ) async {
        let elapsed = timerService.stop()
        screenDimmingService.restore()
        hapticService.playSessionEnd(enabled: settings.vibrationEnabled)
        soundService.playChime(enabled: settings.soundEnabled)

        guard elapsed > 0, let startDate = sessionStartDate else { return }

        let endDate = startDate.addingTimeInterval(TimeInterval(elapsed))
        let session = MeditationSession(
            startDate: startDate,
            durationSeconds: selectedDuration,
            source: .iPhone
        )
        session.endDate = endDate
        session.actualDurationSeconds = elapsed
        session.completed = elapsed >= selectedDuration
        modelContext.insert(session)

        // Write to HealthKit
        if healthKitService.isAuthorized {
            do {
                try await healthKitService.saveMindfulSession(start: startDate, end: endDate)
                session.syncedToHealthKit = true
            } catch {
                // HealthKit write failed; session still saved locally
            }
        }

        // Update streak
        let todayMinutes = fetchTodayTotalMinutes(modelContext: modelContext)
        let goalMinutes = fetchGoalMinutes(modelContext: modelContext)
        streakService.updateTodayRecord(
            totalMinutes: todayMinutes,
            goalMinutes: goalMinutes,
            context: modelContext
        )

        showingCompletionAnimation = true
        sessionStartDate = nil
    }

    func handleCompletion(
        settings: AppSettings,
        modelContext: ModelContext,
        healthKitService: HealthKitService,
        streakService: StreakService
    ) async {
        screenDimmingService.restore()
        hapticService.playSessionEnd(enabled: settings.vibrationEnabled)
        soundService.playChime(enabled: settings.soundEnabled)

        guard let startDate = sessionStartDate else { return }

        let elapsed = selectedDuration
        let endDate = startDate.addingTimeInterval(TimeInterval(elapsed))
        let session = MeditationSession(
            startDate: startDate,
            durationSeconds: selectedDuration,
            source: .iPhone
        )
        session.endDate = endDate
        session.actualDurationSeconds = elapsed
        session.completed = true
        modelContext.insert(session)

        if healthKitService.isAuthorized {
            do {
                try await healthKitService.saveMindfulSession(start: startDate, end: endDate)
                session.syncedToHealthKit = true
            } catch {}
        }

        let todayMinutes = fetchTodayTotalMinutes(modelContext: modelContext)
        let goalMinutes = fetchGoalMinutes(modelContext: modelContext)
        streakService.updateTodayRecord(
            totalMinutes: todayMinutes,
            goalMinutes: goalMinutes,
            context: modelContext
        )

        showingCompletionAnimation = true
        sessionStartDate = nil
    }

    func dismissCompletion() {
        showingCompletionAnimation = false
    }

    func handleScenePhaseChange(isActive: Bool) {
        if isActive && state == .running {
            timerService.recalculateAfterBackground()
        }
        if !isActive && state == .running {
            screenDimmingService.restore()
        }
        if isActive && state == .running {
            screenDimmingService.dim()
        }
    }

    func checkIntervalBell(settings: AppSettings) {
        let interval = settings.intervalBellMinutes
        guard interval > 0 else { return }
        let intervalSeconds = interval * 60
        let currentInterval = elapsedSeconds / intervalSeconds
        if currentInterval > lastIntervalBellAt && elapsedSeconds > 0 {
            lastIntervalBellAt = currentInterval
            hapticService.playIntervalBell(enabled: settings.vibrationEnabled)
            soundService.playIntervalBell(enabled: settings.soundEnabled)
        }
    }

    private func fetchTodayTotalMinutes(modelContext: ModelContext) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<MeditationSession> { session in
            session.startDate >= startOfDay
        }
        let descriptor = FetchDescriptor<MeditationSession>(predicate: predicate)
        let sessions = (try? modelContext.fetch(descriptor)) ?? []
        return sessions.reduce(0) { $0 + $1.actualMinutes }
    }

    private func fetchGoalMinutes(modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<UserGoal>()
        let goals = (try? modelContext.fetch(descriptor)) ?? []
        return goals.first?.dailyGoalMinutes ?? 8
    }
}
