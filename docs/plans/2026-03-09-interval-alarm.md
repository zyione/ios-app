# Interval Alarm iOS App — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a complete iOS app that schedules repeating interval alarms via local notifications, with preset saving, sound selection, and a polished dark-mode UI. Distributed via AltStore.

**Architecture:** MVVM with a single `SessionManager` ObservableObject injected into the SwiftUI environment. All alarms are pre-scheduled upfront using `UNUserNotificationCenter` local notifications — no background processing needed. Persistence uses UserDefaults for last session/settings and a JSON file for presets.

**Tech Stack:** Swift 5.9+, SwiftUI, UserNotifications, AVFoundation, XcodeGen for project generation, iOS 16+

**Platform Note:** Development happens on Windows. Swift cannot be compiled here. All steps marked with a Mac icon (🍎) require a Mac with Xcode to verify. Sound `.caf` assets must be created on Mac.

**Commit Strategy:** Micro-commits after every task. Use conventional commit messages.

---

## Project Structure

```
ios-timer/                              (repo root)
├── project.yml                         (XcodeGen project spec)
├── .gitignore
├── README.md
├── docs/
│   └── plans/
│       └── 2026-03-09-interval-alarm.md
├── IntervalAlarm/
│   ├── App/
│   │   ├── IntervalAlarmApp.swift
│   │   └── ContentView.swift
│   ├── Models/
│   │   ├── AlarmItem.swift
│   │   ├── AlarmSession.swift
│   │   ├── Preset.swift
│   │   └── SetupFormState.swift
│   ├── Managers/
│   │   ├── SessionManager.swift
│   │   ├── NotificationManager.swift
│   │   ├── PersistenceManager.swift
│   │   └── AudioManager.swift
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   ├── SetupView.swift
│   │   │   ├── TimelinePreviewView.swift
│   │   │   └── ActiveSessionView.swift
│   │   ├── Presets/
│   │   │   └── PresetListView.swift
│   │   └── Settings/
│   │       ├── SettingsView.swift
│   │       └── SoundPickerView.swift
│   ├── Resources/
│   │   └── Sounds/
│   │       └── (placeholder — .caf files added on Mac)
│   ├── Utilities/
│   │   ├── DateHelpers.swift
│   │   └── SoundList.swift
│   ├── Theme/
│   │   └── AppTheme.swift
│   └── Info.plist
└── IntervalAlarmTests/
    ├── SessionManagerTests.swift
    ├── AlarmGenerationTests.swift
    └── PersistenceManagerTests.swift
```

---

### Task 1: Project Scaffolding

**Files:**
- Create: `.gitignore`
- Create: `project.yml`
- Create: all directories (empty)

**Step 1: Initialize git repo**

```bash
cd "/c/Users/Neo/Desktop/DLSU/Python Apps/ios-timer"
git init
```

**Step 2: Create .gitignore**

```gitignore
# Xcode
*.xcodeproj/
*.xcworkspace/
build/
DerivedData/
*.dSYM/
*.ipa
*.xcuserdata/
xcuserdata/

# Swift Package Manager
.build/
Packages/
.swiftpm/

# macOS
.DS_Store
*.swp
*~

# Generated
*.hmap
*.pch

# CocoaPods (if ever used)
Pods/
```

**Step 3: Create XcodeGen project spec**

Create `project.yml`:

```yaml
name: IntervalAlarm
options:
  bundleIdPrefix: com.intervalalarm
  deploymentTarget:
    iOS: "16.0"
  xcodeVersion: "15.0"
settings:
  base:
    SWIFT_VERSION: "5.9"
    TARGETED_DEVICE_FAMILY: 1
    GENERATE_INFOPLIST_FILE: false
targets:
  IntervalAlarm:
    type: application
    platform: iOS
    sources:
      - path: IntervalAlarm
        excludes:
          - Resources/Sounds/.gitkeep
    resources:
      - path: IntervalAlarm/Resources/Sounds
        excludes:
          - .gitkeep
    settings:
      base:
        INFOPLIST_FILE: IntervalAlarm/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.intervalalarm.app
        DEVELOPMENT_TEAM: ""
  IntervalAlarmTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: IntervalAlarmTests
    dependencies:
      - target: IntervalAlarm
    settings:
      base:
        GENERATE_INFOPLIST_FILE: true
```

**Step 4: Create directory structure**

```bash
mkdir -p IntervalAlarm/{App,Models,Managers,Views/{Home,Presets,Settings},Resources/Sounds,Utilities,Theme}
mkdir -p IntervalAlarmTests
touch IntervalAlarm/Resources/Sounds/.gitkeep
```

**Step 5: Create Info.plist**

Create `IntervalAlarm/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Interval Alarm</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UIUserInterfaceStyle</key>
    <string>Dark</string>
</dict>
</plist>
```

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: scaffold project structure with XcodeGen spec and Info.plist"
```

---

### Task 2: Data Models

**Files:**
- Create: `IntervalAlarm/Models/AlarmItem.swift`
- Create: `IntervalAlarm/Models/AlarmSession.swift`
- Create: `IntervalAlarm/Models/Preset.swift`
- Create: `IntervalAlarm/Models/SetupFormState.swift`

**Step 1: Create AlarmItem model**

```swift
import Foundation

struct AlarmItem: Codable, Identifiable {
    let id: UUID
    let fireDate: Date
    let label: String?
    var isFired: Bool

    init(id: UUID = UUID(), fireDate: Date, label: String? = nil, isFired: Bool = false) {
        self.id = id
        self.fireDate = fireDate
        self.label = label
        self.isFired = isFired
    }
}
```

**Step 2: Create AlarmSession model**

```swift
import Foundation

struct AlarmSession: Codable {
    let startTime: Date
    let endTime: Date
    let intervalMinutes: Int
    let label: String?
    let soundName: String
    var alarms: [AlarmItem]
    let createdAt: Date

    init(
        startTime: Date,
        endTime: Date,
        intervalMinutes: Int,
        label: String?,
        soundName: String,
        alarms: [AlarmItem],
        createdAt: Date = Date()
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.intervalMinutes = intervalMinutes
        self.label = label
        self.soundName = soundName
        self.alarms = alarms
        self.createdAt = createdAt
    }
}
```

**Step 3: Create Preset model**

```swift
import Foundation

struct Preset: Codable, Identifiable {
    let id: UUID
    var name: String
    var intervalMinutes: Int
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var label: String?
    var soundName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        intervalMinutes: Int,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        label: String? = nil,
        soundName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.intervalMinutes = intervalMinutes
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.label = label
        self.soundName = soundName
        self.createdAt = createdAt
    }
}
```

**Step 4: Create SetupFormState model**

```swift
import Foundation

struct SetupFormState: Codable, Equatable {
    var intervalMinutes: Int = 5
    var startTime: Date = Date()
    var endTime: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    var label: String = ""
    var useCurrentTimeAsStart: Bool = true
}
```

**Step 5: Commit**

```bash
git add IntervalAlarm/Models/
git commit -m "feat: add data models — AlarmItem, AlarmSession, Preset, SetupFormState"
```

---

### Task 3: Utilities — DateHelpers & SoundList

**Files:**
- Create: `IntervalAlarm/Utilities/DateHelpers.swift`
- Create: `IntervalAlarm/Utilities/SoundList.swift`

**Step 1: Create DateHelpers**

```swift
import Foundation

extension Date {
    /// Formats date as "12:05 AM"
    func formatted12Hour() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    /// Formats date as "12:05"
    func formattedShortTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: self)
    }

    /// Returns just the hour and minute components
    var hourAndMinute: (hour: Int, minute: Int) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0, comps.minute ?? 0)
    }

    /// Creates a Date for today at the given hour and minute
    static func todayAt(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
}

extension TimeInterval {
    /// Formats seconds into "Xh Ym" or "Ym Zs"
    func formattedCountdown() -> String {
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
```

**Step 2: Create SoundList**

```swift
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
```

**Step 3: Commit**

```bash
git add IntervalAlarm/Utilities/
git commit -m "feat: add DateHelpers extensions and SoundList constants"
```

---

### Task 4: PersistenceManager

**Files:**
- Create: `IntervalAlarm/Managers/PersistenceManager.swift`

**Step 1: Create PersistenceManager**

```swift
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
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Managers/PersistenceManager.swift
git commit -m "feat: add PersistenceManager — UserDefaults + JSON file persistence"
```

---

### Task 5: NotificationManager

**Files:**
- Create: `IntervalAlarm/Managers/NotificationManager.swift`

**Step 1: Create NotificationManager**

```swift
import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func checkPermission(completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    func scheduleAlarms(_ alarms: [AlarmItem], soundName: String, overrideSilentMode: Bool) {
        for alarm in alarms {
            let content = UNMutableNotificationContent()
            content.title = "Interval Alarm"

            let timeString = alarm.fireDate.formatted12Hour()
            if let label = alarm.label, !label.isEmpty {
                content.body = "\(timeString) \u{00B7} \(label)"
            } else {
                content.body = timeString
            }

            // Critical sound requires com.apple.developer.usernotifications.critical-alerts entitlement.
            // Without it, falls back to regular sound. AltStore builds won't have this entitlement.
            if overrideSilentMode {
                content.sound = .defaultCritical
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).caf"))
            }

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: alarm.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    func cancelAllAlarms() {
        center.removeAllPendingNotificationRequests()
    }

    func pendingAlarmCount(completion: @escaping (Int) -> Void) {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Managers/NotificationManager.swift
git commit -m "feat: add NotificationManager — wraps UNUserNotificationCenter for scheduling"
```

---

### Task 6: AudioManager

**Files:**
- Create: `IntervalAlarm/Managers/AudioManager.swift`

**Step 1: Create AudioManager**

```swift
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
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Managers/AudioManager.swift
git commit -m "feat: add AudioManager — AVAudioPlayer wrapper for sound preview"
```

---

### Task 7: SessionManager (Core Business Logic)

**Files:**
- Create: `IntervalAlarm/Managers/SessionManager.swift`

**Step 1: Create SessionManager**

This is the central ObservableObject. All views read/write through this.

```swift
import Foundation
import Combine

final class SessionManager: ObservableObject {
    @Published var currentSession: AlarmSession?
    @Published var setupForm: SetupFormState
    @Published var presets: [Preset]
    @Published var selectedSound: String
    @Published var overrideSilentMode: Bool
    @Published var notificationPermissionGranted: Bool = false

    private let persistence = PersistenceManager.shared
    private let notifications = NotificationManager.shared

    init() {
        let savedForm = PersistenceManager.shared.loadSetupForm()
        self.setupForm = savedForm ?? SetupFormState()
        self.presets = PersistenceManager.shared.loadPresets()
        self.selectedSound = PersistenceManager.shared.loadSelectedSound()
        self.overrideSilentMode = PersistenceManager.shared.loadOverrideSilentMode()

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
        alarmCount > 64
    }

    // MARK: - Session Control

    func startSession() {
        var alarms = generateAlarms()
        if alarms.count > 64 {
            alarms = Array(alarms.prefix(64))
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

        notifications.scheduleAlarms(alarms, soundName: selectedSound, overrideSilentMode: overrideSilentMode)
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
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Managers/SessionManager.swift
git commit -m "feat: add SessionManager — core MVVM ObservableObject with alarm generation, session control, and presets"
```

---

### Task 8: Theme & App Shell

**Files:**
- Create: `IntervalAlarm/Theme/AppTheme.swift`
- Create: `IntervalAlarm/App/IntervalAlarmApp.swift`
- Create: `IntervalAlarm/App/ContentView.swift`
- Create: `IntervalAlarm/Views/Home/HomeView.swift`

**Step 1: Create AppTheme**

```swift
import SwiftUI

enum AppTheme {
    static let accent = Color(red: 1.0, green: 0.67, blue: 0.25) // Warm amber #FFAB40
    static let accentSoft = Color(red: 1.0, green: 0.67, blue: 0.25).opacity(0.15)
    static let cardBackground = Color(.systemGray6)
    static let destructive = Color.red
}
```

**Step 2: Create IntervalAlarmApp entry point**

```swift
import SwiftUI

@main
struct IntervalAlarmApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
                .onAppear {
                    sessionManager.requestNotificationPermission()
                }
        }
    }
}
```

**Step 3: Create ContentView with tab bar**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "clock.fill")
                }

            PresetListView()
                .tabItem {
                    Label("Presets", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
```

**Step 4: Create HomeView (switches between setup and active session)**

```swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            Group {
                if session.currentSession != nil {
                    ActiveSessionView()
                } else {
                    SetupView()
                }
            }
            .navigationTitle("Interval Alarm")
        }
    }
}
```

**Step 5: Commit**

```bash
git add IntervalAlarm/Theme/ IntervalAlarm/App/ IntervalAlarm/Views/Home/HomeView.swift
git commit -m "feat: add app entry point, tab navigation, theme, and HomeView shell"
```

---

### Task 9: SetupView

**Files:**
- Create: `IntervalAlarm/Views/Home/SetupView.swift`

**Step 1: Create SetupView**

```swift
import SwiftUI

struct SetupView: View {
    @EnvironmentObject var session: SessionManager
    @State private var showSavePresetAlert = false
    @State private var presetName = ""

    private var alarms: [AlarmItem] {
        session.generateAlarms()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Notification warning
                if !session.notificationPermissionGranted {
                    notificationBanner
                }

                // Interval picker
                inputCard(title: "Interval") {
                    Stepper(
                        "\(session.setupForm.intervalMinutes) min",
                        value: $session.setupForm.intervalMinutes,
                        in: 1...120
                    )
                    .font(.title3.monospacedDigit())
                }

                // Start time
                inputCard(title: "Start Time") {
                    Toggle("Use current time", isOn: $session.setupForm.useCurrentTimeAsStart)
                        .font(.subheadline)

                    if !session.setupForm.useCurrentTimeAsStart {
                        DatePicker(
                            "",
                            selection: $session.setupForm.startTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 120)
                        .clipped()
                    }
                }

                // End time
                inputCard(title: "End Time") {
                    DatePicker(
                        "",
                        selection: $session.setupForm.endTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 120)
                    .clipped()
                }

                // Label
                inputCard(title: "Label (optional)") {
                    TextField("e.g. Wake up, Check in", text: $session.setupForm.label)
                        .textFieldStyle(.roundedBorder)
                }

                // Sound selector
                NavigationLink {
                    SoundPickerView()
                } label: {
                    HStack {
                        Text("Sound")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(SoundList.displayName(for: session.selectedSound))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                // Timeline preview
                TimelinePreviewView(alarms: alarms)

                // 64-alarm warning
                if session.exceedsLimit {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text("iOS limits to 64 notifications. Only the first 64 alarms will fire.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }

                // Start button
                Button {
                    session.startSession()
                } label: {
                    Text("Start Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(alarms.isEmpty ? Color.gray : AppTheme.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
                .disabled(alarms.isEmpty)

                // Save as preset
                Button {
                    showSavePresetAlert = true
                } label: {
                    Text("Save as Preset")
                        .font(.subheadline)
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .onChange(of: session.setupForm) { _ in
            session.persistSetupForm()
        }
        .alert("Save Preset", isPresented: $showSavePresetAlert) {
            TextField("Preset name", text: $presetName)
            Button("Save") {
                guard !presetName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                session.savePreset(name: presetName.trimmingCharacters(in: .whitespaces))
                presetName = ""
            }
            Button("Cancel", role: .cancel) { presetName = "" }
        } message: {
            Text("Enter a name for this preset")
        }
    }

    // MARK: - Subviews

    private var notificationBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(.red)
            Text("Notifications disabled. Alarms won't fire.")
                .font(.caption)
            Spacer()
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption.bold())
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }

    private func inputCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Views/Home/SetupView.swift
git commit -m "feat: add SetupView — main alarm configuration form with inputs, sound selector, and preset saving"
```

---

### Task 10: TimelinePreviewView

**Files:**
- Create: `IntervalAlarm/Views/Home/TimelinePreviewView.swift`

**Step 1: Create TimelinePreviewView**

```swift
import SwiftUI

struct TimelinePreviewView: View {
    let alarms: [AlarmItem]

    @State private var selectedAlarm: AlarmItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Timeline")
                    .font(.headline)
                Spacer()
                Text("\(alarms.count) alarm\(alarms.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if alarms.isEmpty {
                Text("No alarms to schedule")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                // Timeline bar
                timelineBar

                // Start / End labels
                if let first = alarms.first, let last = alarms.last {
                    HStack {
                        Text(first.fireDate.formatted12Hour())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(last.fireDate.formatted12Hour())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Selected alarm detail
                if let selected = selectedAlarm {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(AppTheme.accent)
                        Text(selected.fireDate.formatted12Hour())
                            .font(.subheadline.bold())
                        if let label = selected.label {
                            Text("· \(label)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(8)
                    .background(AppTheme.accentSoft)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }

    private var timelineBar: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(height: 4)

                // Alarm dots
                ForEach(alarms) { alarm in
                    let position = dotPosition(for: alarm, in: width)
                    Circle()
                        .fill(selectedAlarm?.id == alarm.id ? AppTheme.accent : AppTheme.accent.opacity(0.6))
                        .frame(width: selectedAlarm?.id == alarm.id ? 12 : 8,
                               height: selectedAlarm?.id == alarm.id ? 12 : 8)
                        .offset(x: position - 4)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedAlarm = alarm
                            }
                        }
                }
            }
        }
        .frame(height: 20)
    }

    private func dotPosition(for alarm: AlarmItem, in totalWidth: CGFloat) -> CGFloat {
        guard let first = alarms.first, let last = alarms.last else { return 0 }
        let totalDuration = last.fireDate.timeIntervalSince(first.fireDate)
        guard totalDuration > 0 else { return totalWidth / 2 }
        let offset = alarm.fireDate.timeIntervalSince(first.fireDate)
        return CGFloat(offset / totalDuration) * totalWidth
    }
}
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Views/Home/TimelinePreviewView.swift
git commit -m "feat: add TimelinePreviewView — visual timeline bar with tappable alarm dots"
```

---

### Task 11: ActiveSessionView

**Files:**
- Create: `IntervalAlarm/Views/Home/ActiveSessionView.swift`

**Step 1: Create ActiveSessionView**

```swift
import SwiftUI

struct ActiveSessionView: View {
    @EnvironmentObject var session: SessionManager
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var nextAlarm: AlarmItem? {
        session.currentSession?.alarms.first { $0.fireDate > now }
    }

    private var remainingAlarms: [AlarmItem] {
        session.currentSession?.alarms.filter { $0.fireDate > now } ?? []
    }

    private var firedAlarms: [AlarmItem] {
        session.currentSession?.alarms.filter { $0.fireDate <= now } ?? []
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Next alarm countdown
            if let next = nextAlarm {
                VStack(spacing: 8) {
                    Text("Next Alarm")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(next.fireDate.formatted12Hour())
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("in \(next.fireDate.timeIntervalSince(now).formattedCountdown())")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accent)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("All alarms have fired")
                        .font(.title3)
                }
            }

            // Session info
            if let currentSession = session.currentSession {
                VStack(spacing: 4) {
                    if let label = currentSession.label {
                        Text(label)
                            .font(.headline)
                    }
                    Text("Every \(currentSession.intervalMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(firedAlarms.count)/\(currentSession.alarms.count) fired")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Progress ring
            if let currentSession = session.currentSession {
                let progress = Double(firedAlarms.count) / Double(max(currentSession.alarms.count, 1))
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                }
                .frame(width: 80, height: 80)
            }

            Spacer()

            // Remaining alarms list (scrollable)
            if !remainingAlarms.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(remainingAlarms.prefix(20)) { alarm in
                                Text(alarm.fireDate.formattedShortTime())
                                    .font(.caption.monospacedDigit())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.accentSoft)
                                    .cornerRadius(8)
                            }
                            if remainingAlarms.count > 20 {
                                Text("+\(remainingAlarms.count - 20) more")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Stop All button
            Button(role: .destructive) {
                session.stopSession()
            } label: {
                Text("Stop All")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.destructive)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onReceive(timer) { tick in
            now = tick

            // Auto-clear session when all alarms have fired
            if let currentSession = session.currentSession, currentSession.endTime < now {
                session.stopSession()
            }
        }
    }
}
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Views/Home/ActiveSessionView.swift
git commit -m "feat: add ActiveSessionView — countdown display, progress ring, and stop-all button"
```

---

### Task 12: PresetListView

**Files:**
- Create: `IntervalAlarm/Views/Presets/PresetListView.swift`

**Step 1: Create PresetListView**

```swift
import SwiftUI

struct PresetListView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            Group {
                if session.presets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No saved presets")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Save a session configuration from the Home tab to create a preset.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(session.presets) { preset in
                            Button {
                                session.loadPreset(preset)
                            } label: {
                                presetRow(preset)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                session.deletePreset(session.presets[index])
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Presets")
        }
    }

    private func presetRow(_ preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(preset.name)
                .font(.headline)

            HStack(spacing: 12) {
                Label("\(preset.intervalMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                let startStr = String(format: "%d:%02d", preset.startHour, preset.startMinute)
                let endStr = String(format: "%d:%02d", preset.endHour, preset.endMinute)
                Text("\(startStr) \u{2192} \(endStr)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if let label = preset.label, !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Views/Presets/PresetListView.swift
git commit -m "feat: add PresetListView — saved presets with tap-to-load and swipe-to-delete"
```

---

### Task 13: SettingsView & SoundPickerView

**Files:**
- Create: `IntervalAlarm/Views/Settings/SettingsView.swift`
- Create: `IntervalAlarm/Views/Settings/SoundPickerView.swift`

**Step 1: Create SettingsView**

```swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            List {
                Section("Sound") {
                    NavigationLink {
                        SoundPickerView()
                    } label: {
                        HStack {
                            Text("Alarm Sound")
                            Spacer()
                            Text(SoundList.displayName(for: session.selectedSound))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Notifications") {
                    Toggle("Override Silent Mode", isOn: Binding(
                        get: { session.overrideSilentMode },
                        set: { session.setOverrideSilentMode($0) }
                    ))

                    Text("Uses critical alerts to play sound even in silent mode. Requires special entitlement from Apple — may not work with AltStore builds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("iOS Notification Limit")
                        Spacer()
                        Text("64 per session")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}
```

**Step 2: Create SoundPickerView**

```swift
import SwiftUI

struct SoundPickerView: View {
    @EnvironmentObject var session: SessionManager
    @State private var previewingSound: String?

    var body: some View {
        List {
            ForEach(SoundList.all, id: \.self) { sound in
                Button {
                    // Preview the sound
                    if previewingSound == sound {
                        AudioManager.shared.stopPreview()
                        previewingSound = nil
                    } else {
                        AudioManager.shared.previewSound(sound)
                        previewingSound = sound
                    }
                } label: {
                    HStack {
                        // Selected checkmark
                        Image(systemName: session.selectedSound == sound ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(session.selectedSound == sound ? AppTheme.accent : .secondary)

                        Text(SoundList.displayName(for: sound))
                            .foregroundStyle(.primary)

                        Spacer()

                        // Preview indicator
                        if previewingSound == sound {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(AppTheme.accent)
                                .font(.caption)
                        } else {
                            Image(systemName: "speaker.wave.1")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Alarm Sound")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let previewing = previewingSound {
                        session.selectSound(previewing)
                    }
                    AudioManager.shared.stopPreview()
                }
            }
        }
        .onDisappear {
            AudioManager.shared.stopPreview()
        }
    }
}
```

**Step 3: Commit**

```bash
git add IntervalAlarm/Views/Settings/
git commit -m "feat: add SettingsView and SoundPickerView — sound selection with preview, silent mode toggle"
```

---

### Task 14: Sound Assets & Placeholder Setup

**Files:**
- Create: `IntervalAlarm/Resources/Sounds/README.md`

**Step 1: Create sound assets README**

The actual `.caf` sound files must be created on a Mac. This README documents the process.

Create `IntervalAlarm/Resources/Sounds/README.md`:

```markdown
# Sound Assets

These .caf files must be created on macOS before building the app.

## Required files

- gentle_chime.caf
- soft_bell.caf
- morning_tone.caf
- digital_beep.caf
- classic_alarm.caf
- pulse.caf
- ripple.caf

## How to create placeholder sounds on Mac

Use `afconvert` to convert any .wav or .mp3 to .caf:

    afconvert input.wav output.caf -d LEI16 -f caff

Or generate simple tones with `sox` (install via `brew install sox`):

    sox -n gentle_chime.caf synth 2 sine 880 fade 0 2 1.5
    sox -n soft_bell.caf synth 1.5 sine 1046.5 fade 0 1.5 1
    sox -n morning_tone.caf synth 2 sine 659.25 fade 0 2 1.5
    sox -n digital_beep.caf synth 0.5 square 1000 fade 0 0.5 0.3
    sox -n classic_alarm.caf synth 3 sine 440:880 fade 0 3 0.5
    sox -n pulse.caf synth 1 sine 523.25 sine 659.25 fade 0 1 0.5
    sox -n ripple.caf synth 2.5 pluck 440 fade 0 2.5 2

## Notification sound constraints

- Maximum 30 seconds
- Supported formats: .caf, .wav, .aiff
- Must be in app bundle (not on-demand resources)
```

**Step 2: Commit**

```bash
git add IntervalAlarm/Resources/Sounds/
git commit -m "docs: add sound assets README with macOS generation instructions"
```

---

### Task 15: Unit Tests

**Files:**
- Create: `IntervalAlarmTests/AlarmGenerationTests.swift`
- Create: `IntervalAlarmTests/PersistenceManagerTests.swift`

**Step 1: Create AlarmGenerationTests**

These test the core alarm generation logic. 🍎 Run on Mac with `cmd+U` in Xcode.

```swift
import XCTest
@testable import IntervalAlarm

final class AlarmGenerationTests: XCTestCase {

    func testBasicAlarmGeneration() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 15)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()

        // 5, 10, 15 = 3 alarms
        XCTAssertEqual(alarms.count, 3)
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[0].fireDate), 5
        )
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[1].fireDate), 10
        )
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[2].fireDate), 15
        )
    }

    func testNoAlarmsWhenIntervalExceedsDuration() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 3)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()
        XCTAssertEqual(alarms.count, 0)
    }

    func testOvernightSession() {
        let manager = SessionManager()
        // 11 PM start, 1 AM end (next day)
        let start = Date.todayAt(hour: 23, minute: 0)
        let end = Date.todayAt(hour: 1, minute: 0) // This is "earlier" — should wrap to next day

        manager.setupForm.intervalMinutes = 30
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()

        // 23:30, 0:00, 0:30, 1:00 = 4 alarms
        XCTAssertEqual(alarms.count, 4)
    }

    func testLabelPropagation() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 10)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false
        manager.setupForm.label = "Wake up"

        let alarms = manager.generateAlarms()
        XCTAssertEqual(alarms[0].label, "Wake up")
        XCTAssertEqual(alarms[1].label, "Wake up")
    }

    func testEmptyLabelBecomesNil() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 10)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false
        manager.setupForm.label = ""

        let alarms = manager.generateAlarms()
        XCTAssertNil(alarms[0].label)
    }

    func testExceedsLimitFlag() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 23, minute: 59)

        manager.setupForm.intervalMinutes = 1
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        XCTAssertTrue(manager.exceedsLimit)
    }

    func testAlarmCountWithinLimit() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 1, minute: 0)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        XCTAssertFalse(manager.exceedsLimit)
        XCTAssertEqual(manager.alarmCount, 12)
    }
}
```

**Step 2: Create PersistenceManagerTests**

```swift
import XCTest
@testable import IntervalAlarm

final class PersistenceManagerTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "lastSetupForm")
        UserDefaults.standard.removeObject(forKey: "activeSession")
        UserDefaults.standard.removeObject(forKey: "selectedSound")
    }

    func testSetupFormRoundTrip() {
        let persistence = PersistenceManager.shared
        var form = SetupFormState()
        form.intervalMinutes = 10
        form.label = "Test"
        form.useCurrentTimeAsStart = false

        persistence.saveSetupForm(form)
        let loaded = persistence.loadSetupForm()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.intervalMinutes, 10)
        XCTAssertEqual(loaded?.label, "Test")
        XCTAssertEqual(loaded?.useCurrentTimeAsStart, false)
    }

    func testSelectedSoundPersistence() {
        let persistence = PersistenceManager.shared

        persistence.saveSelectedSound("classic_alarm")
        XCTAssertEqual(persistence.loadSelectedSound(), "classic_alarm")
    }

    func testSelectedSoundDefault() {
        let persistence = PersistenceManager.shared
        UserDefaults.standard.removeObject(forKey: "selectedSound")

        XCTAssertEqual(persistence.loadSelectedSound(), SoundList.defaultSound)
    }

    func testActiveSessionClear() {
        let persistence = PersistenceManager.shared
        let session = AlarmSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            intervalMinutes: 5,
            label: nil,
            soundName: "gentle_chime",
            alarms: []
        )

        persistence.saveActiveSession(session)
        XCTAssertNotNil(persistence.loadActiveSession())

        persistence.clearActiveSession()
        XCTAssertNil(persistence.loadActiveSession())
    }

    func testPresetsRoundTrip() {
        let persistence = PersistenceManager.shared
        let preset = Preset(
            name: "Test Preset",
            intervalMinutes: 10,
            startHour: 22,
            startMinute: 0,
            endHour: 6,
            endMinute: 0,
            soundName: "soft_bell"
        )

        persistence.savePresets([preset])
        let loaded = persistence.loadPresets()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Test Preset")
        XCTAssertEqual(loaded[0].intervalMinutes, 10)
        XCTAssertEqual(loaded[0].startHour, 22)
        XCTAssertEqual(loaded[0].endHour, 6)

        // Clean up presets file
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.removeItem(at: docs.appendingPathComponent("presets.json"))
    }
}
```

**Step 3: Commit**

```bash
git add IntervalAlarmTests/
git commit -m "test: add unit tests for alarm generation logic and persistence manager"
```

---

### Task 16: README

**Files:**
- Create: `README.md`

**Step 1: Create README**

```markdown
# Interval Alarm

An iOS app that automatically schedules repeating alarms at a fixed interval until a set end time. Built with SwiftUI, distributed via AltStore.

## Features

- Set interval, start time, end time, and optional label
- Visual timeline preview of all scheduled alarms
- Alarms fire via iOS local notifications (works with phone locked)
- Built-in sound picker with preview
- Save and load presets
- Auto-fills last session on launch
- Dark mode UI

## Requirements

- iOS 16+
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project)

## Setup (macOS)

1. Install XcodeGen: `brew install xcodegen`
2. Clone this repo
3. Generate sound assets (see `IntervalAlarm/Resources/Sounds/README.md`)
4. Run `xcodegen generate` in the repo root
5. Open `IntervalAlarm.xcodeproj` in Xcode
6. Build and run on a device or simulator

## AltStore Installation

1. Build the app in Xcode (Product > Archive > Export as .ipa)
2. Install [AltServer](https://altstore.io) on your PC or Mac
3. Connect your iPhone via USB
4. Open AltStore on iPhone > My Apps > tap + > select the .ipa
5. Re-sign every 7 days (AltStore handles this automatically)

## Limitations

- iOS allows max 64 pending local notifications — the app warns and truncates if exceeded
- Silent mode override requires Apple's Critical Alerts entitlement (not available for sideloaded apps)
- Sound files must be under 30 seconds in .caf format

## Architecture

MVVM with a single `SessionManager` ObservableObject. See `docs/plans/` for the full implementation plan.
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add project README with setup and AltStore installation instructions"
```

---

## Verification Checklist (🍎 Mac Required)

After all tasks are committed and the repo is cloned on a Mac:

1. [ ] Run `xcodegen generate` — project opens in Xcode without errors
2. [ ] Generate sound .caf files per `IntervalAlarm/Resources/Sounds/README.md`
3. [ ] Build succeeds on iOS 16 simulator
4. [ ] Run unit tests (Cmd+U) — all pass
5. [ ] Launch app — HomeTab shows SetupView with default values
6. [ ] Configure a 1-minute interval, start a session — alarms fire on schedule
7. [ ] Stop All cancels remaining notifications
8. [ ] Save a preset, switch to Presets tab, tap to load — form pre-fills
9. [ ] Kill and relaunch app — last session state is restored
10. [ ] Build .ipa and sideload via AltStore on a real device
