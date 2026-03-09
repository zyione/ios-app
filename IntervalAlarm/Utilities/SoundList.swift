import Foundation

enum SoundList {
    static let defaultSound = "gentle_chime"

    /// Sound identifier for the iOS system default notification sound.
    static let systemDefault = "system_default"

    /// Sound identifier for user-provided iOS ringtone.
    static let iosRingtone = "ios_ringtone"

    static let all: [String] = [
        "system_default",
        "gentle_chime",
        "soft_bell",
        "morning_tone",
        "digital_beep",
        "classic_alarm",
        "pulse",
        "ripple",
        "ios_ringtone"
    ]

    static func displayName(for sound: String) -> String {
        switch sound {
        case "system_default":
            return "System Default"
        case "ios_ringtone":
            return "iOS Ringtone"
        default:
            return sound.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    /// Whether the sound is a bundled .caf file (as opposed to system default).
    static func isBundledSound(_ sound: String) -> Bool {
        sound != systemDefault
    }
}
