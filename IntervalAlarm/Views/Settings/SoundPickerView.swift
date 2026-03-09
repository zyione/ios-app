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

                    // Toggle preview
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
                            .font(.title3)

                        Text(SoundList.displayName(for: sound))
                            .foregroundStyle(.primary)

                        Spacer()

                        // Preview indicator
                        if previewingSound == sound {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(AppTheme.accent)
                        } else {
                            Image(systemName: "speaker.wave.1")
                                .foregroundStyle(.secondary)
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
