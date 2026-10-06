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

    // MARK: - Scheduled courses (single source of truth)

    // FALL2026, class IA2104. Rooms, slots, lecturers, names and start/end dates come from the
    // reference screenshots; each course repeats its weekly pattern from start date to end date,
    // which reproduces the screenshot's SessionNo values (e.g. MAD101 #9 on Tue 6/10).
    // finalMark values are the requested all-passed marks (6-8), fixed so they survive restarts.
    static let fall2026Courses: [Course] = [
        Course(code: "IOT102", name: "Internet of Things", className: "IA2104", lecturer: "loind",
               startDay: CalendarDay(2026, 9, 11), endDay: CalendarDay(2026, 11, 13),
               meetings: [Meeting(weekday: .friday, slot: .four, room: "P.132")],
               finalMark: 7.8),
        Course(code: "MAD101", name: "Discrete mathematics", className: "IA2104", lecturer: "vinhdp",
               startDay: CalendarDay(2026, 9, 8), endDay: CalendarDay(2026, 11, 13),
               meetings: [Meeting(weekday: .tuesday, slot: .three, room: "P.115"),
                          Meeting(weekday: .friday, slot: .three, room: "P.115")],
               finalMark: 6.5),
        Course(code: "NWC204", name: "Computer Networking", className: "IA2104", lecturer: "NguyenLH5",
               startDay: CalendarDay(2026, 9, 9), endDay: CalendarDay(2026, 11, 14),
               meetings: [Meeting(weekday: .wednesday, slot: .three, room: "P.503"),
                          Meeting(weekday: .saturday, slot: .three, room: "P.503")],
               finalMark: 7.2),
        Course(code: "OSG203", name: "Operating System_Hệ điều hành", className: "IA2104", lecturer: "thaopy",
               startDay: CalendarDay(2026, 9, 9), endDay: CalendarDay(2026, 11, 14),
               meetings: [Meeting(weekday: .wednesday, slot: .four, room: "P.233"),
                          Meeting(weekday: .saturday, slot: .four, room: "P.233")],
               finalMark: 7.5),
    ]

    private static let coursesBySemester: [String: [Course]] = [
        "FALL2026": fall2026Courses,
    ]

    // MARK: - Marks of semesters without schedule data (copied from the reference screenshots)

    private static let archivedMarks: [String: [CourseMark]] = [
        "SUMMER2026": [
            mark("CEA201", "Computer Organization and Architecture", "IA2102", 0.0),
            mark("CSI106", "Introduction to Computer Science", "IA2102", 1.2),
            mark("MAE101", "Mathematics for Engineering", "IA2102", 0.2),
            mark("PFP191", "Programming Fundamentals with Python", "IA2102", 0.0),
            mark("SSA101", "Academic skills", "IA2102", 0.0),
            // Average is cut off in the screenshot; 0.0 is an assumption.
            mark("VOV124", "Vovinam 2/3", "H1_VOV124_4B", 0.0),
        ],
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
