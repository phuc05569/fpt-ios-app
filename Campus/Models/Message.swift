import Foundation

/// A row of the Messages and Notification lists.
struct Message: Identifiable, Hashable {
    let id: Int
    let title: String
    let sender: String
    let body: String
    let day: CalendarDay

    /// "9 days ago", counted in whole calendar days in the school's time zone, as the reference does.
    func age(now: Date = .now) -> String {
        let today = ScheduleCalendar.date(of: ScheduleCalendar.day(of: now))
        let days = Int((today.timeIntervalSince(ScheduleCalendar.date(of: day)) / 86_400).rounded())
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "en_US")   // the reference app shows English relative dates
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter.localizedString(from: DateComponents(day: -days))
    }

    func matches(_ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespaces)
        return query.isEmpty || [title, sender, body].contains { $0.localizedStandardContains(query) }
    }
}
