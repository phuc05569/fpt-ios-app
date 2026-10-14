import SwiftUI

/// Values sampled from the reference screenshots (828x1792 @2x, iPhone 11 class).
/// Palette hex values match Tailwind's grays/red/green where the screenshot did.
/// Light values are the reference; dark values are our own (no dark reference yet), used when Dark Mode is on.
enum Theme {
    static let bar = Color(hex: 0x1A2E4A)                         // navigation bar, tab bar and navy cards: navy in both modes
    static let navy = Color(light: 0x1A2E4A, dark: 0xE5E7EB)      // navy text and tints
    static let orange = Color(hex: 0xF39200)
    static let canvas = Color(light: 0xF4F6F9, dark: 0x111827)
    static let card = Color(light: 0xFFFFFF, dark: 0x1F2937)
    static let subtle = Color(light: 0xF3F4F6, dark: 0x2B3544)    // icon tiles, info boxes, exam cards
    static let textStrong = Color(light: 0x374151, dark: 0xE5E7EB) // empty-state titles
    static let red = Color(hex: 0xEF4444)
    static let green = Color(hex: 0x10B981)      // "Passed": not visible in the Mark Report screenshot
    static let textSecondary = Color(light: 0x6B7280, dark: 0x9CA3AF)
    static let divider = Color(light: 0xF3F4F6, dark: 0x374151)
    static let chipBorder = Color(light: 0xE5E7EB, dark: 0x374151)
    static let chipIcon = Color(hex: 0x9CA3AF)
    static let tabIcon = Color(hex: 0x818C9B)
    static let tabSelected = Color(hex: 0x3A3D3F)

    // Timetable (sampled from the Weekly timetable screenshots)
    static let slotThree = Color(hex: 0xE06822)
    static let slotFour = Color(hex: 0x160BE0)
    static let statusGrey = Color(hex: 0x808080)      // "NOT YET" pill and the week-strip hairlines
    static let textTertiary = Color(light: 0x9CA3AF, dark: 0x8B95A5)   // times and the "Room" label
    static let headerSubtitle = Color(hex: 0x91A3BD)  // "FPT University" in the Home header (sampled)
    static let present = Color(hex: 0x059669)         // "PRESENT" pill: assumption, not visible in the screenshots

    static let cardRadius: CGFloat = 15
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }

    /// Follows the app's Dark Mode switch (RootView sets the color scheme).
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension View {
    /// Navy navigation bar with white title and back button (tint is set on the NavigationStack).
    func navyNavigationBar() -> some View {
        toolbarBackground(Theme.bar, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
