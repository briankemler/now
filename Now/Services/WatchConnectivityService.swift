import WatchConnectivity
import SwiftData
import Foundation

@Observable
final class PhoneConnectivityService: NSObject, WCSessionDelegate {
    private var session: WCSession?
    private(set) var isReachable = false
    var onSessionReceived: ((SessionSyncPayload) -> Void)?

    func activate() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    func sendGoalUpdate(_ payload: GoalSyncPayload) {
        guard let session, session.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? session.updateApplicationContext(["goalUpdate": data])
    }

    func sendSettingsUpdate(goalMinutes: Int) {
        guard let session, session.activationState == .activated else { return }
        try? session.updateApplicationContext(["goalMinutes": goalMinutes])
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        if let data = userInfo["sessionSync"] as? Data,
           let payload = try? JSONDecoder().decode(SessionSyncPayload.self, from: data) {
            DispatchQueue.main.async {
                self.onSessionReceived?(payload)
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
