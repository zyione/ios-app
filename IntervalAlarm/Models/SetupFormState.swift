import Foundation

struct SetupFormState: Codable, Equatable {
    var intervalMinutes: Int = 5
    var startTime: Date = Date()
    var endTime: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    var label: String = ""
    var useCurrentTimeAsStart: Bool = true
}
