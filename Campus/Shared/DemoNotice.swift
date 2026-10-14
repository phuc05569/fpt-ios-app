import SwiftUI

/// Disclosure shown on every screen with academic, identity or fee information. This app is an
/// unofficial demo and some marks and attendance values are sample data, so these screens must
/// never pass as official FPT records. Not dismissible on purpose; keep it on those screens.
struct DemoNotice: View {
    let text: String

    /// Marks, attendance and timetable: some values are sample data (not taken from the official app).
    static let sampleData = "Unofficial demo app · includes sample data, not official FPT records"
    /// Screens whose content was copied from the official app's screenshots.
    static let unofficial = "Unofficial demo app · not an official FPT record"
    /// Student ID card.
    static let notValidID = "Unofficial demo app · not valid for identity verification"

    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundStyle(Color(light: 0x92400E, dark: 0xFCD34D))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color(light: 0xFEF3C7, dark: 0x3B2F12), in: .rect(cornerRadius: 10))
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        DemoNotice(text: DemoNotice.sampleData)
        DemoNotice(text: DemoNotice.unofficial)
        DemoNotice(text: DemoNotice.notValidID)
    }
    .padding()
    .background(Theme.canvas)
}
