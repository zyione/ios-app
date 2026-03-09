import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    private enum Keys {
        static let lastSetupForm = "lastSetupForm"
        static let activeSession = "activeSession"
        static let selectedSound = "selectedSound"
        static let overrideSilentMode = "overrideSilentMode"
        static let alarmDuration = "alarmDuration"
    }

    // MARK: - Setup Form (UserDefaults)

    func saveSetupForm(_ form: SetupFormState) {
        if let data = try? encoder.encode(form) {
            defaults.set(data, forKey: Keys.lastSetupForm)
        }
    }

    func loadSetupForm() -> SetupFormState? {
        guard let data = defaults.data(forKey: Keys.lastSetupForm) else { return nil }
        return try? decoder.decode(SetupFormState.self, from: data)
    }

    // MARK: - Active Session (UserDefaults)

    func saveActiveSession(_ session: AlarmSession) {
        if let data = try? encoder.encode(session) {
            defaults.set(data, forKey: Keys.activeSession)
        }
    }

    func loadActiveSession() -> AlarmSession? {
        guard let data = defaults.data(forKey: Keys.activeSession) else { return nil }
        return try? decoder.decode(AlarmSession.self, from: data)
    }

    func clearActiveSession() {
        defaults.removeObject(forKey: Keys.activeSession)
    }

    // MARK: - Sound Selection (UserDefaults)

    func saveSelectedSound(_ name: String) {
        defaults.set(name, forKey: Keys.selectedSound)
    }

    func loadSelectedSound() -> String {
        defaults.string(forKey: Keys.selectedSound) ?? SoundList.defaultSound
    }

    // MARK: - Silent Mode Override (UserDefaults)

    func saveOverrideSilentMode(_ value: Bool) {
        defaults.set(value, forKey: Keys.overrideSilentMode)
    }

    func loadOverrideSilentMode() -> Bool {
        // Default to false — critical alerts require Apple entitlement
        defaults.object(forKey: Keys.overrideSilentMode) as? Bool ?? false
    }

    // MARK: - Alarm Duration (UserDefaults)

    func saveAlarmDuration(_ seconds: Int) {
        defaults.set(seconds, forKey: Keys.alarmDuration)
    }

    func loadAlarmDuration() -> Int {
        // Default to 90 seconds (3 notifications × 30s each)
        defaults.object(forKey: Keys.alarmDuration) as? Int ?? 90
    }

    // MARK: - Presets (JSON file in Documents)

    private var presetsFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("presets.json")
    }

    func savePresets(_ presets: [Preset]) {
        if let data = try? encoder.encode(presets) {
            try? data.write(to: presetsFileURL, options: .atomic)
        }
    }

    func loadPresets() -> [Preset] {
        guard let data = try? Data(contentsOf: presetsFileURL) else { return [] }
        return (try? decoder.decode([Preset].self, from: data)) ?? []
    }
}
