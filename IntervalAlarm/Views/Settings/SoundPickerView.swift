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
