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
