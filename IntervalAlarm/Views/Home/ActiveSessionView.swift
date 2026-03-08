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
