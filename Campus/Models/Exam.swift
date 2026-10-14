import Foundation

/// One card of the Exam schedule. Every field is copied from the reference screenshots;
/// an empty string is a field that is blank in the reference (e.g. "Room:" with no room).
struct Exam: Hashable {
    let day: CalendarDay
    let subject: String
    let room: String
    let time: String
    let type: String
    let status: String   // "Đã thi"

    /// "30/6/2026": the reference shows exam dates without leading zeros.
    var dateText: String { "\(day.day)/\(day.month)/\(day.year)" }
}
