import Foundation

struct CourseMark: Identifiable, Hashable, Codable {
    enum Status: String, Codable {
        case passed
        case notPassed
        case exempted
    }

    let courseCode: String
    let courseName: String
    let className: String
    /// `nil` when no mark is recorded (e.g. an exempted course).
    let average: Double?
    let status: Status

    var id: String { "\(courseCode)-\(className)" }
}

extension CourseMark {
    /// Marks for a scheduled course come from the shared `Course` data,
    /// so the code, name and class always match the timetable and attendance.
    init(course: Course) {
        self.init(courseCode: course.code,
                  courseName: course.name,
                  className: course.className,
                  average: course.finalMark,
                  status: (course.finalMark ?? 0) >= 5 ? .passed : .notPassed)
    }
}
