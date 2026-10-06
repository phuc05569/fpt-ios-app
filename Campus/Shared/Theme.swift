import SwiftUI

/// Values sampled from the reference screenshots (828x1792 @2x, iPhone 11 class).
/// Palette hex values match Tailwind's grays/red/green where the screenshot did.
enum Theme {
    static let navy = Color(hex: 0x1A2E4A)
    static let orange = Color(hex: 0xF39200)
    static let canvas = Color(hex: 0xF4F6F9)
    static let card = Color.white
    static let red = Color(hex: 0xEF4444)
    static let green = Color(hex: 0x10B981)      // "Passed": not visible in the Mark Report screenshot
    static let textSecondary = Color(hex: 0x6B7280)
    static let divider = Color(hex: 0xF3F4F6)
    static let chipBorder = Color(hex: 0xE5E7EB)
    static let chipIcon = Color(hex: 0x9CA3AF)
    static let tabIcon = Color(hex: 0x818C9B)
    static let tabSelected = Color(hex: 0x3A3D3F)

    // Timetable (sampled from the Weekly timetable screenshots)
    static let slotThree = Color(hex: 0xE06822)
    static let slotFour = Color(hex: 0x160BE0)
    static let statusGrey = Color(hex: 0x808080)      // "NOT YET" pill and the week-strip hairlines
    static let textTertiary = Color(hex: 0x9CA3AF)    // times and the "Room" label
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
}

extension View {
    /// Navy navigation bar with white title and back button (tint is set on the NavigationStack).
    func navyNavigationBar() -> some View {
        toolbarBackground(Theme.navy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
