import Foundation

struct MockStudentService: StudentService {
    /// Simulated network latency. Tests pass `.zero`.
    var delay: Duration = .milliseconds(300)

    func semesters() async throws -> [Semester] {
        try await Task.sleep(for: delay)
        return ["FALL2026", "SUMMER2026", "SPRING2026", "FALL2025", "SUMMER2025"].map(Semester.init(name:))
    }

    func courses(for semester: Semester) async throws -> [Course] {
        try await Task.sleep(for: delay)
        return Self.coursesBySemester[semester.name] ?? []
    }

    func marks(for semester: Semester) async throws -> [CourseMark] {
        try await Task.sleep(for: delay)
        if let courses = Self.coursesBySemester[semester.name] {
            return courses.sorted { $0.code < $1.code }.map(CourseMark.init(course:))
        }
        return Self.archivedMarks[semester.name] ?? []
    }

    func exams(for semester: Semester) async throws -> [Exam] {
        try await Task.sleep(for: delay)
        return Self.examsBySemester[semester.name] ?? []
    }

    func profile() async throws -> StudentProfile {
        try await Task.sleep(for: delay)
        return Self.studentProfile
    }

    func messages() async throws -> [Message] {
        try await Task.sleep(for: delay)
        return Self.inbox
    }

    /// The Notification screenshot shows an empty list.
    func notifications() async throws -> [Message] {
        try await Task.sleep(for: delay)
        return []
    }

    /// The Student Fee screenshot shows "0.0 VND" and no paid invoices.
    func feeBalance() async throws -> Double {
        try await Task.sleep(for: delay)
        return 0
    }

    // MARK: - Scheduled courses (single source of truth)

    // FALL2026, class IA2104. Rooms, slots, lecturers, names and start/end dates come from the
    // reference screenshots; each course repeats its weekly pattern from start date to end date,
    // which reproduces the screenshot's SessionNo values (e.g. MAD101 #9 on Tue 6/10).
    // finalMark values are the requested all-passed marks (6-8), fixed so they survive restarts.
    // absentSessions: missed sessions, drawn once with a fixed random seed (20261007) and written down here so they
    // never change between launches. Rule: attendance (attended/held) must never fall below 80%, so a course may only
    // have as many absences as held/5 allows (max 3), and the k-th absence sits at session 5k or later. At 4 sessions held
    // even one absence is 75%, so IOT102 has none yet. Absences only sit on sessions that had finished by 2026-10-06.
    static let fall2026Courses: [Course] = [
        Course(code: "IOT102", name: "Internet of Things", className: "IA2104", lecturer: "loind",
               startDay: CalendarDay(2026, 9, 11), endDay: CalendarDay(2026, 11, 13),
               meetings: [Meeting(weekday: .friday, slot: .four, room: "P.132")],
               absentSessions: [],
               finalMark: 7.8),
        Course(code: "MAD101", name: "Discrete mathematics", className: "IA2104", lecturer: "vinhdp",
               startDay: CalendarDay(2026, 9, 8), endDay: CalendarDay(2026, 11, 13),
               meetings: [Meeting(weekday: .tuesday, slot: .three, room: "P.115"),
                          Meeting(weekday: .friday, slot: .three, room: "P.115")],
               absentSessions: [8],
               finalMark: 6.5),
        Course(code: "NWC204", name: "Computer Networking", className: "IA2104", lecturer: "NguyenLH5",
               startDay: CalendarDay(2026, 9, 9), endDay: CalendarDay(2026, 11, 14),
               meetings: [Meeting(weekday: .wednesday, slot: .three, room: "P.503"),
                          Meeting(weekday: .saturday, slot: .three, room: "P.503")],
               absentSessions: [6],
               finalMark: 7.2),
        Course(code: "OSG203", name: "Operating System_Hệ điều hành", className: "IA2104", lecturer: "thaopy",
               startDay: CalendarDay(2026, 9, 9), endDay: CalendarDay(2026, 11, 14),
               meetings: [Meeting(weekday: .wednesday, slot: .four, room: "P.233"),
                          Meeting(weekday: .saturday, slot: .four, room: "P.233")],
               absentSessions: [5],
               finalMark: 7.5),
    ]

    // SUMMER2026, class IA2102: a completed semester (all sessions are in the past).
    // From the reference screenshots: course codes, names, class names and start/end dates
    // (VOV124's dates are cut off in the screenshot and are assumed to match SSA101).
    // The meeting days follow from the start/end weekdays (Mon+Thu, Tue+Fri, Wed+Sat).
    // ASSUMED, not in any screenshot: rooms, slots, lecturers, the break week and the final marks.
    // The break week (15-21 June) makes each course 20 sessions, matching the "/20" in the reference attendance.
    // absentSessions: 1-3 missed sessions per course (attendance 85-95%), same seed and 80% rule as Fall.
    private static let summerBreak = ScheduleCalendar.week(containing: CalendarDay(2026, 6, 15))

    static let summer2026Courses: [Course] = [
        Course(code: "CEA201", name: "Computer Organization and Architecture", className: "IA2102", lecturer: "khoand2",
               startDay: CalendarDay(2026, 5, 13), endDay: CalendarDay(2026, 7, 25),
               meetings: [Meeting(weekday: .wednesday, slot: .three, room: "P.201"),
                          Meeting(weekday: .saturday, slot: .three, room: "P.201")],
               breakDays: summerBreak, absentSessions: [19], finalMark: 7.0),
        Course(code: "CSI106", name: "Introduction to Computer Science", className: "IA2102", lecturer: "hanvt5",
               startDay: CalendarDay(2026, 5, 11), endDay: CalendarDay(2026, 7, 23),
               meetings: [Meeting(weekday: .monday, slot: .three, room: "P.304"),
                          Meeting(weekday: .thursday, slot: .three, room: "P.304")],
               breakDays: summerBreak, absentSessions: [5, 17], finalMark: 8.0),
        Course(code: "MAE101", name: "Mathematics for Engineering", className: "IA2102", lecturer: "tuanlq3",
               startDay: CalendarDay(2026, 5, 13), endDay: CalendarDay(2026, 7, 25),
               meetings: [Meeting(weekday: .wednesday, slot: .four, room: "P.201"),
                          Meeting(weekday: .saturday, slot: .four, room: "P.201")],
               breakDays: summerBreak, absentSessions: [18], finalMark: 6.8),
        Course(code: "PFP191", name: "Programming Fundamentals with Python", className: "IA2102", lecturer: "namph4",
               startDay: CalendarDay(2026, 5, 11), endDay: CalendarDay(2026, 7, 23),
               meetings: [Meeting(weekday: .monday, slot: .four, room: "P.304"),
                          Meeting(weekday: .thursday, slot: .four, room: "P.304")],
               breakDays: summerBreak, absentSessions: [6, 18], finalMark: 7.6),
        Course(code: "SSA101", name: "Academic skills", className: "IA2102", lecturer: "lanpt8",
               startDay: CalendarDay(2026, 5, 12), endDay: CalendarDay(2026, 7, 24),
               meetings: [Meeting(weekday: .tuesday, slot: .three, room: "P.402"),
                          Meeting(weekday: .friday, slot: .three, room: "P.402")],
               breakDays: summerBreak, absentSessions: [7, 12, 16], finalMark: 7.4),
        Course(code: "VOV124", name: "Vovinam 2/3", className: "H1_VOV124_4B", lecturer: "binhnk",
               startDay: CalendarDay(2026, 5, 12), endDay: CalendarDay(2026, 7, 24),
               meetings: [Meeting(weekday: .tuesday, slot: .four, room: "P.G01"),
                          Meeting(weekday: .friday, slot: .four, room: "P.G01")],
               breakDays: summerBreak, absentSessions: [7, 13, 17], finalMark: 6.5),
    ]

    private static let coursesBySemester: [String: [Course]] = [
        "FALL2026": fall2026Courses,
        "SUMMER2026": summer2026Courses,
    ]

    // MARK: - Exams, profile and messages (copied from the reference screenshots)

    // Only SUMMER2026 was shown; other semesters show 0 exams until their screenshots arrive.
    // Blank rooms and types are blank in the reference too.
    static let summer2026Exams: [Exam] = [
        Exam(day: CalendarDay(2026, 6, 30), subject: "VOV124", room: "VOV2", time: "07h00-08h30", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 19), subject: "PFP191", room: "130", time: "13h40-15h40", type: "PE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 20), subject: "PFP191", room: "007", time: "17h45-20h00", type: "", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 26), subject: "CSI106", room: "133", time: "16h10-17h40", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 28), subject: "CEA201", room: "302", time: "12h50-14h20", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 29), subject: "PFP191", room: "233", time: "07h30-09h00", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 7, 31), subject: "MAE101", room: "312", time: "10h50-12h20", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 2), subject: "SSA101", room: "225", time: "07h30-09h00", type: "FE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 2), subject: "CSI106", room: "", time: "16h10-17h40", type: "2NDFE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 4), subject: "PFP191", room: "", time: "10h50-12h20", type: "2NDFE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 4), subject: "CEA201", room: "", time: "16h10-17h40", type: "2NDFE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 8), subject: "MAE101", room: "", time: "10h50-12h20", type: "2NDFE", status: "Đã thi"),
        Exam(day: CalendarDay(2026, 8, 8), subject: "SSA101", room: "", time: "14h30-16h00", type: "2NDFE", status: "Đã thi"),
    ]

    private static let examsBySemester: [String: [Exam]] = ["SUMMER2026": summer2026Exams]

    // The roll number is what the Student ID QR code in the reference decodes to.
    // shortcut: only the masked email is known, so revealing it shows the same text; put the full address here to reveal it.
    static let studentProfile = StudentProfile(name: "Vũ Hoàng Phúc", badge: "HD", rollNumber: "SE211094",
                                               email: "phu***699@gmail.com", campus: "HCM")

    // Newest first, as in the reference. These are copied as text; the Fall attendance data above is
    // deliberately left unchanged even where it disagrees (user decision, 2026-10-14).
    // UNRESOLVED: a 7th row is cut off by the tab bar. Visible: "Cập nhật điểm danh", "12 days ago · vinhdp",
    // and only the tops of its first body line. Its body cannot be read, so it is left out rather than guessed;
    // add it (and any later rows) from a scrolled screenshot.
    static let inbox: [Message] = [
        Message(id: 1, title: "Thông báo đăng nhập", sender: "SE211094",
                body: "Bạn vừa đăng nhập lúc 05/10/2026 10:09:38.", day: CalendarDay(2026, 10, 5)),
        Message(id: 2, title: "Cập nhật điểm danh", sender: "thaopy",
                body: "Điểm danh Operating System_Hệ điều hành ngày 03/10/2026: Vắng mặt.", day: CalendarDay(2026, 10, 3)),
        Message(id: 3, title: "Cập nhật điểm danh", sender: "NguyenLH5",
                body: "Điểm danh Mạng máy tính ngày 03/10/2026: Vắng mặt.", day: CalendarDay(2026, 10, 3)),
        Message(id: 4, title: "Cập nhật điểm danh", sender: "loind",
                body: "Điểm danh Internet vạn vật ngày 02/10/2026: Có mặt.", day: CalendarDay(2026, 10, 2)),
        Message(id: 5, title: "Cập nhật điểm danh", sender: "loind",
                body: "Điểm danh Internet vạn vật ngày 02/10/2026: Có mặt.", day: CalendarDay(2026, 10, 2)),
        Message(id: 6, title: "Cập nhật điểm danh", sender: "vinhdp",
                body: "Điểm danh Toán rời rạc ngày 02/10/2026: Có mặt.", day: CalendarDay(2026, 10, 2)),
    ]

    // MARK: - Marks of semesters that have no schedule data yet (copied from the reference screenshots)

    private static let archivedMarks: [String: [CourseMark]] = [
        "SPRING2026": [
            CourseMark(courseCode: "ENT503_Malaysia", courseName: "", className: "H1_SP26_MALAYSIA",
                       average: nil, status: .exempted),
        ],
        "FALL2025": [
            mark("ENT403", "Summit 1", "H2_PC1504", 6.2, passed: true),
            // "Orientaiton" is spelled this way in the reference screenshot.
            mark("OTP101", "Orientaiton and General Training Program", "OTP_Dot 1_FA25", 7.3, passed: true),
            mark("VOV114", "Vovinam 1/3", "H2_VOV114_9A", 6.0, passed: true),
        ],
    ]

    private static func mark(_ code: String, _ name: String, _ className: String,
                             _ average: Double, passed: Bool = false) -> CourseMark {
        CourseMark(courseCode: code, courseName: name, className: className,
                   average: average, status: passed ? .passed : .notPassed)
    }
}
