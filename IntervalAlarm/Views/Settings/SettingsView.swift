import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionManager

    private let durationOptions = [30, 60, 90]

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

                Section {
                    Picker("Ring Duration", selection: Binding(
                        get: { session.alarmDuration },
                        set: { session.setAlarmDuration($0) }
                    )) {
                        Text("30s").tag(30)
                        Text("1 min").tag(60)
                        Text("90s").tag(90)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Max alarms per session")
                        Spacer()
                        Text("\(session.effectiveAlarmLimit)")
                            .foregroundStyle(.secondary)
                    }

                    Text("Each alarm rings for \(durationLabel(session.alarmDuration)). Longer ring times use more of the iOS 64-notification limit.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Alarm Duration")
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
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }

    private func durationLabel(_ seconds: Int) -> String {
        switch seconds {
        case 30: return "30 seconds"
        case 60: return "1 minute"
        case 90: return "90 seconds"
        default: return "\(seconds)s"
        }
    }
}
