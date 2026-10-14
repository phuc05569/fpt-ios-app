import Foundation

struct StudentProfile: Hashable {
    let name: String
    let badge: String        // the green pill under the name ("HD" in the reference)
    let rollNumber: String
    let email: String
    let campus: String

    var maskedRollNumber: String { Self.mask(rollNumber) }

    var maskedEmail: String {
        guard let at = email.firstIndex(of: "@") else { return Self.mask(email) }
        return Self.mask(String(email[..<at])) + String(email[at...])
    }

    /// "SE211094" -> "SE2***094": first three and last three characters, as the reference masks them.
    static func mask(_ text: String) -> String {
        guard text.count > 6 else { return text }
        return String(text.prefix(3)) + "***" + String(text.suffix(3))
    }
}
