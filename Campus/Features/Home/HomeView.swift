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
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
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
