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
