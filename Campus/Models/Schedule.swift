import Foundation

enum SessionState {
    case upcoming
    case inProgress
    case completed
}

/// One dated occurrence of a course meeting, generated from the weekly pattern.
struct ClassSession: Identifiable, Hashable {
    let course: Course
    let meeting: Meeting
    let day: CalendarDay
    let number: Int       // SessionNo, counted from the course's first session
    let start: Date
    let end: Date

    var id: String { "\(course.id)-\(number)" }

    func state(at now: Date) -> SessionState {
        if now >= end { return .completed }
        if now >= start { return .inProgress }
        return .upcoming
    }

    /// Attendance rule: Present once the session has ended.
    /// Before it starts and while it is running the status stays "Not Yet".
    func isPresent(at now: Date) -> Bool {
        state(at: now) == .completed
    }

    /// Attendance report rule: the session has ended and the student was not marked absent.
    /// (`isPresent(at:)` stays purely time-based; the Weekly Timetable badge uses it.)
    func wasAttended(at now: Date) -> Bool {
        isPresent(at: now) && !course.absentSessions.contains(number)
    }
}

struct CourseAttendance: Identifiable, Hashable {
    let course: Course
    let attended: Int
    /// Sessions already finished. The reference app uses this as the denominator ("Attended: 5/8").
    let held: Int

    var id: String { course.id }
    var percent: Double { held == 0 ? 0 : Double(attended) / Double(held) * 100 }
}

/// All date/time logic lives here, in one fixed time zone (FPT HCMC), so results
/// do not depend on the device's time zone.
enum ScheduleCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        calendar.firstWeekday = 2
        return calendar
    }()

    // MARK: Dates

    static func date(of day: CalendarDay, minutes: Int = 0) -> Date {
        let midnight = calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day))
            ?? Date(timeIntervalSince1970: 0)
        return calendar.date(byAdding: .minute, value: minutes, to: midnight) ?? midnight
    }

    static func day(of date: Date) -> CalendarDay {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return CalendarDay(parts.year ?? 1970, parts.month ?? 1, parts.day ?? 1)
    }

    static func weekday(of day: CalendarDay) -> Weekday {
        let sundayFirst = calendar.component(.weekday, from: date(of: day))   // 1 = Sunday
        return Weekday(rawValue: (sundayFirst + 5) % 7 + 1) ?? .monday
    }

    static func adding(_ days: Int, to day: CalendarDay) -> CalendarDay {
        let start = date(of: day)
        return Self.day(of: calendar.date(byAdding: .day, value: days, to: start) ?? start)
    }

    /// Monday through Sunday of the week containing `day`.
    static func week(containing day: CalendarDay) -> [CalendarDay] {
        let monday = adding(-(weekday(of: day).rawValue - 1), to: day)
        return (0..<7).map { adding($0, to: monday) }
    }

    /// "October 2026"
    static func monthTitle(of day: CalendarDay) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date(of: day))
    }

    // MARK: Sessions

    /// Every session of a course: the weekly pattern repeated from the start date to the end date.
    static func sessions(of course: Course) -> [ClassSession] {
        var result: [ClassSession] = []
        var cursor = course.startDay
        while cursor <= course.endDay {
            let weekday = Self.weekday(of: cursor)
            let todays: [Meeting] = course.breakDays.contains(cursor)
                ? []
                : course.meetings
                    .filter { $0.weekday == weekday }
                    .sorted { $0.slot.rawValue < $1.slot.rawValue }
            for meeting in todays {
                result.append(ClassSession(
                    course: course,
                    meeting: meeting,
                    day: cursor,
                    number: result.count + 1,
                    start: date(of: cursor, minutes: meeting.slot.startMinutes),
                    end: date(of: cursor, minutes: meeting.slot.endMinutes)))
            }
            cursor = adding(1, to: cursor)
        }
        return result
    }

    /// Sessions falling on the given days, grouped by day and sorted by start time.
    static func sessions(of courses: [Course], in days: [CalendarDay]) -> [CalendarDay: [ClassSession]] {
        let wanted = Set(days)
        let matching = courses.flatMap { sessions(of: $0) }.filter { wanted.contains($0.day) }
        return Dictionary(grouping: matching, by: \.day)
            .mapValues { $0.sorted { $0.start < $1.start } }
    }

    // MARK: Attendance

    static func attendance(of course: Course, at now: Date) -> CourseAttendance {
        let all = sessions(of: course)
        let held = all.filter { $0.state(at: now) == .completed }.count
        let attended = all.filter { $0.wasAttended(at: now) }.count
        return CourseAttendance(course: course, attended: attended, held: held)
    }
}
