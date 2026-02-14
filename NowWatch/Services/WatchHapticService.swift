import WatchKit

final class WatchHapticService {
    func playSessionStart() {
        WKInterfaceDevice.current().play(.start)
    }

    func playSessionEnd() {
        WKInterfaceDevice.current().play(.success)
    }

    func playIntervalBell() {
        WKInterfaceDevice.current().play(.directionUp)
    }

    func playPause() {
        WKInterfaceDevice.current().play(.stop)
    }
}
