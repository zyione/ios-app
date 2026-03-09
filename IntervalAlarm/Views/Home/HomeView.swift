import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            Group {
                if session.currentSession != nil {
                    ActiveSessionView()
                } else {
                    SetupView()
                }
            }
            .navigationTitle("RemindMeInX")
        }
    }
}
