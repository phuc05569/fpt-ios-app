import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .home
    @AppStorage(AppSettings.darkModeKey) private var darkMode = false   // off by default
    @Environment(\.studentService) private var service

    var body: some View {
        Group {
            switch tab {
            case .home:
                NavigationStack {
                    HomeView()
                }
                .tint(.white)   // white back chevron and label
            case .chat:
                NavigationStack {
                    MessagesView(service: service)
                }
                .tint(.white)
            case .profile:
                NavigationStack {   // its transparent bar sets the status bar style (see ProfileView)
                    ProfileView(service: service)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomTabBar(selection: $tab)
        }
        .preferredColorScheme(darkMode ? .dark : .light)   // the reference is light; dark is opt-in from Profile
    }
}

enum AppSettings {
    static let darkModeKey = "darkMode"
}
