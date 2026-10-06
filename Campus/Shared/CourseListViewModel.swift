import Foundation
import Observation

/// Shared by the Timetable and Attendance screens: both show the selected semester's courses.
@MainActor @Observable
final class CourseListViewModel {
    private(set) var semesters: [Semester] = []
    var selected: Semester?
    private(set) var state: LoadState<[Course]> = .loading

    private let service: any StudentService

    init(service: any StudentService) {
        self.service = service
    }

    var courses: [Course] {
        if case .loaded(let courses) = state { return courses }
        return []
    }

    func loadSemesters() async {
        do {
            semesters = try await service.semesters()
            selected = semesters.first
            if selected == nil { state = .loaded([]) }
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func loadCourses() async {
        guard let semester = selected else { return }
        state = .loading
        do {
            state = .loaded(try await service.courses(for: semester))
        } catch is CancellationError {
            // Superseded by a newer selection.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func retry() async {
        if semesters.isEmpty {
            state = .loading
            await loadSemesters()
        } else {
            await loadCourses()
        }
    }
}
