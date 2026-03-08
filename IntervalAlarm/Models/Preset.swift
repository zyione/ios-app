import Foundation

struct Preset: Codable, Identifiable {
    let id: UUID
    var name: String
    var intervalMinutes: Int
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var label: String?
    var soundName: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        intervalMinutes: Int,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        label: String? = nil,
        soundName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.intervalMinutes = intervalMinutes
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.label = label
        self.soundName = soundName
        self.createdAt = createdAt
    }
}
