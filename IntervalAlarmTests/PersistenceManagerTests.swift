import XCTest
@testable import IntervalAlarm

final class PersistenceManagerTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "lastSetupForm")
        UserDefaults.standard.removeObject(forKey: "activeSession")
        UserDefaults.standard.removeObject(forKey: "selectedSound")
    }

    func testSetupFormRoundTrip() {
        let persistence = PersistenceManager.shared
        var form = SetupFormState()
        form.intervalMinutes = 10
        form.label = "Test"
        form.useCurrentTimeAsStart = false

        persistence.saveSetupForm(form)
        let loaded = persistence.loadSetupForm()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.intervalMinutes, 10)
        XCTAssertEqual(loaded?.label, "Test")
        XCTAssertEqual(loaded?.useCurrentTimeAsStart, false)
    }

    func testSelectedSoundPersistence() {
        let persistence = PersistenceManager.shared

        persistence.saveSelectedSound("classic_alarm")
        XCTAssertEqual(persistence.loadSelectedSound(), "classic_alarm")
    }

    func testSelectedSoundDefault() {
        let persistence = PersistenceManager.shared
        UserDefaults.standard.removeObject(forKey: "selectedSound")

        XCTAssertEqual(persistence.loadSelectedSound(), SoundList.defaultSound)
    }

    func testActiveSessionClear() {
        let persistence = PersistenceManager.shared
        let session = AlarmSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            intervalMinutes: 5,
            label: nil,
            soundName: "gentle_chime",
            alarms: []
        )

        persistence.saveActiveSession(session)
        XCTAssertNotNil(persistence.loadActiveSession())

        persistence.clearActiveSession()
        XCTAssertNil(persistence.loadActiveSession())
    }

    func testPresetsRoundTrip() {
        let persistence = PersistenceManager.shared
        let preset = Preset(
            name: "Test Preset",
            intervalMinutes: 10,
            startHour: 22,
            startMinute: 0,
            endHour: 6,
            endMinute: 0,
            soundName: "soft_bell"
        )

        persistence.savePresets([preset])
        let loaded = persistence.loadPresets()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Test Preset")
        XCTAssertEqual(loaded[0].intervalMinutes, 10)
        XCTAssertEqual(loaded[0].startHour, 22)
        XCTAssertEqual(loaded[0].endHour, 6)

        // Clean up presets file
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.removeItem(at: docs.appendingPathComponent("presets.json"))
    }
}
