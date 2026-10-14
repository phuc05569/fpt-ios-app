import SwiftUI

/// Empty state with soft background circles, shown on the Notification, Application status and Student Fee screens.
/// Measured from the references: horizontal positions scale with the container width (they match both the full-width
/// Notification screen and the 16pt-inset Student Fee screen); vertical positions and sizes are fixed in points.
struct DecoratedEmptyState<Icon: View>: View {
    let title: String
    let message: String
    @ViewBuilder let icon: Icon

    private static var circles: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color)] {
        [
            (0.097, 99.5, 180, Color(light: 0xECEFF5, dark: 0x1C2534)),
            (0.912, 124.5, 129.5, Color(light: 0xF9F4ED, dark: 0x2A2620)),
            (0.394, 205, 80, Color(light: 0xEBF2FB, dark: 0x1B2A3F)),
            (0.175, 32.5, 5.5, Color(light: 0xC6CCD6, dark: 0x3A4456)),
            (0.107, 122.5, 4.5, Color(light: 0xC6CCD6, dark: 0x3A4456)),
            (0.845, 56.5, 3.5, Color(light: 0xCCD2D9, dark: 0x3A4456)),
            (0.807, 103.5, 6.5, Color(light: 0xDEDCD9, dark: 0x3F3A33)),
        ]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Self.circles.indices, id: \.self) { i in
                    let c = Self.circles[i]
                    Circle()
                        .fill(c.color)
                        .frame(width: c.size, height: c.size)
                        .position(x: geo.size.width * c.x, y: c.y)
                }
                ZStack {
                    Circle()
                        .fill(Color(light: 0xE9EDF2, dark: 0x243044))
                        .frame(width: 103.5, height: 103.5)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    Circle()
                        .fill(Color(light: 0xD8E0EA, dark: 0x2E3B50))
                        .frame(width: 71.5, height: 71.5)
                    icon
                        .foregroundStyle(Color(hex: 0x94A3B8))
                }
                .position(x: geo.size.width / 2, y: 103.75)
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textStrong)
                    Text(message)
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.textTertiary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .frame(width: geo.size.width)
                .position(x: geo.size.width / 2, y: 197)
            }
        }
        .frame(height: 250)
        .clipped()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DecoratedEmptyState(title: "Showing 0 results", message: "Try searching with a different keyword.") {
        Image(systemName: "bell.fill").font(.system(size: 29))
    }
    .background(Theme.canvas)
}
