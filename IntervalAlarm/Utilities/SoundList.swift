import Foundation

enum SoundList {
    static let defaultSound = "gentle_chime"

    static let all: [String] = [
        "gentle_chime",
        "soft_bell",
        "morning_tone",
        "digital_beep",
        "classic_alarm",
        "pulse",
        "ripple"
    ]

    static func displayName(for sound: String) -> String {
        sound.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
