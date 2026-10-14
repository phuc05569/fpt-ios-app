import SwiftUI

/// Exam schedule: semester chips and a count row stay pinned while the exam cards scroll beneath them.
/// Opens on SUMMER2026, the semester shown in the reference (user decision).
struct ExamScheduleView: View {
    let service: any StudentService
    let startingSemester: String

    @State private var semesters: [Semester] = []
    @State private var selected: Semester?
    @State private var state: LoadState<[Exam]> = .loading

    init(service: any StudentService, startingSemester: String = "SUMMER2026") {
        self.service = service
        self.startingSemester = startingSemester
    }

    var body: some View {
        VStack(spacing: 0) {
            SemesterChipBar(semesters: semesters, selected: selected) { selected = $0 }
            countRow
                .padding(.horizontal, 16)
                .padding(.top, 25.5)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Exam schedule")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await loadSemesters() }
        .task(id: selected) { await loadExams() }
    }

    private var countRow: some View {
        HStack(spacing: 12) {
            Text("Number of exams: \(exams.count)")
                .font(.system(size: 13.5, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 14.5)
                .frame(height: 21.5)
                .background(Theme.bar, in: Capsule())
                .padding(.leading, 0.5)
            Text("Date format: dd/mm/yyyy")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Button {
                Task { await loadExams() }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 32.5, height: 24.5)
                    .background(Theme.bar, in: Capsule())
            }
            .accessibilityLabel("Refresh")
        }
    }

    private var exams: [Exam] {
        if case .loaded(let exams) = state { return exams }
        return []
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            ProgressView().tint(Theme.navy).frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            RetryMessage(message: message) { Task { await loadExams() } }
        case .loaded(let exams):
            ScrollView {
                LazyVStack(spacing: 12.5) {
                    ForEach(Array(exams.enumerated()), id: \.offset) { index, exam in
                        ExamCard(exam: exam, number: index + 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 9)
                .padding(.bottom, 16)
            }
            .overlay(alignment: .top) {
                // Cards fade out under the pinned header, as in the scrolled references.
                LinearGradient(colors: [Theme.canvas, Theme.canvas.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 9)
                    .allowsHitTesting(false)
            }
        }
    }

    private func loadSemesters() async {
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

    private func loadExams() async {
        guard let semester = selected else { return }
        state = .loading
        do {
            state = .loaded(try await service.exams(for: semester))
        } catch is CancellationError {
            // Superseded by a newer selection.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

/// Grey card with a 4pt grey top bar. Measured: 170.5pt tall, header row centred 34.5pt from the top,
/// divider at 63pt, then four 21pt-pitch detail lines.
struct ExamCard: View {
    let exam: Exam
    let number: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.textTertiary)
                    .frame(width: 28)
                Text("Date: \(exam.dateText)")
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.leading, 14.25)
                Spacer(minLength: 8)
                Text(exam.status)
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                Text("#\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 9)
                    .frame(height: 19)
                    .background(Theme.bar, in: Capsule())
                    .padding(.leading, 19.5)
            }
            .padding(.leading, 16.75)
            .padding(.trailing, 14)
            .frame(height: 57)
            .padding(.top, 6)

            Theme.chipBorder
                .frame(height: 1)
                .padding(.horizontal, 14.5)

            VStack(alignment: .leading, spacing: 5.5) {
                detail("Subject:", exam.subject)
                detail("Room:", exam.room)
                detail("Time:", exam.time)
                detail("Type:", exam.type)
            }
            .padding(.horizontal, 14.5)
            .padding(.top, 9.5)
            .padding(.bottom, 19.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.subtle)
        .overlay(alignment: .top) {
            Theme.textTertiary.frame(height: 4)
        }
        .clipShape(.rect(cornerRadius: Theme.cardRadius))
        .accessibilityElement(children: .combine)
    }

    private func detail(_ label: String, _ value: String) -> some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textTertiary)
        }
    }
}

#Preview {
    NavigationStack { ExamScheduleView(service: MockStudentService(delay: .zero)) }.tint(.white)
}
