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
