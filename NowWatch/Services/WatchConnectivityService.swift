import WatchConnectivity
import Foundation

@Observable
final class WatchPhoneConnectivityService: NSObject, WCSessionDelegate {
    private var session: WCSession?
    var onGoalUpdate: ((Int, Int, Double) -> Void)?

    func activate() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    func sendSession(_ payload: SessionSyncPayload) {
        guard let session, session.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        session.transferUserInfo(["sessionSync": data])
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        if let data = applicationContext["goalUpdate"] as? Data,
           let payload = try? JSONDecoder().decode(GoalSyncPayload.self, from: data) {
            DispatchQueue.main.async {
                self.onGoalUpdate?(
                    payload.dailyGoalMinutes,
                    payload.currentStreak,
                    payload.todayMinutes
                )
            }
        }

        if let goalMinutes = applicationContext["goalMinutes"] as? Int {
            DispatchQueue.main.async {
                self.onGoalUpdate?(goalMinutes, 0, 0)
            }
        }
    }
}
