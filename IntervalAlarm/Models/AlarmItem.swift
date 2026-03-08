import Foundation

struct AlarmItem: Codable, Identifiable {
    let id: UUID
    let fireDate: Date
    let label: String?
    var isFired: Bool

    init(id: UUID = UUID(), fireDate: Date, label: String? = nil, isFired: Bool = false) {
        self.id = id
        self.fireDate = fireDate
        self.label = label
        self.isFired = isFired
    }
}
