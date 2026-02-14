import UIKit

@MainActor
final class ScreenDimmingService {
    private var originalBrightness: CGFloat = 0.5
    private var isDimmed = false
    private var brightnessTimer: Timer?

    func dim() {
        guard !isDimmed else { return }
        originalBrightness = UIScreen.main.brightness
        isDimmed = true
        UIApplication.shared.isIdleTimerDisabled = true
        animateBrightness(to: 0.1, duration: 2.0)
    }

    func restore() {
        guard isDimmed else { return }
        brightnessTimer?.invalidate()
        isDimmed = false
        UIApplication.shared.isIdleTimerDisabled = false
        animateBrightness(to: originalBrightness, duration: 0.5)
    }

    private func animateBrightness(to target: CGFloat, duration: TimeInterval) {
        brightnessTimer?.invalidate()

        let current = UIScreen.main.brightness
        let steps = Int(duration * 30)
        guard steps > 0 else {
            UIScreen.main.brightness = target
            return
        }
        let delta = (target - current) / CGFloat(steps)
        var step = 0

        brightnessTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { timer in
            step += 1
            UIScreen.main.brightness = current + delta * CGFloat(step)
            if step >= steps {
                timer.invalidate()
                UIScreen.main.brightness = target
            }
        }
    }
}
