import SwiftUI

/// Proportionate disclosure for screens that show sample (unverified) academic values and for the
/// Student ID card. Replaces the earlier full-width banners (user request) with a small subtitle under
/// the navigation title, which stays visible while scrolling and leaves the reference layout untouched.
enum DemoDisclosure {
    /// Marks, attendance and timetable: some values are sample data, not taken from the official app.
    static let sampleData = "Unofficial demo · includes sample data"
    /// Student ID card.
    static let notValidID = "Unofficial demo · not valid for identity verification"
}

extension View {
    /// Shows `title` with the sample-data subtitle in the navigation bar. Keep `navigationTitle` set as well
    /// (it still names the screen for back buttons and accessibility).
    func sampleDataTitle(_ title: String) -> some View {
        toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(title)
                        .font(.headline)   // 17pt semibold, the standard inline title
                        .foregroundStyle(Color.white)
                    Text(DemoDisclosure.sampleData)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
                .lineLimit(1)
                .accessibilityElement(children: .combine)
            }
        }
    }
}
