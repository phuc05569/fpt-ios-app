import Foundation

struct CourseMark: Identifiable, Hashable, Codable {
    enum Status: String, Codable {
        case passed
        case notPassed
    }

    let courseCode: String
    let courseName: String
    let className: String
    let average: Double
    let status: Status

    var id: String { "\(courseCode)-\(className)" }
}
