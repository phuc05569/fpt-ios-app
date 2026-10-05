import Foundation
import Observation

@MainActor @Observable
final class MarkReportViewModel {
    private(set) var semesters: [Semester] = []
    var selected: Semester?
    private(set) var state: LoadState<[CourseMark]> = .loading

    private let service: any StudentService
    private let startingSemester: String

    /// `startingSemester` matches the reference screenshot (SUMMER2026 selected).
    /// A real app would pick the latest semester that has published marks.
    init(service: any StudentService, startingSemester: String = "SUMMER2026") {
        self.service = service
        self.startingSemester = startingSemester
    }

    func loadSemesters() async {
        do {
            semesters = try await service.semesters()
            selected = semesters.first { $0.name == startingSemester } ?? semesters.first
            if selected == nil { state = .loaded([]) }
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func loadMarks() async {
        guard let semester = selected else { return }
        state = .loading
        do {
            state = .loaded(try await service.marks(for: semester))
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
            await loadMarks()
        }
    }
}
