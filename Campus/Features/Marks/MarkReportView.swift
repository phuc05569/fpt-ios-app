import SwiftUI

struct MarkReportView: View {
    @State private var viewModel: MarkReportViewModel

    init(service: any StudentService) {
        _viewModel = State(initialValue: MarkReportViewModel(service: service))
    }

    var body: some View {
        VStack(spacing: 0) {
            SemesterChipBar(semesters: viewModel.semesters, selected: viewModel.selected) {
                viewModel.selected = $0
            }
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Mark Report")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await viewModel.loadSemesters() }
        .task(id: viewModel.selected) { await viewModel.loadMarks() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Theme.navy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 12) {
                Text(message)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Retry") { Task { await viewModel.retry() } }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.orange)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let marks) where marks.isEmpty:
            Text("No marks for this semester yet.")
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let marks):
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(marks) { MarkCard(mark: $0) }
                }
                .padding(.horizontal, 16)
                .padding(.top, 25)
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MarkReportView(service: MockStudentService(delay: .zero))
    }
    .tint(.white)
}
