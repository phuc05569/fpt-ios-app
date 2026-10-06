import SwiftUI

/// Leading part of the Home navigation bar: the FPT mascot tile, the student's name and the university.
/// Geometry measured from the Home reference screenshot (725px wide = 1.751 px/pt):
/// 39pt tile with ~9pt corner radius, 8pt gap, 17.5pt bold name, 11pt subtitle 1pt below.
struct HomeProfileHeader: View {
    static let name = "Vũ Hoàng Phúc"
    static let university = "FPT University"

    var body: some View {
        HStack(spacing: 8) {
            // FPT.png is drawn whole, scaled to the tile; its near-white background forms the tile, as in the reference.
            Image("FPTAvatar")
                .resizable()
                .scaledToFit()
                .frame(width: 39, height: 39)
                .clipShape(.rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 1) {
                Text(Self.name)
                    .font(.system(size: 17.5, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(Self.university)
                    .font(.system(size: 11))
                    .tracking(0.3)
                    .foregroundStyle(Theme.headerSubtitle)
                    .lineLimit(1)
            }
        }
        .padding(.leading, -4)   // the reference tile sits 12pt from the edge; toolbar items start at 16pt
        .accessibilityElement(children: .combine)
    }
}
