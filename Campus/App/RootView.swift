import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .home

    var body: some View {
        Group {
            switch tab {
            case .home:
                NavigationStack {
                    HomeView()
                }
                .tint(.white)   // white back chevron and label
            case .chat:
                PlaceholderView(title: "Chat")
            case .profile:
                PlaceholderView(title: "Profile")
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomTabBar(selection: $tab)
        }
        .preferredColorScheme(.light)   // the reference design is light-only
    }
}

/// Chat and Profile are not in the reference screenshots.
private struct PlaceholderView: View {
    let title: String

    var body: some View {
        Text(title)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.canvas.ignoresSafeArea())
    }
}
