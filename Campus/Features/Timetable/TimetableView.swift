import SwiftUI

struct TimetableView: View {
    @State private var viewModel: CourseListViewModel
    @State private var selectedDay = ScheduleCalendar.day(of: .now)

    init(service: any StudentService) {
        _viewModel = State(initialValue: CourseListViewModel(service: service))
    }

    var body: some View {
        let weekDays = ScheduleCalendar.week(containing: selectedDay)
        let sessionsByDay = ScheduleCalendar.sessions(of: viewModel.courses, in: weekDays)

        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                SemesterChipBar(semesters: viewModel.semesters, selected: viewModel.selected) {
                    viewModel.selected = $0
                }
                Text("Current week: \(weekDays[0].formatted) – \(weekDays[6].formatted)")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 25)
                    .padding(.bottom, 6)
                WeekStrip(
                    title: ScheduleCalendar.monthTitle(of: weekDays[3]),
                    days: weekDays,
                    selected: selectedDay,
                    daysWithSessions: Set(sessionsByDay.keys),
                    onPrevious: { selectedDay = ScheduleCalendar.adding(-7, to: selectedDay) },
                    onNext: { selectedDay = ScheduleCalendar.adding(7, to: selectedDay) },
                    onSelect: { day in
                        selectedDay = day
                        withAnimation { proxy.scrollTo(day, anchor: .top) }
                    })
                list(weekDays: weekDays, sessionsByDay: sessionsByDay)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.canvas.ignoresSafeArea())
        }
        .navigationTitle("Weekly timetable")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await viewModel.loadSemesters() }
        .task(id: viewModel.selected) { await viewModel.loadCourses() }
    }

    @ViewBuilder
    private func list(weekDays: [CalendarDay], sessionsByDay: [CalendarDay: [ClassSession]]) -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Theme.navy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            RetryMessage(message: message) { Task { await viewModel.retry() } }
        case .loaded:
            // Re-evaluated every minute, so NOT YET turns into PRESENT as sessions end.
            TimelineView(.everyMinute) { context in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(weekDays, id: \.self) { day in
                            TimetableDayRow(day: day, sessions: sessionsByDay[day] ?? [], now: context.date)
                                .id(day)
                        }
                    }
                }
                .id(weekDays[0])   // new week starts scrolled to the top
            }
            .background(Color.white)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Theme.statusGrey).frame(height: 0.5)
            }
            .padding(.bottom, 30.5)
        }
    }
}

#Preview {
    NavigationStack {
        TimetableView(service: MockStudentService(delay: .zero))
    }
    .tint(.white)
}
