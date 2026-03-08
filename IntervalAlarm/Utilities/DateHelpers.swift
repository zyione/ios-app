import Foundation

extension Date {
    /// Formats date as "12:05 AM"
    func formatted12Hour() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    /// Formats date as "12:05"
    func formattedShortTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: self)
    }

    /// Returns just the hour and minute components
    var hourAndMinute: (hour: Int, minute: Int) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0, comps.minute ?? 0)
    }

    /// Creates a Date for today at the given hour and minute
    static func todayAt(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
}

extension TimeInterval {
    /// Formats seconds into "Xh Ym" or "Ym Zs"
    func formattedCountdown() -> String {
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
