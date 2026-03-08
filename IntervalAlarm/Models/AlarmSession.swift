import Foundation

struct AlarmSession: Codable {
    let startTime: Date
    let endTime: Date
    let intervalMinutes: Int
    let label: String?
    let soundName: String
    var alarms: [AlarmItem]
    let createdAt: Date

    init(
        startTime: Date,
        endTime: Date,
        intervalMinutes: Int,
        label: String?,
        soundName: String,
        alarms: [AlarmItem],
        createdAt: Date = Date()
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.intervalMinutes = intervalMinutes
        self.label = label
        self.soundName = soundName
        self.alarms = alarms
        self.createdAt = createdAt
    }
}
