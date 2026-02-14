import UIKit

final class HapticService {
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    init() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
    }

    func playSessionStart(enabled: Bool) {
        guard enabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func playSessionEnd(enabled: Bool) {
        guard enabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    func playIntervalBell(enabled: Bool) {
        guard enabled else { return }
        impactGenerator.impactOccurred()
    }

    func prepare() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
    }
}
