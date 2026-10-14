import Testing
import SwiftUI
import UIKit
@testable import Campus

/// Data and logic behind the Profile, Messages, Notification, Exam schedule and Student Fee screens.
struct ReferenceScreensTests {
    private let service = MockStudentService(delay: .zero)
    /// When the reference screenshots were taken: 14/10/2026 22:06, Ho Chi Minh City.
    private let screenshotTime = ScheduleCalendar.date(of: CalendarDay(2026, 10, 14), minutes: 22 * 60 + 6)

    @Test func summerExamsMatchTheReference() async throws {
        let exams = try await service.exams(for: Semester(name: "SUMMER2026"))
        #expect(exams.count == 13)
        #expect(exams.allSatisfy { $0.status == "\u{0110}\u{00E3} thi" })
        #expect(exams.map(\.subject) == ["VOV124", "PFP191", "PFP191", "CSI106", "CEA201", "PFP191", "MAE101",
                                         "SSA101", "CSI106", "PFP191", "CEA201", "MAE101", "SSA101"])
        #expect(exams.first?.dateText == "30/6/2026")
        #expect(exams[7].dateText == "2/8/2026")
        #expect(exams[2].type.isEmpty && exams[2].room == "007")     // "Type:" is blank in the reference
        #expect(exams[8].room.isEmpty && exams[8].type == "2NDFE")   // "Room:" is blank in the reference
        #expect(exams.last?.time == "14h30-16h00")
    }

    @Test func otherSemestersHaveNoExamsYet() async throws {
        for name in ["FALL2026", "SPRING2026"] {
            #expect(try await service.exams(for: Semester(name: name)).isEmpty)
        }
    }

    @Test func messagesMatchTheReference() async throws {
        let messages = try await service.messages()
        #expect(messages.count == 6)   // the 7th, unreadable row is deliberately left out
        #expect(messages.first?.title == "\u{0054}h\u{00F4}ng b\u{00E1}o \u{0111}\u{0103}ng nh\u{1EAD}p")
        #expect(messages.first?.body == "\u{0042}\u{1EA1}n v\u{1EEB}a \u{0111}\u{0103}ng nh\u{1EAD}p l\u{00FA}c 05/10/2026 10:09:38.")
        #expect(messages[1].body == "\u{0110}i\u{1EC3}m danh Operating System_H\u{1EC7} \u{0111}i\u{1EC1}u h\u{00E0}nh ng\u{00E0}y 03/10/2026: V\u{1EAF}ng m\u{1EB7}t.")
        #expect(messages.map(\.sender) == ["SE211094", "thaopy", "NguyenLH5", "loind", "loind", "vinhdp"])
        #expect(messages.map { $0.age(now: screenshotTime) } ==
                ["9 days ago", "11 days ago", "11 days ago", "12 days ago", "12 days ago", "12 days ago"])
    }

    @Test func messageSearchIgnoresCaseAndAccents() async throws {
        let messages = try await service.messages()
        #expect(messages.filter { $0.matches("") }.count == 6)
        #expect(messages.filter { $0.matches("mang may tinh") }.map(\.id) == [3])
        #expect(messages.filter { $0.matches("VINHDP") }.count == 1)
        #expect(messages.filter { $0.matches("no such text") }.isEmpty)
    }

    @Test func notificationsAndFeesAreEmptyAsInTheReference() async throws {
        #expect(try await service.notifications().isEmpty)
        let balance = try await service.feeBalance()
        #expect("\(balance) VND" == "0.0 VND")
    }

    @Test func profileMasksLikeTheReference() async throws {
        let profile = try await service.profile()
        #expect(profile.name == "V\u{0169} Ho\u{00E0}ng Ph\u{00FA}c")
        #expect(profile.maskedRollNumber == "SE2***094")
        #expect(profile.maskedEmail == "phu***699@gmail.com")
        #expect(StudentProfile.mask("phuc055699") == "phu***699")
        #expect(StudentProfile.mask("abc") == "abc")
    }

    @Test func studentIDQRHasOneVersion1Symbol() throws {
        let image = try #require(QRCode.image(for: "SE211094"))
        #expect(image.cgImage?.width == 21)   // version 1, quiet zone trimmed
        #expect(image.cgImage?.height == 21)
    }

    @Test func lightColorsAreUnchangedAndDarkColorsDiffer() {
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        func hex(_ color: Color, _ traits: UITraitCollection) -> UInt32 {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            UIColor(color).resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
            return UInt32((r * 255).rounded()) << 16 | UInt32((g * 255).rounded()) << 8 | UInt32((b * 255).rounded())
        }
        #expect(hex(Theme.canvas, light) == 0xF4F6F9)
        #expect(hex(Theme.card, light) == 0xFFFFFF)
        #expect(hex(Theme.navy, light) == 0x1A2E4A)
        #expect(hex(Theme.textSecondary, light) == 0x6B7280)
        #expect(hex(Theme.bar, dark) == 0x1A2E4A)   // bars stay navy in Dark Mode
        #expect(hex(Theme.canvas, dark) != 0xF4F6F9)
        #expect(hex(Theme.navy, dark) != 0x1A2E4A)
    }
}
