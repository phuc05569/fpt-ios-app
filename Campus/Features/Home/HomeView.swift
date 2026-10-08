import SwiftUI

/// Home menu: three titled sections of two-column tiles, as in the Home reference screenshot.
/// Tiles for screens that exist push them; the others open a neutral "not available yet" screen.
struct HomeView: View {
    @Environment(\.studentService) private var service

    private let columns = [
        GridItem(.flexible(), spacing: HomeMenuMetrics.gap),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HomeMenuMetrics.sectionSpacing) {
                ForEach(HomeMenuSection.all) { section in
                    VStack(alignment: .leading, spacing: HomeMenuMetrics.titleToCards) {
                        HomeSectionTitle(title: section.title)
                        LazyVGrid(columns: columns, spacing: HomeMenuMetrics.gap) {
                            ForEach(section.items) { item in
                                NavigationLink {
                                    destination(for: item)
                                } label: {
                                    HomeMenuTile(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.leading, HomeMenuMetrics.leadingInset)
            .padding(.trailing, HomeMenuMetrics.trailingInset)
            .padding(.top, HomeMenuMetrics.topPadding)
            .padding(.bottom, HomeMenuMetrics.sectionSpacing)
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

    @ViewBuilder
    private func destination(for item: HomeMenuItem) -> some View {
        switch item.destination {
        case .timetable: TimetableView(service: service)
        case .attendance: AttendanceView(service: service)
        case .marks: MarkReportView(service: service)
        case .unavailable: HomeUnavailableView(title: item.title)
        }
    }
}
