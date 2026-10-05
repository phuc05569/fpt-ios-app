import SwiftUI

/// White rounded card with a colored accent bar on the leading edge.
/// Measured from the screenshots: 4pt bar, 14pt padding, 15pt corner radius, no shadow.
struct ReportCard<Content: View>: View {
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.vertical, 14)
            .padding(.trailing, 14)
            .padding(.leading, 18)   // 4pt bar + 14pt padding
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .overlay(alignment: .leading) {
                accent.frame(width: 4)
            }
            .clipShape(.rect(cornerRadius: Theme.cardRadius))
    }
}
