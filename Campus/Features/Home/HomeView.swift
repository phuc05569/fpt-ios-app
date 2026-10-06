import SwiftUI

/// Placeholder launcher: the Home screen is not implemented yet.
/// It only exists so the "Home" back button and navigation make sense.
struct HomeView: View {
    @Environment(\.studentService) private var service

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                row("Weekly timetable") { TimetableView(service: service) }
                row("Attendance report") { AttendanceView(service: service) }
                row("Mark Report") { MarkReportView(service: service) }
            }
            .padding(16)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Home")   // kept so pushed screens show "< Home"; the header below replaces the visible title
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear.frame(width: 1, height: 1)   // suppresses the centred inline title
            }
            ToolbarItem(placement: .topBarLeading) {
                HomeProfileHeader()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 19))
                    .foregroundStyle(Color.white)
                    .accessibilityLabel("Notifications")
            }
        }
    }

    private func row<Destination: View>(_ title: String,
                                        @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            ReportCard(accent: Theme.orange) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.navy)
            }
        }
        .buttonStyle(.plain)
    }
}
