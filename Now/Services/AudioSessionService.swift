import AVFoundation

final class AudioSessionService {
    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying = false
    private(set) var currentSound: AmbientSound?

    enum AmbientSound: String, CaseIterable, Identifiable {
        case rain = "rain"
        case wind = "wind"
        case silence = "silence"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .rain: return "Rain"
            case .wind: return "Wind"
            case .silence: return "Silence"
            }
        }
    }

    func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Audio session configuration failed; ambient sounds won't work
        }
    }

    func play(sound: AmbientSound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return
        }

        do {
            configureSession()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
            isPlaying = true
            currentSound = sound
        } catch {
            // Audio playback failed
        }
    }

    func stop() {
        audioPlayer?.setVolume(0, fadeDuration: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
            self?.isPlaying = false
            self?.currentSound = nil
        }
    }

    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
}
