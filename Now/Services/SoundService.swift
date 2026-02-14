import AudioToolbox
import AVFoundation

final class SoundService {
    private var chimeSound: SystemSoundID = 0
    private var hasCustomSound = false

    init() {
        if let url = Bundle.main.url(forResource: "chime", withExtension: "caf") {
            AudioServicesCreateSystemSoundID(url as CFURL, &chimeSound)
            hasCustomSound = true
        }
    }

    deinit {
        if hasCustomSound {
            AudioServicesDisposeSystemSoundID(chimeSound)
        }
    }

    func playChime(enabled: Bool) {
        guard enabled else { return }
        if hasCustomSound {
            AudioServicesPlaySystemSound(chimeSound)
        } else {
            AudioServicesPlaySystemSound(1013)
        }
    }

    func playIntervalBell(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1057)
    }
}
