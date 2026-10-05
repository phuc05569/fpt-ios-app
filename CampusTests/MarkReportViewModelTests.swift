import Testing
@testable import Campus

@MainActor
struct MarkReportViewModelTests {
    @Test func startsOnSummerThenSwitchesSemester() async {
        let viewModel = MarkReportViewModel(service: MockStudentService(delay: .zero))

        await viewModel.loadSemesters()
        #expect(viewModel.selected?.name == "SUMMER2026")

        await viewModel.loadMarks()
        guard case .loaded(let summer) = viewModel.state else {
            Issue.record("Summer marks did not load")
            return
        }
        #expect(summer.count == 6)
        #expect(summer.allSatisfy { $0.status == .notPassed })

        viewModel.selected = viewModel.semesters.first { $0.name == "SPRING2026" }
        await viewModel.loadMarks()
        guard case .loaded(let spring) = viewModel.state else {
            Issue.record("Spring marks did not load")
            return
        }
        #expect(spring.allSatisfy { $0.status == .passed })
    }
}
