import SwiftUI

// MARK: - Model

/// Where a Home menu tile leads. Only screens that already exist are wired to real views;
/// the rest open a neutral "not available yet" screen instead of showing invented data.
enum HomeDestination: Equatable {
    case timetable, attendance, marks, unavailable
}

enum HomeGlyph: Equatable {
    case bell, contactBook, calendar, newspaper, calendarGrid, checklist, barChart, cashRegister
}

struct HomeMenuItem: Identifiable, Equatable {
    let title: String
    let glyph: HomeGlyph
    let tile: Color
    let accent: Color
    let destination: HomeDestination
    var id: String { title }
}

struct HomeMenuSection: Identifiable, Equatable {
    let title: String
    let items: [HomeMenuItem]
    var id: String { title }
}

extension HomeMenuSection {
    /// Tile and glyph colours sampled from the Home reference screenshot.
    /// The label of the last Reports card is hidden behind the tab bar in the reference;
    /// the user confirmed it is "Student Fee".
    static let all: [HomeMenuSection] = [
        HomeMenuSection(title: "NOTIFICATION AND APPLICATION STATUS", items: [
            HomeMenuItem(title: "Notification", glyph: .bell,
                         tile: Color(hex: 0xFFF3E0), accent: Theme.orange, destination: .unavailable),
            HomeMenuItem(title: "Application status", glyph: .contactBook,
                         tile: Color(hex: 0xE8F0FE), accent: Color(hex: 0x1668B2), destination: .unavailable),
        ]),
        HomeMenuSection(title: "INFORMATION ACCESS", items: [
            HomeMenuItem(title: "Weekly timetable", glyph: .calendar,
                         tile: Color(hex: 0xE0F2FE), accent: Color(hex: 0x0EA5E9), destination: .timetable),
            HomeMenuItem(title: "Exam schedule", glyph: .newspaper,
                         tile: Color(hex: 0xFEE2E2), accent: Theme.red, destination: .unavailable),
            HomeMenuItem(title: "Semester Schedule", glyph: .calendarGrid,
                         tile: Color(hex: 0xEDE9FE), accent: Color(hex: 0x8B5CF6), destination: .unavailable),
        ]),
        HomeMenuSection(title: "REPORTS", items: [
            HomeMenuItem(title: "Attendance report", glyph: .checklist,
                         tile: Color(hex: 0xD1FAE5), accent: Theme.green, destination: .attendance),
            HomeMenuItem(title: "Mark Report", glyph: .barChart,
                         tile: Color(hex: 0xFEF3C7), accent: Color(hex: 0xF59E0B), destination: .marks),
            HomeMenuItem(title: "Student Fee", glyph: .cashRegister,
                         tile: Color(hex: 0xFEE2E2), accent: Theme.red, destination: .unavailable),
        ]),
    ]
}

// MARK: - Metrics

/// Measured from the reference (828x1792 px = 414x896 pt, so 1pt = 2px).
enum HomeMenuMetrics {
    static let leadingInset: CGFloat = 16      // card edge at x = 32px
    static let trailingInset: CGFloat = 24.5   // card edge at x = 779px (the reference is asymmetric)
    static let gap: CGFloat = 8.5              // 17px between cards, both directions
    static let cardHeight: CGFloat = 122.5     // 245px
    static let cardRadius: CGFloat = 16        // ~32px
    static let tileSize: CGFloat = 55.5        // 111px
    static let tileRadius: CGFloat = 16
    static let tileTopPadding: CGFloat = 20    // 40px
    static let tileToLabel: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
    static let titleToCards: CGFloat = 14
    static let titleInset: CGFloat = 14        // title starts at x = 60px
    static let topPadding: CGFloat = 27.5
}

// MARK: - Views

struct HomeSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(Theme.navy)
            .padding(.leading, HomeMenuMetrics.titleInset)
            .accessibilityAddTraits(.isHeader)
    }
}

struct HomeMenuTile: View {
    let item: HomeMenuItem

    var body: some View {
        VStack(spacing: HomeMenuMetrics.tileToLabel) {
            RoundedRectangle(cornerRadius: HomeMenuMetrics.tileRadius, style: .continuous)
                .fill(item.tile)
                .frame(width: HomeMenuMetrics.tileSize, height: HomeMenuMetrics.tileSize)
                .overlay {
                    HomeGlyphView(glyph: item.glyph, accent: item.accent, tile: item.tile)
                }
            Text(item.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.navy)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.top, HomeMenuMetrics.tileTopPadding)
        .frame(maxWidth: .infinity, minHeight: HomeMenuMetrics.cardHeight,
               maxHeight: HomeMenuMetrics.cardHeight, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: HomeMenuMetrics.cardRadius, style: .continuous)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .contentShape(.rect(cornerRadius: HomeMenuMetrics.cardRadius))
        .accessibilityElement(children: .combine)
    }
}

/// Shown for menu items whose screen does not exist yet (not in the reference screenshots).
struct HomeUnavailableView: View {
    let title: String

    var body: some View {
        Text("\(title) is not available yet.")
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navyNavigationBar()
    }
}

// MARK: - Glyphs
// The reference uses solid Font Awesome style icons. SF Symbols are used where a close match exists
// (bell, newspaper, checklist); the others are drawn so the shapes match the reference.

struct HomeGlyphView: View {
    let glyph: HomeGlyph
    let accent: Color
    let tile: Color

    var body: some View {
        switch glyph {
        case .bell:
            Image(systemName: "bell.fill").font(.system(size: 26)).foregroundStyle(accent)
        case .newspaper:
            Image(systemName: "newspaper.fill").font(.system(size: 25)).foregroundStyle(accent)
        case .checklist:
            Image(systemName: "checklist").font(.system(size: 25, weight: .bold)).foregroundStyle(accent)
        case .contactBook:
            ContactBookGlyph(accent: accent, tile: tile)
        case .calendar:
            CalendarGlyph(accent: accent, tile: tile, grid: false)
        case .calendarGrid:
            CalendarGlyph(accent: accent, tile: tile, grid: true)
        case .barChart:
            BarChartGlyph(accent: accent, tile: tile)
        case .cashRegister:
            CashRegisterGlyph(accent: accent, tile: tile)
        }
    }
}

private struct ContactBookGlyph: View {
    let accent: Color
    let tile: Color

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accent)
                .frame(width: 20, height: 26)
                .overlay {
                    VStack(spacing: 2) {
                        Circle().fill(tile).frame(width: 7, height: 7)
                        UnevenRoundedRectangle(topLeadingRadius: 5, bottomLeadingRadius: 1,
                                               bottomTrailingRadius: 1, topTrailingRadius: 5)
                            .fill(tile)
                            .frame(width: 11, height: 5)
                    }
                }
            VStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule().fill(accent).frame(width: 3, height: 3)
                }
            }
        }
    }
}

private struct CalendarGlyph: View {
    let accent: Color
    let tile: Color
    let grid: Bool

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accent)
                .frame(width: 23, height: 22)
                .padding(.top, 4)
            HStack(spacing: 8) {
                Capsule().fill(accent).frame(width: 3, height: 7)
                Capsule().fill(accent).frame(width: 3, height: 7)
            }
            Rectangle().fill(tile.opacity(0.7)).frame(width: 23, height: 1.5).padding(.top, 10)
            if grid {
                VStack(spacing: 3) {
                    ForEach(0..<2, id: \.self) { _ in
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1).fill(tile).frame(width: 4, height: 4)
                            }
                        }
                    }
                }
                .padding(.top, 14)
            } else {
                RoundedRectangle(cornerRadius: 1).fill(tile)
                    .frame(width: 6, height: 6)
                    .frame(width: 23, alignment: .leading)
                    .padding(.leading, 4)
                    .padding(.top, 15)
            }
        }
        .frame(width: 23, height: 26)
    }
}

private struct BarChartGlyph: View {
    let accent: Color
    let tile: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(accent)
            .frame(width: 23, height: 23)
            .overlay {
                HStack(alignment: .bottom, spacing: 2.5) {
                    RoundedRectangle(cornerRadius: 1).fill(tile).frame(width: 3.5, height: 8)
                    RoundedRectangle(cornerRadius: 1).fill(tile).frame(width: 3.5, height: 14)
                    RoundedRectangle(cornerRadius: 1).fill(tile).frame(width: 3.5, height: 6)
                }
                .frame(height: 15, alignment: .bottom)
            }
    }
}

private struct CashRegisterGlyph: View {
    let accent: Color
    let tile: Color

    var body: some View {
        VStack(spacing: 1) {
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(accent)
                .frame(width: 12, height: 6)
                .overlay { Rectangle().fill(tile).frame(width: 7, height: 1.5) }
            Rectangle().fill(accent).frame(width: 2.5, height: 3)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accent)
                .frame(width: 26, height: 15)
                .overlay {
                    VStack(spacing: 2.5) {
                        ForEach(0..<2, id: \.self) { _ in
                            HStack(spacing: 2.5) {
                                ForEach(0..<4, id: \.self) { _ in
                                    Circle().fill(tile).frame(width: 2.5, height: 2.5)
                                }
                            }
                        }
                        Capsule().fill(tile).frame(width: 9, height: 1.5)
                    }
                }
        }
    }
}
