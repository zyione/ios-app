import SwiftUI

@main
struct IntervalAlarmApp: App {
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
                .onAppear {
                    sessionManager.requestNotificationPermission()
                }
        }
    }
}
