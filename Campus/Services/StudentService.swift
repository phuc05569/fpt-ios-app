import SwiftUI

/// Data source for the app. `MockStudentService` backs it for now;
/// a URLSession-based implementation can replace it without touching any view.
protocol StudentService: Sendable {
    func semesters() async throws -> [Semester]
    /// The scheduled courses of a semester. Timetable, attendance and (for these courses) marks derive from this.
    func courses(for semester: Semester) async throws -> [Course]
    func marks(for semester: Semester) async throws -> [CourseMark]
}

extension EnvironmentValues {
    @Entry var studentService: any StudentService = MockStudentService()
}
