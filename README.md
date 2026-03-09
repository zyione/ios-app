# RemindMeInX

An iOS app that automatically schedules repeating alarms at a fixed interval until a set end time. Built with SwiftUI, distributed via AltStore.

## Features

- Set interval, start time, end time, and optional label
- Visual timeline preview of all scheduled alarms
- Alarms fire via iOS local notifications (works with phone locked)
- Built-in sound picker with preview
- Save and load presets
- Auto-fills last session on launch
- Dark mode UI

## Requirements

- iOS 16+
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating the Xcode project)

## Setup (macOS)

1. Install XcodeGen: `brew install xcodegen`
2. Clone this repo
3. Generate sound assets (see `IntervalAlarm/Resources/Sounds/README.md`)
4. Run `xcodegen generate` in the repo root
5. Open `IntervalAlarm.xcodeproj` in Xcode
6. Build and run on a device or simulator

## Building (No Mac Required)

This project uses **GitHub Actions** to build the `.ipa` on a cloud Mac automatically.

1. Push your code to GitHub
2. Go to **Actions** tab > **Build iOS App** workflow
3. The workflow runs automatically on every push (or click **Run workflow** to trigger manually)
4. Once the build completes, download the `IntervalAlarm-ipa` artifact from the workflow run
5. The `.ipa` file is inside the downloaded zip

You can also build locally on a Mac — see `Setup (macOS)` above.

## AltStore Installation

1. Download the `.ipa` from GitHub Actions (see above)
2. Install [AltServer](https://altstore.io) on your PC or Mac
3. Connect your iPhone via USB and trust the computer
4. Open AltStore on iPhone > My Apps > tap **+** > select the `.ipa` file
5. Re-sign every 7 days (AltStore handles this automatically when AltServer is running)

## Limitations

- iOS allows max 64 pending local notifications — the app warns and truncates if exceeded
- Silent mode override requires Apple's Critical Alerts entitlement (not available for sideloaded apps)
- Sound files must be under 30 seconds in .caf format

## Architecture

MVVM with a single `SessionManager` ObservableObject. See `docs/plans/` for the full implementation plan.
