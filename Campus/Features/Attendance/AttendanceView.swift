import SwiftUI

struct AttendanceView: View {
    @State private var viewModel: CourseListViewModel

    init(service: any StudentService) {
        _viewModel = State(initialValue: CourseListViewModel(service: service))
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
        .navigationTitle("Attendance Report")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await viewModel.loadSemesters() }
        .task(id: viewModel.selected) { await viewModel.loadCourses() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Theme.navy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            RetryMessage(message: message) { Task { await viewModel.retry() } }
        case .loaded(let courses) where courses.isEmpty:
            Text("No attendance for this semester yet.")
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let courses):
            // Re-evaluated every minute, so counts update as sessions finish.
            TimelineView(.everyMinute) { context in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(courses.sorted { $0.code < $1.code }) { course in
                            AttendanceCard(item: ScheduleCalendar.attendance(of: course, at: context.date))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AttendanceView(service: MockStudentService(delay: .zero))
    }
    .tint(.white)
}
