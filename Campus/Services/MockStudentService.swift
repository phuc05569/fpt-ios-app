import Foundation

struct MockStudentService: StudentService {
    /// Simulated network latency. Tests pass `.zero`.
    var delay: Duration = .milliseconds(300)

    func semesters() async throws -> [Semester] {
        try await Task.sleep(for: delay)
        return ["FALL2026", "SUMMER2026", "SPRING2026"].map(Semester.init(name:))
    }

    func marks(for semester: Semester) async throws -> [CourseMark] {
        try await Task.sleep(for: delay)
        return Self.marksBySemester[semester.name] ?? []
    }

    // MARK: - Data

    // SUMMER2026 mirrors the Mark Report reference screenshot.
    // VOV124's average is cut off in the screenshot, so 0.0 is an assumption.
    // FALL2026 and SPRING2026 are invented to exercise the other states.
    private static let marksBySemester: [String: [CourseMark]] = [
        "FALL2026": [
            mark("MAD101", "Discrete Mathematics", "IA2104", 0.0),
            mark("NWC204", "Computer Networking", "IA2104", 0.0),
            mark("OSG203", "Operating Systems", "IA2104", 0.0),
        ],
        "SUMMER2026": [
            mark("CEA201", "Computer Organization and Architecture", "IA2102", 0.0),
            mark("CSI106", "Introduction to Computer Science", "IA2102", 1.2),
            mark("MAE101", "Mathematics for Engineering", "IA2102", 0.2),
            mark("PFP191", "Programming Fundamentals with Python", "IA2102", 0.0),
            mark("SSA101", "Academic skills", "IA2102", 0.0),
            mark("VOV124", "Vovinam 2/3", "IA2102", 0.0),
        ],
        "SPRING2026": [
            mark("SSG104", "Communication and In-Group Working Skills", "IA2101", 7.4, passed: true),
            mark("ITE302c", "Ethics in IT", "IA2101", 8.1, passed: true),
        ],
    ]

    private static func mark(_ code: String, _ name: String, _ className: String,
                             _ average: Double, passed: Bool = false) -> CourseMark {
        CourseMark(courseCode: code, courseName: name, className: className,
                   average: average, status: passed ? .passed : .notPassed)
    }
}
