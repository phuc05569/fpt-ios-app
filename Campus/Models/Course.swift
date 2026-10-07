import Foundation

/// A calendar date without a time zone, e.g. 2026-09-08. Used for course start/end dates.
struct CalendarDay: Hashable, Codable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(_ year: Int, _ month: Int, _ day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    /// dd/MM/yyyy, the format used in the reference screenshots.
    var formatted: String {
        String(format: "%02d/%02d/%04d", day, month, year)
    }
}

/// ISO numbering: Monday = 1 ... Sunday = 7.
enum Weekday: Int, CaseIterable, Hashable, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortName: String {
        switch self {
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        case .sunday: "Sun"
        }
    }
}

/// Teaching slots. Only slots 3 and 4 appear in the reference screenshots.
enum Slot: Int, Hashable, Codable {
    case three = 3
    case four = 4

    var startMinutes: Int {
        switch self {
        case .three: 12 * 60 + 30
        case .four: 15 * 60
        }
    }

    var endMinutes: Int {
        switch self {
        case .three: 14 * 60 + 45
        case .four: 17 * 60 + 15
        }
    }

    var startText: String { Self.text(startMinutes) }
    var endText: String { Self.text(endMinutes) }

    private static func text(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }
}

/// One recurring weekly meeting of a course.
struct Meeting: Hashable, Codable {
    let weekday: Weekday
    let slot: Slot
    let room: String
}

/// The single source of truth for a course. Timetable sessions, attendance and
/// marks are all derived from this, so names, rooms and lecturers cannot drift apart.
struct Course: Identifiable, Hashable, Codable {
    let code: String
    let name: String
    let className: String
    let lecturer: String
    let startDay: CalendarDay
    let endDay: CalendarDay
    let meetings: [Meeting]
    /// Days with no class (e.g. an exam week). Skipped when sessions are generated. Empty by default.
    var breakDays: [CalendarDay] = []
    /// SessionNo values the student missed. Each must be a session that has already finished;
    /// every other finished session counts as attended. Empty by default.
    /// Data rule (enforced by tests): at most 3, and attendance never below 80% at any moment,
    /// i.e. the k-th absence is session 5k or later.
    var absentSessions: [Int] = []
    /// Published final average. `nil` until the course is graded.
    let finalMark: Double?

    var id: String { "\(code)-\(className)" }
}
