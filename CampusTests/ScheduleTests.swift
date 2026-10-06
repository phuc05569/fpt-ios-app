import Foundation
import Testing
@testable import Campus

struct ScheduleTests {
    private let courses = MockStudentService.fall2026Courses

    private func moment(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
        ScheduleCalendar.date(of: CalendarDay(year, month, day), minutes: hour * 60 + minute)
            .addingTimeInterval(TimeInterval(second))
    }

    private func sessions(on day: CalendarDay) -> [ClassSession] {
        ScheduleCalendar.sessions(of: courses, in: [day])[day] ?? []
    }

    // The weekly timetable screenshot (week of 05/10/2026).
    @Test func reproducesTheReferenceWeek() {
        func summary(_ day: CalendarDay) -> [String] {
            sessions(on: day).map {
                "\($0.meeting.slot.rawValue) \($0.course.code) #\($0.number) \($0.meeting.room) \($0.course.lecturer) \($0.meeting.slot.startText)-\($0.meeting.slot.endText)"
            }
        }
        #expect(summary(CalendarDay(2026, 10, 5)) == [])
        #expect(summary(CalendarDay(2026, 10, 6)) == ["3 MAD101 #9 P.115 vinhdp 12:30-14:45"])
        #expect(summary(CalendarDay(2026, 10, 7)) == ["3 NWC204 #9 P.503 NguyenLH5 12:30-14:45",
                                                      "4 OSG203 #9 P.233 thaopy 15:00-17:15"])
        #expect(summary(CalendarDay(2026, 10, 8)) == [])
        #expect(summary(CalendarDay(2026, 10, 9)) == ["3 MAD101 #10 P.115 vinhdp 12:30-14:45",
                                                      "4 IOT102 #5 P.132 loind 15:00-17:15"])
        #expect(summary(CalendarDay(2026, 10, 10)) == ["3 NWC204 #10 P.503 NguyenLH5 12:30-14:45",
                                                       "4 OSG203 #10 P.233 thaopy 15:00-17:15"])
        #expect(summary(CalendarDay(2026, 10, 11)) == [])
    }

    @Test func weekIsMondayToSunday() {
        let week = ScheduleCalendar.week(containing: CalendarDay(2026, 10, 8))
        #expect(week.first == CalendarDay(2026, 10, 5))
        #expect(week.last == CalendarDay(2026, 10, 11))
        #expect(week.count == 7)
    }

    @Test func everyWeekRepeatsTheSamePattern() {
        func pattern(startingAt monday: CalendarDay) -> [String] {
            let week = ScheduleCalendar.week(containing: monday)
            let grouped = ScheduleCalendar.sessions(of: courses, in: week)
            return week.flatMap { day in
                (grouped[day] ?? []).map {
                    "\(ScheduleCalendar.weekday(of: day).shortName) \($0.course.code) \($0.meeting.slot.rawValue) \($0.meeting.room) \($0.course.lecturer)"
                }
            }
        }
        // Weeks that are fully inside every course's date range (15 Sep to 6 Nov).
        let reference = pattern(startingAt: CalendarDay(2026, 9, 14))
        #expect(reference.count == 7)
        for monday in [CalendarDay(2026, 9, 21), CalendarDay(2026, 10, 5), CalendarDay(2026, 10, 26), CalendarDay(2026, 11, 2)] {
            #expect(pattern(startingAt: monday) == reference)
        }
    }

    @Test func courseDatesMatchTheirSessionRange() {
        for course in courses {
            let all = ScheduleCalendar.sessions(of: course)
            #expect(all.first?.day == course.startDay)
            #expect(all.last?.day == course.endDay)
            #expect(all.map(\.number) == Array(1...all.count))
        }
    }

    // Sessions outside a course's start/end dates do not exist.
    @Test func noSessionsOutsideTheSemester() {
        #expect(sessions(on: CalendarDay(2026, 9, 1)).isEmpty)
        #expect(sessions(on: CalendarDay(2026, 12, 1)).isEmpty)
    }

    @Test func sessionStateFollowsTheClock() {
        let session = sessions(on: CalendarDay(2026, 10, 6))[0]   // MAD101, 12:30-14:45
        #expect(session.state(at: moment(2026, 10, 6, 12, 29, 59)) == .upcoming)
        #expect(session.isPresent(at: moment(2026, 10, 6, 12, 29, 59)) == false)
        #expect(session.state(at: moment(2026, 10, 6, 12, 30)) == .inProgress)
        #expect(session.isPresent(at: moment(2026, 10, 6, 13, 0)) == false)
        #expect(session.state(at: moment(2026, 10, 6, 14, 44, 59)) == .inProgress)
        #expect(session.isPresent(at: moment(2026, 10, 6, 14, 44, 59)) == false)
        #expect(session.state(at: moment(2026, 10, 6, 14, 45)) == .completed)
        #expect(session.isPresent(at: moment(2026, 10, 6, 14, 45)))
    }

    // Reference attendance screenshot: denominators 4, 8, 8, 8 on 05/10/2026 around 15:47.
    @Test func attendanceCountsFinishedSessions() {
        let now = moment(2026, 10, 5, 15, 47)
        let held = Dictionary(uniqueKeysWithValues: courses.map {
            ($0.code, ScheduleCalendar.attendance(of: $0, at: now))
        })
        #expect(held["IOT102"]?.held == 4)
        #expect(held["MAD101"]?.held == 8)
        #expect(held["NWC204"]?.held == 8)
        #expect(held["OSG203"]?.held == 8)
        // All finished sessions are Present.
        #expect(held.values.allSatisfy { $0.attended == $0.held })
    }

    @Test func attendanceGrowsAsTimePasses() {
        let course = courses.first { $0.code == "MAD101" }!
        let before = ScheduleCalendar.attendance(of: course, at: moment(2026, 10, 6, 14, 44))
        let after = ScheduleCalendar.attendance(of: course, at: moment(2026, 10, 6, 14, 45))
        #expect(before.held == 8)
        #expect(after.held == 9)
        #expect(after.attended == 9)
        #expect(ScheduleCalendar.attendance(of: course, at: moment(2026, 9, 1, 0, 0)).held == 0)
        #expect(ScheduleCalendar.attendance(of: course, at: moment(2027, 1, 1, 0, 0)).held == 20)
    }

    @Test func marksAreDerivedFromTheSameCourses() async throws {
        let service = MockStudentService(delay: .zero)
        let marks = try await service.marks(for: Semester(name: "FALL2026"))
        #expect(marks.count == courses.count)
        #expect(Set(marks.map(\.courseCode)) == Set(courses.map(\.code)))
        for mark in marks {
            let course = courses.first { $0.code == mark.courseCode }!
            #expect(mark.courseName == course.name)
            #expect(mark.className == course.className)
            #expect(mark.status == .passed)
            #expect((6.0...8.0).contains(mark.average ?? 0))
        }
        #expect(Set(marks.compactMap(\.average)).count == marks.count)   // distinct scores
    }
}
