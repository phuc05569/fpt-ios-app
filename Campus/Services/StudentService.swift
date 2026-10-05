import SwiftUI

/// Data source for the app. `MockStudentService` backs it for now;
/// a URLSession-based implementation can replace it without touching any view.
protocol StudentService: Sendable {
    func semesters() async throws -> [Semester]
    func marks(for semester: Semester) async throws -> [CourseMark]
}

extension EnvironmentValues {
    @Entry var studentService: any StudentService = MockStudentService()
}
