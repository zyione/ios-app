import Foundation
import Combine

final class SessionManager: ObservableObject {
    @Published var currentSession: AlarmSession?
    @Published var setupForm: SetupFormState
    @Published var presets: [Preset]
    @Published var selectedSound: String
    @Published var overrideSilentMode: Bool
    @Published var alarmDuration: Int // seconds: 30, 60, or 90
    @Published var notificationPermissionGranted: Bool = false

    private let persistence = PersistenceManager.shared
    private let notifications = NotificationManager.shared

    /// Number of back-to-back notifications scheduled per alarm (each 30s long).
    var notificationsPerAlarm: Int {
        max(1, alarmDuration / 30)
    }

    /// Effective alarm limit accounting for repeated notifications.
    var effectiveAlarmLimit: Int {
        64 / notificationsPerAlarm
    }

    init() {
        let savedForm = PersistenceManager.shared.loadSetupForm()
        self.setupForm = savedForm ?? SetupFormState()
        self.presets = PersistenceManager.shared.loadPresets()
        self.selectedSound = PersistenceManager.shared.loadSelectedSound()
        self.overrideSilentMode = PersistenceManager.shared.loadOverrideSilentMode()
        self.alarmDuration = PersistenceManager.shared.loadAlarmDuration()

        // Recover active session if still valid
        if let session = PersistenceManager.shared.loadActiveSession(), session.endTime > Date() {
            self.currentSession = session
        } else {
            PersistenceManager.shared.clearActiveSession()
            self.currentSession = nil
        }

        // Check notification permission
        notifications.checkPermission { [weak self] granted in
            self?.notificationPermissionGranted = granted
        }
    }

    // MARK: - Alarm Generation

    func generateAlarms() -> [AlarmItem] {
        let start = setupForm.useCurrentTimeAsStart ? Date() : setupForm.startTime
        var end = setupForm.endTime
        let interval = TimeInterval(setupForm.intervalMinutes * 60)

        guard interval > 0 else { return [] }

        // If end is before or equal to start, assume next day
        if end <= start {
            end = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
        }

        var alarms: [AlarmItem] = []
        var nextFire = start.addingTimeInterval(interval)

        while nextFire <= end {
            let alarm = AlarmItem(
                fireDate: nextFire,
                label: setupForm.label.isEmpty ? nil : setupForm.label
            )
            alarms.append(alarm)
            nextFire = nextFire.addingTimeInterval(interval)
        }

        return alarms
    }

    var alarmCount: Int {
        generateAlarms().count
    }

    var exceedsLimit: Bool {
        alarmCount > effectiveAlarmLimit
    }

    // MARK: - Session Control

    func startSession() {
        var alarms = generateAlarms()
        let limit = effectiveAlarmLimit
        if alarms.count > limit {
            alarms = Array(alarms.prefix(limit))
        }

        guard !alarms.isEmpty else { return }

        let session = AlarmSession(
            startTime: setupForm.useCurrentTimeAsStart ? Date() : setupForm.startTime,
            endTime: setupForm.endTime,
            intervalMinutes: setupForm.intervalMinutes,
            label: setupForm.label.isEmpty ? nil : setupForm.label,
            soundName: selectedSound,
            alarms: alarms
        )

        notifications.scheduleAlarms(
            alarms,
            soundName: selectedSound,
            overrideSilentMode: overrideSilentMode,
            notificationsPerAlarm: notificationsPerAlarm
        )
        currentSession = session
        persistence.saveActiveSession(session)
        persistence.saveSetupForm(setupForm)
    }

    func stopSession() {
        notifications.cancelAllAlarms()
        currentSession = nil
        persistence.clearActiveSession()
    }

    // MARK: - Presets

    func savePreset(name: String) {
        let start = setupForm.startTime.hourAndMinute
        let end = setupForm.endTime.hourAndMinute

        let preset = Preset(
            name: name,
            intervalMinutes: setupForm.intervalMinutes,
            startHour: start.hour,
            startMinute: start.minute,
            endHour: end.hour,
            endMinute: end.minute,
            label: setupForm.label.isEmpty ? nil : setupForm.label,
            soundName: selectedSound
        )

        presets.append(preset)
        persistence.savePresets(presets)
    }

    func loadPreset(_ preset: Preset) {
        setupForm.intervalMinutes = preset.intervalMinutes
        setupForm.startTime = Date.todayAt(hour: preset.startHour, minute: preset.startMinute)
        setupForm.endTime = Date.todayAt(hour: preset.endHour, minute: preset.endMinute)
        setupForm.label = preset.label ?? ""
        setupForm.useCurrentTimeAsStart = false
        selectedSound = preset.soundName

        persistence.saveSetupForm(setupForm)
        persistence.saveSelectedSound(selectedSound)
    }

    func deletePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        persistence.savePresets(presets)
    }

    // MARK: - Sound

    func selectSound(_ name: String) {
        selectedSound = name
        persistence.saveSelectedSound(name)
    }

    // MARK: - Settings

    func setOverrideSilentMode(_ value: Bool) {
        overrideSilentMode = value
        persistence.saveOverrideSilentMode(value)
    }

    func setAlarmDuration(_ seconds: Int) {
        alarmDuration = seconds
        persistence.saveAlarmDuration(seconds)
    }

    // MARK: - Permissions

    func requestNotificationPermission() {
        notifications.requestPermission { [weak self] granted in
            self?.notificationPermissionGranted = granted
        }
    }

    // MARK: - Form Persistence

    func persistSetupForm() {
        persistence.saveSetupForm(setupForm)
    }
}
