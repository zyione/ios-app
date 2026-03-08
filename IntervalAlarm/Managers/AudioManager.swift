import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?

    private init() {}

    func previewSound(_ name: String) {
        stopPreview()
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }

    func stopPreview() {
        player?.stop()
        player = nil
    }
}
