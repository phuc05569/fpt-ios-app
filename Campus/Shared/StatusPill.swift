import SwiftUI

/// Capsule label: colored text on a 13% tint of the same color.
struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundStyle(color)
            .lineLimit(1)
            .padding(.horizontal, 11)
            .padding(.vertical, 3.5)
            .background(color.opacity(0.13), in: Capsule())
            .fixedSize()
    }
}
