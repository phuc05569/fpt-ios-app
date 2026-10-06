import SwiftUI

/// One day of the week: date label on the left, that day's sessions on the right.
/// Days without sessions keep a 55pt row, as in the reference.
struct TimetableDayRow: View {
    let day: CalendarDay
    let sessions: [ClassSession]
    let now: Date

    private static let dateColumnWidth: CGFloat = 82.5

    var body: some View {
        let emptyHeight: CGFloat? = sessions.isEmpty ? 55 : nil
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    if index > 0 {
                        Rectangle().fill(Theme.divider).frame(height: 0.5)
                    }
                    TimetableSessionRow(session: session, now: now)
                }
            }
            .padding(.leading, Self.dateColumnWidth)
            .frame(maxWidth: .infinity)
            .frame(height: emptyHeight)
            .background(alignment: .leading) { dateLabel }

            Rectangle().fill(Theme.chipBorder).frame(height: 1)
        }
    }

    private var dateLabel: some View {
        VStack(spacing: 1) {
            Text("\(day.day)/\(day.month)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.navy)
            Text(ScheduleCalendar.weekday(of: day).shortName)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(width: Self.dateColumnWidth)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .trailing) {
            Rectangle().fill(Theme.chipBorder).frame(width: 0.5)
        }
    }
}

struct TimetableSessionRow: View {
    let session: ClassSession
    let now: Date

    private var slot: Slot { session.meeting.slot }
    private var accent: Color { slot == .three ? Theme.slotThree : Theme.slotFour }
    private var isPresent: Bool { session.isPresent(at: now) }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            timeColumn
            details
        }
        .padding(.leading, 19)   // 4pt accent bar + 15pt gap
        .padding(.trailing, 14)
        .padding(.vertical, 12.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4)
                .padding(.vertical, 12.5)
        }
    }

    private var timeColumn: some View {
        VStack(spacing: 0) {
            Text("Slot \(slot.rawValue)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 48, height: 19)
                .background(accent.opacity(0.13), in: .rect(cornerRadius: 8))
            Text(slot.startText)
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.textTertiary)
                .padding(.top, 8.5)
            Rectangle()
                .fill(Theme.chipBorder)
                .frame(width: 1, height: 12)
                .padding(.vertical, 3)
            Text(slot.endText)
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(width: 48)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Room")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textTertiary)
                Text(session.meeting.room)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(Theme.navy)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.divider, in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.course.code)
                Text("SessionNo: \(session.number)")
                Text("Class: \(session.course.className)")
                Text("Lecturer: \(session.course.lecturer)")
            }
            .font(.system(size: 12.5))
            .foregroundStyle(Theme.textSecondary)
            .padding(.top, 6)

            HStack(spacing: 6) {
                Text(isPresent ? "PRESENT" : "NOT YET")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 63.5, height: 21.5)
                    .background(isPresent ? Theme.present : Theme.statusGrey, in: Capsule())
                // Visual only: there is no meeting URL data yet.
                Text("Meet URL")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 11)
                    .frame(height: 21.5)
                    .background(Theme.green, in: Capsule())
            }
            .padding(.top, 8)
        }
    }
}
