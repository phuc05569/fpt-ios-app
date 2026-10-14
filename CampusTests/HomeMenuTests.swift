import Testing
@testable import Campus

struct HomeMenuTests {
    @Test func sectionsAndTitlesMatchTheReference() {
        let sections = HomeMenuSection.all
        #expect(sections.map(\.title) == ["NOTIFICATION AND APPLICATION STATUS", "INFORMATION ACCESS", "REPORTS"])
        #expect(sections.map { $0.items.count } == [2, 3, 3])
        #expect(sections[0].items.map(\.title) == ["Notification", "Application status"])
        #expect(sections[1].items.map(\.title) == ["Weekly timetable", "Exam schedule", "Semester Schedule"])
        #expect(sections[2].items.map(\.title).prefix(2) == ["Attendance report", "Mark Report"])
    }

    @Test func existingScreensStayWired() {
        let items = HomeMenuSection.all.flatMap(\.items)
        #expect(items.first { $0.title == "Weekly timetable" }?.destination == .timetable)
        #expect(items.first { $0.title == "Attendance report" }?.destination == .attendance)
        #expect(items.first { $0.title == "Mark Report" }?.destination == .marks)
    }

    @Test func referenceScreensAreWired() {
        let items = HomeMenuSection.all.flatMap(\.items)
        #expect(items.first { $0.title == "Notification" }?.destination == .notification)
        #expect(items.first { $0.title == "Application status" }?.destination == .applicationStatus)
        #expect(items.first { $0.title == "Exam schedule" }?.destination == .exams)
        #expect(items.first { $0.title == "Student Fee" }?.destination == .fee)
        #expect(items.first { $0.title == "Semester Schedule" }?.destination == .unavailable)   // no reference yet
    }

    @Test func everyItemHasUniqueTitle() {
        let titles = HomeMenuSection.all.flatMap(\.items).map(\.title)
        #expect(Set(titles).count == titles.count)
    }
}
