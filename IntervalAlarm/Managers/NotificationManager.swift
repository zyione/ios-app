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

    func scheduleAlarms(_ alarms: [AlarmItem], soundName: String, overrideSilentMode: Bool) {
        for alarm in alarms {
            let content = UNMutableNotificationContent()
            content.title = "RemindMeInX"

            let timeString = alarm.fireDate.formatted12Hour()
            if let label = alarm.label, !label.isEmpty {
                content.body = "\(timeString) \u{00B7} \(label)"
            } else {
                content.body = timeString
            }

            // Critical sound requires com.apple.developer.usernotifications.critical-alerts entitlement.
            // Without it, falls back to regular sound. AltStore builds won't have this entitlement.
            if overrideSilentMode {
                content.sound = .defaultCritical
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(soundName).caf"))
            }

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: alarm.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: trigger
            )

            center.add(request)
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
