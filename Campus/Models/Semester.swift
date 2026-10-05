import Foundation

struct Semester: Identifiable, Hashable, Codable {
    let name: String   // e.g. "SUMMER2026"
    var id: String { name }
}
