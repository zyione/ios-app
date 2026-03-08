import XCTest
@testable import IntervalAlarm

final class AlarmGenerationTests: XCTestCase {

    func testBasicAlarmGeneration() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 15)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()

        // 5, 10, 15 = 3 alarms
        XCTAssertEqual(alarms.count, 3)
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[0].fireDate), 5
        )
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[1].fireDate), 10
        )
        XCTAssertEqual(
            Calendar.current.component(.minute, from: alarms[2].fireDate), 15
        )
    }

    func testNoAlarmsWhenIntervalExceedsDuration() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 3)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()
        XCTAssertEqual(alarms.count, 0)
    }

    func testOvernightSession() {
        let manager = SessionManager()
        // 11 PM start, 1 AM end (next day)
        let start = Date.todayAt(hour: 23, minute: 0)
        let end = Date.todayAt(hour: 1, minute: 0) // This is "earlier" — should wrap to next day

        manager.setupForm.intervalMinutes = 30
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        let alarms = manager.generateAlarms()

        // 23:30, 0:00, 0:30, 1:00 = 4 alarms
        XCTAssertEqual(alarms.count, 4)
    }

    func testLabelPropagation() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 10)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false
        manager.setupForm.label = "Wake up"

        let alarms = manager.generateAlarms()
        XCTAssertEqual(alarms[0].label, "Wake up")
        XCTAssertEqual(alarms[1].label, "Wake up")
    }

    func testEmptyLabelBecomesNil() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 0, minute: 10)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false
        manager.setupForm.label = ""

        let alarms = manager.generateAlarms()
        XCTAssertNil(alarms[0].label)
    }

    func testExceedsLimitFlag() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 23, minute: 59)

        manager.setupForm.intervalMinutes = 1
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        XCTAssertTrue(manager.exceedsLimit)
    }

    func testAlarmCountWithinLimit() {
        let manager = SessionManager()
        let start = Date.todayAt(hour: 0, minute: 0)
        let end = Date.todayAt(hour: 1, minute: 0)

        manager.setupForm.intervalMinutes = 5
        manager.setupForm.startTime = start
        manager.setupForm.endTime = end
        manager.setupForm.useCurrentTimeAsStart = false

        XCTAssertFalse(manager.exceedsLimit)
        XCTAssertEqual(manager.alarmCount, 12)
    }
}
