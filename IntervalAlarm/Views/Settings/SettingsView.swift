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
