import Testing
@testable import Campus

@MainActor
struct MarkReportViewModelTests {
    private func marks(of viewModel: MarkReportViewModel) -> [CourseMark]? {
        guard case .loaded(let marks) = viewModel.state else { return nil }
        return marks
    }

    // Semester switching must work in both directions and must not leak data between semesters.
    @Test func switchesBetweenFallAndSummerInBothDirections() async {
        let viewModel = MarkReportViewModel(service: MockStudentService(delay: .zero))

        await viewModel.loadSemesters()
        #expect(viewModel.selected?.name == "FALL2026")
        await viewModel.loadMarks()
        let fall = marks(of: viewModel)
        #expect(fall?.map(\.courseCode) == ["IOT102", "MAD101", "NWC204", "OSG203"])
        #expect(fall?.allSatisfy { $0.status == .passed } == true)

        viewModel.selected = viewModel.semesters.first { $0.name == "SUMMER2026" }
        await viewModel.loadMarks()
        let summer = marks(of: viewModel)
        #expect(summer?.map(\.courseCode) == ["CEA201", "CSI106", "MAE101", "PFP191", "SSA101", "VOV124"])
        #expect(summer?.allSatisfy { $0.status == .passed } == true)

        viewModel.selected = viewModel.semesters.first { $0.name == "FALL2026" }
        await viewModel.loadMarks()
        #expect(marks(of: viewModel) == fall)   // unchanged after switching back
    }
}
