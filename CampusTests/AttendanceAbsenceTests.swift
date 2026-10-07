import Foundation
import Testing
@testable import Campus

/// Attendance rule: a course FAILS below 80%, so attendance must never be below 80% (and never more than 3 absences).
/// These tests pin that rule at every moment of both semesters and prove Marks and Timetable are unaffected.
struct AttendanceAbsenceTests {
    private let fall = MockStudentService.fall2026Courses
    private let summer = MockStudentService.summer2026Courses
    private let written = ScheduleCalendar.date(of: CalendarDay(2026, 10, 6))   // when the absences were recorded

    private func moment(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        ScheduleCalendar.date(of: CalendarDay(year, month, day), minutes: hour * 60 + minute)
    }

    /// Absences that count at `now`: recorded absences on sessions that have finished.
    private func countedAbsences(_ course: Course, at now: Date) -> Int {
        ScheduleCalendar.sessions(of: course)
            .filter { $0.end <= now && course.absentSessions.contains($0.number) }.count
    }

    // MARK: 1. Absence counts

    @Test func summerCoursesHaveOneToThreeAbsencesAndEightyFiveToNinetyFivePercent() {
        for course in summer {
            #expect((1...3).contains(course.absentSessions.count), "\(course.code)")
            let result = ScheduleCalendar.attendance(of: course, at: moment(2026, 10, 5, 15, 47))
            #expect(result.held == 20)
            #expect((85.0...95.0).contains(result.percent), "\(course.code) \(result.percent)")
        }
    }

    // Fall: as many absences as the 80% rule allows for the sessions held so far (held / 5, at most 3),
    // and at least one whenever that is possible. With 4 sessions held even one absence is 75%, so none.
    @Test func fallAbsencesFollowTheEightyPercentRule() {
        for course in fall {
            let held = ScheduleCalendar.sessions(of: course).filter { $0.end <= written }.count
            let allowed = min(3, held / 5)
            if allowed == 0 {
                #expect(course.absentSessions.isEmpty, "\(course.code): \(held) held, any absence would be below 80%")
            } else {
                #expect((1...allowed).contains(course.absentSessions.count), "\(course.code)")
            }
        }
    }

    @Test func noCourseHasMoreThanThreeAbsences() {
        for course in summer + fall {
            #expect(course.absentSessions.count <= 3, "\(course.code)")
            #expect(Set(course.absentSessions).count == course.absentSessions.count)
            let total = ScheduleCalendar.sessions(of: course).count
            #expect(course.absentSessions.allSatisfy { (1...total).contains($0) })
        }
    }

    // MARK: 2. Never below 80%

    // The k-th absence is session 5k or later, which keeps absences <= held / 5 at every moment.
    @Test func absencesAreSpacedSoTheFloorHoldsFromTheFirstSession() {
        for course in summer + fall {
            for (index, number) in course.absentSessions.sorted().enumerated() {
                #expect(number >= 5 * (index + 1), "\(course.code) absence #\(index + 1) at session \(number)")
            }
        }
    }

    // Checked at the end of every single session of both semesters, not just today.
    @Test func attendanceIsNeverBelowEightyPercentAtAnyMoment() {
        for course in summer + fall {
            for session in ScheduleCalendar.sessions(of: course) {
                for now in [session.end.addingTimeInterval(-1), session.end, session.end.addingTimeInterval(3600)] {
                    let result = ScheduleCalendar.attendance(of: course, at: now)
                    if result.held > 0 {
                        #expect(result.percent >= 80, "\(course.code) after session \(session.number): \(result.percent)")
                    }
                }
            }
        }
    }

    // As Fall sessions pass, attendance can only stay or rise: all absences are already in the past.
    @Test func fallAttendanceNeverDropsAsSessionsProgress() {
        for course in fall {
            var previous = ScheduleCalendar.attendance(of: course, at: written).percent
            #expect(previous >= 80)
            for session in ScheduleCalendar.sessions(of: course) where session.end > written {
                let result = ScheduleCalendar.attendance(of: course, at: session.end)
                #expect(result.percent >= previous, "\(course.code) after session \(session.number)")
                #expect(result.percent >= 80)
                previous = result.percent
            }
        }
    }

    // MARK: 3. Percentages come from the sessions

    @Test func attendanceIsRecomputedFromTheActualSessions() {
        let times = [moment(2026, 5, 1), moment(2026, 6, 10, 13), moment(2026, 10, 5, 15, 47),
                     moment(2026, 10, 6, 14, 45), moment(2026, 11, 20), moment(2027, 1, 1)]
        for course in summer + fall {
            let sessions = ScheduleCalendar.sessions(of: course)
            for now in times {
                let finished = sessions.filter { $0.end <= now }
                let attended = finished.filter { !course.absentSessions.contains($0.number) }
                let result = ScheduleCalendar.attendance(of: course, at: now)
                #expect(result.held == finished.count)
                #expect(result.attended == attended.count)
                let expected = finished.isEmpty ? 0 : Double(attended.count) / Double(finished.count) * 100
                #expect(result.percent == expected)
            }
        }
    }

    // Frozen table on 05/10/2026 15:47 (attended, held, percent).
    @Test func attendanceTableOnTheReferenceDay() {
        let now = moment(2026, 10, 5, 15, 47)
        let expected: [String: (attended: Int, held: Int, percent: Double)] = [
            // FALL2026
            "IOT102": (4, 4, 100), "MAD101": (7, 8, 87.5), "NWC204": (7, 8, 87.5), "OSG203": (7, 8, 87.5),
            // SUMMER2026 (all 20 sessions finished)
            "CEA201": (19, 20, 95), "CSI106": (18, 20, 90), "MAE101": (19, 20, 95),
            "PFP191": (18, 20, 90), "SSA101": (17, 20, 85), "VOV124": (17, 20, 85),
        ]
        for course in fall + summer {
            let result = ScheduleCalendar.attendance(of: course, at: now)
            let row = expected[course.code]
            #expect(result.attended == row?.attended)
            #expect(result.held == row?.held)
            #expect(result.percent == row?.percent)
        }
    }

    // MARK: 4. Future sessions are never absences

    @Test func absencesOnlyCountOnceTheirSessionHasFinished() {
        for course in summer + fall {
            let sessions = ScheduleCalendar.sessions(of: course)
            // Before the course starts nothing is held and nothing is absent.
            let before = ScheduleCalendar.attendance(of: course, at: moment(2026, 1, 1))
            #expect(before.held == 0 && before.attended == 0)
            for session in sessions where course.absentSessions.contains(session.number) {
                let justBefore = session.end.addingTimeInterval(-1)
                let early = ScheduleCalendar.attendance(of: course, at: justBefore)
                #expect(early.held == session.number - 1)                                   // the session is not even held yet
                #expect(early.held - early.attended == countedAbsences(course, at: justBefore))
                #expect(early.held - early.attended == course.absentSessions.filter { $0 < session.number }.count)
                let after = ScheduleCalendar.attendance(of: course, at: session.end)
                #expect(after.held == session.number)
                #expect(after.held - after.attended == course.absentSessions.filter { $0 <= session.number }.count)
            }
        }
    }

    // Every recorded absence is on a session that had already finished when the data was written.
    @Test func absencesAreOnAlreadyFinishedSessions() {
        for course in summer + fall {
            for session in ScheduleCalendar.sessions(of: course) where course.absentSessions.contains(session.number) {
                #expect(session.end < written, "\(course.code) #\(session.number)")
            }
        }
    }

    @Test func absencesVaryBetweenCourses() {
        #expect(Set(summer.map { $0.absentSessions.count }) == [1, 2, 3])
        #expect(Set(summer.map { $0.absentSessions }).count == summer.count)
        let fallWithAbsences = fall.filter { !$0.absentSessions.isEmpty }
        #expect(Set(fallWithAbsences.map { $0.absentSessions }).count == fallWithAbsences.count)
    }

    @Test func attendanceReportStillUsesTheSharedCourses() async throws {
        let service = MockStudentService(delay: .zero)
        #expect(try await service.courses(for: Semester(name: "FALL2026")) == fall)
        #expect(try await service.courses(for: Semester(name: "SUMMER2026")) == summer)
    }

    // MARK: 5. Mark Report and Weekly Timetable unchanged

    @Test func markReportIsUnchanged() async throws {
        let service = MockStudentService(delay: .zero)
        let expected: [String: [(code: String, average: Double, className: String)]] = [
            "FALL2026": [("IOT102", 7.8, "IA2104"), ("MAD101", 6.5, "IA2104"),
                         ("NWC204", 7.2, "IA2104"), ("OSG203", 7.5, "IA2104")],
            "SUMMER2026": [("CEA201", 7.0, "IA2102"), ("CSI106", 8.0, "IA2102"), ("MAE101", 6.8, "IA2102"),
                           ("PFP191", 7.6, "IA2102"), ("SSA101", 7.4, "IA2102"), ("VOV124", 6.5, "H1_VOV124_4B")],
        ]
        for (semester, rows) in expected {
            let marks = try await service.marks(for: Semester(name: semester))
            #expect(marks.count == rows.count)
            for (mark, row) in zip(marks, rows) {
                #expect(mark.courseCode == row.code)
                #expect(mark.average == row.average)
                #expect(mark.className == row.className)
                #expect(mark.status == .passed)
            }
        }
    }

    // Absences are attendance data only: they must not move, add or remove a single session,
    // and the timetable badge (time-based `isPresent`) behaves exactly as before.
    @Test func weeklyTimetableIsUnchanged() {
        func plain(_ course: Course) -> [String] {
            ScheduleCalendar.sessions(of: course).map {
                "\($0.number) \($0.day.formatted) \($0.meeting.slot.rawValue) \($0.meeting.room) \($0.start.timeIntervalSince1970)-\($0.end.timeIntervalSince1970)"
            }
        }
        for course in fall + summer {
            var withoutAbsences = course
            withoutAbsences.absentSessions = []
            #expect(plain(course) == plain(withoutAbsences))
        }
        let counts = Dictionary(uniqueKeysWithValues: (fall + summer).map { ($0.code, ScheduleCalendar.sessions(of: $0).count) })
        #expect(counts == ["IOT102": 10, "MAD101": 20, "NWC204": 20, "OSG203": 20,
                           "CEA201": 20, "CSI106": 20, "MAE101": 20, "PFP191": 20, "SSA101": 20, "VOV124": 20])
        let absent = ScheduleCalendar.sessions(of: fall[1]).first { fall[1].absentSessions.contains($0.number) }!
        #expect(absent.isPresent(at: moment(2026, 10, 5, 15, 47)))      // timetable still shows a finished session
        #expect(!absent.wasAttended(at: moment(2026, 10, 5, 15, 47)))   // attendance report counts it as missed
        // The reference week (05-11/10/2026) is covered by ScheduleTests.reproducesTheReferenceWeek.
    }
}
