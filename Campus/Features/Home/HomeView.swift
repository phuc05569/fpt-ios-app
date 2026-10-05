import SwiftUI

/// Placeholder launcher: the Home screen is not in the reference screenshots.
/// It only exists so the "Home" back button and navigation make sense.
struct HomeView: View {
    @Environment(\.studentService) private var service

    var body: some View {
        ScrollView {
            NavigationLink {
                MarkReportView(service: service)
            } label: {
                ReportCard(accent: Theme.orange) {
                    Text("Mark Report")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.navy)
                }
            }
            .buttonStyle(.plain)
            .padding(16)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
    }
}
