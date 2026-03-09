import SwiftUI

struct SoundPickerView: View {
    @EnvironmentObject var session: SessionManager
    @State private var previewingSound: String?

    var body: some View {
        List {
            ForEach(SoundList.all, id: \.self) { sound in
                Button {
                    // Select the sound immediately
                    session.selectSound(sound)

                    // Toggle preview (only for bundled sounds)
                    if SoundList.isBundledSound(sound) {
                        if previewingSound == sound {
                            AudioManager.shared.stopPreview()
                            previewingSound = nil
                        } else {
                            AudioManager.shared.previewSound(sound)
                            previewingSound = sound
                        }
                    } else {
                        // System default — can't preview, just stop any current preview
                        AudioManager.shared.stopPreview()
                        previewingSound = nil
                    }
                } label: {
                    HStack {
                        // Selected checkmark
                        Image(systemName: session.selectedSound == sound ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(session.selectedSound == sound ? AppTheme.accent : .secondary)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(SoundList.displayName(for: sound))
                                .foregroundStyle(.primary)

                            if sound == SoundList.systemDefault {
                                Text("Uses your iPhone notification sound")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if sound == SoundList.iosRingtone {
                                Text("Custom ringtone")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        // Preview indicator (only for bundled sounds)
                        if SoundList.isBundledSound(sound) {
                            if previewingSound == sound {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(AppTheme.accent)
                            } else {
                                Image(systemName: "speaker.wave.1")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Alarm Sound")
        .onDisappear {
            AudioManager.shared.stopPreview()
        }
    }
}
