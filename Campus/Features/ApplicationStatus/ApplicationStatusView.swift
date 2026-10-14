import SwiftUI

/// Application status: the reference shows only the empty state.
/// shortcut: no application model or service call yet; add both when a screenshot with applications arrives.
struct ApplicationStatusView: View {
    var body: some View {
        ScrollView {
            DecoratedEmptyState(title: "Showing 0 results", message: "No applications have been submitted yet") {
                Image(systemName: "checklist").font(.system(size: 27, weight: .semibold))
            }
            .padding(.top, 0.5)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Application status")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
    }
}

#Preview {
    NavigationStack { ApplicationStatusView() }.tint(.white)
}
