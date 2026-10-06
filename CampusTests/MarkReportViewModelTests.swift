import Testing
@testable import Campus

@MainActor
struct MarkReportViewModelTests {
    @Test func startsOnFallThenSwitchesSemester() async {
        let viewModel = MarkReportViewModel(service: MockStudentService(delay: .zero))

        await viewModel.loadSemesters()
        #expect(viewModel.selected?.name == "FALL2026")

        await viewModel.loadMarks()
        guard case .loaded(let fall) = viewModel.state else {
            Issue.record("Fall marks did not load")
            return
        }
        #expect(fall.count == 4)
        #expect(fall.allSatisfy { $0.status == .passed })

        viewModel.selected = viewModel.semesters.first { $0.name == "SUMMER2026" }
        await viewModel.loadMarks()
        guard case .loaded(let summer) = viewModel.state else {
            Issue.record("Summer marks did not load")
            return
        }
        #expect(summer.count == 6)
        #expect(summer.allSatisfy { $0.status == .notPassed })
    }
}
