import SwiftUI

struct AttendanceCard: View {
    let item: CourseAttendance

    private var course: Course { item.course }

    var body: some View {
        ReportCard(accent: Theme.orange, verticalPadding: 12) {
            HStack(spacing: 14) {
                AttendanceDonut(percent: item.percent)
                VStack(alignment: .leading, spacing: 0) {
                    title
                        .lineLimit(1)
                        .frame(height: 16.5, alignment: .leading)
                    line("Class name: \(course.className)")
                    line("Start date: \(course.startDay.formatted)")
                    line("End date: \(course.endDay.formatted)")
                    Text("Attended: \(item.attended)/\(item.held)")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(Theme.orange)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 2)
                        .overlay { Capsule().strokeBorder(Theme.orange, lineWidth: 1) }
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // Bold navy code followed by the regular grey course name.
    private var title: Text {
        Text(course.code)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Theme.navy)
        + Text(" - \(course.name)")
            .font(.system(size: 13))
            .foregroundStyle(Theme.textSecondary)
    }

    private func line(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Theme.textSecondary)
            .frame(height: 16.5, alignment: .leading)
    }
}

/// 56pt ring: orange base, green arc for the attended share, percentage in the middle.
struct AttendanceDonut: View {
    let percent: Double

    private let ringWidth: CGFloat = 9.5

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.orange, lineWidth: ringWidth)
                .padding(ringWidth / 2)
            Circle()
                .trim(from: 0, to: min(max(percent / 100, 0), 1))
                .stroke(Theme.green, lineWidth: ringWidth)
                .rotationEffect(.degrees(-90))
                .padding(ringWidth / 2)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.orange)
        }
        .frame(width: 56, height: 56)
    }

    /// "50", "62.5", "12.5": whole numbers without a decimal, as in the reference.
    private var label: String {
        String(format: "%g", (percent * 10).rounded() / 10)
    }
}
