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

    /// Schedule alarms with repeated notifications for extended ringing.
    /// - Parameters:
    ///   - alarms: The alarms to schedule.
    ///   - soundName: Sound file name (without extension) or "system_default".
    ///   - overrideSilentMode: Use critical alert sound.
    ///   - notificationsPerAlarm: Number of back-to-back notifications (each 30s apart) per alarm.
    func scheduleAlarms(
        _ alarms: [AlarmItem],
        soundName: String,
        overrideSilentMode: Bool,
        notificationsPerAlarm: Int = 1
    ) {
        let repeatCount = max(1, min(notificationsPerAlarm, 6))

        for alarm in alarms {
            for i in 0..<repeatCount {
                let content = UNMutableNotificationContent()
                content.title = "RemindMeInX"

                let timeString = alarm.fireDate.formatted12Hour()
                if let label = alarm.label, !label.isEmpty {
                    content.body = "\(timeString) \u{00B7} \(label)"
                } else {
                    content.body = timeString
                }

                // Determine sound
                if overrideSilentMode {
                    // Critical sound requires com.apple.developer.usernotifications.critical-alerts entitlement.
                    // Without it, falls back to regular sound. AltStore builds won't have this entitlement.
                    content.sound = .defaultCritical
                } else if soundName == SoundList.systemDefault {
                    content.sound = .default
                } else {
                    content.sound = UNNotificationSound(
                        named: UNNotificationSoundName(rawValue: "\(soundName).caf")
                    )
                }

                // Each sub-notification fires 30 seconds after the previous
                let fireDate = alarm.fireDate.addingTimeInterval(TimeInterval(i * 30))

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                // Unique ID for each sub-notification
                let identifier = repeatCount > 1
                    ? "\(alarm.id.uuidString)-\(i)"
                    : alarm.id.uuidString

                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )

                center.add(request)
            }
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
