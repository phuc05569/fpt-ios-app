import SwiftUI

/// White rounded card with a colored accent bar on the leading edge.
/// Measured from the screenshots: 4pt bar, 14pt padding, 15pt corner radius, no shadow.
struct ReportCard<Content: View>: View {
    let accent: Color
    var verticalPadding: CGFloat = 14
    var leadingPadding: CGFloat = 14   // inside the bar; the Messages rows use 10
    var trailingPadding: CGFloat = 14
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.vertical, verticalPadding)
            .padding(.trailing, trailingPadding)
            .padding(.leading, 4 + leadingPadding)   // 4pt bar + padding
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .overlay(alignment: .leading) {
                accent.frame(width: 4)
            }
            .clipShape(.rect(cornerRadius: Theme.cardRadius))
    }
}
