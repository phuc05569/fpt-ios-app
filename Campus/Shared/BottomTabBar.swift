import SwiftUI

enum AppTab: CaseIterable {
    case home, chat, profile

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .chat: "message.fill"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .chat: "Chat"
        case .profile: "Profile"
        }
    }
}

/// Custom navy tab bar. Attach with `.safeAreaInset(edge: .bottom, spacing: 0)`.
///
/// In the screenshot the bar is 64pt tall on a 34pt-inset device and the 44pt selected
/// square starts 5pt below its top, so the square overlaps the home-indicator area.
/// The layout height is therefore 30pt (64 - 34); the navy background extends under
/// the safe area and the square overflows the 30pt frame on purpose.
/// Assumes a device with a bottom safe-area inset (anything with Face ID).
struct BottomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    Image(systemName: tab.symbolName)
                        .font(.system(size: 20))
                        .foregroundStyle(selection == tab ? Theme.orange : Theme.tabIcon)
                        .frame(width: 52, height: 44)
                        .background(selection == tab ? Theme.tabSelected : Color.clear,
                                    in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 5)
        .frame(height: 30, alignment: .top)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(Theme.navy)
                .shadow(color: .black.opacity(0.12), radius: 10, y: -4)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
