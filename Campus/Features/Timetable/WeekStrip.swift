import SwiftUI

/// Month title with prev/next arrows, weekday labels and the seven date cells.
/// Dots mark days that have sessions. Geometry measured from the reference screenshots.
struct WeekStrip: View {
    let title: String
    let days: [CalendarDay]
    let selected: CalendarDay
    let daysWithSessions: Set<CalendarDay>
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSelect: (CalendarDay) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 8.5)
            weekdayLabels
                .padding(.top, 6)
            dateCells
                .padding(.top, 10.75)
        }
        .padding(.bottom, 10.25)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) { hairline }
        .overlay(alignment: .bottom) { hairline }
    }

    private var hairline: some View {
        Rectangle().fill(Theme.statusGrey).frame(height: 0.5)
    }

    private var header: some View {
        ZStack {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.navy)
            HStack {
                arrowButton("arrowtriangle.left.fill", alignment: .leading, action: onPrevious)
                Spacer()
                arrowButton("arrowtriangle.right.fill", alignment: .trailing, action: onNext)
            }
        }
        .frame(height: 18)
    }

    private func arrowButton(_ symbol: String, alignment: Alignment, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 9))
                .foregroundStyle(Theme.navy)
                .padding(alignment == .leading ? .leading : .trailing, 11.5)
                .frame(width: 56, height: 30, alignment: alignment)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var weekdayLabels: some View {
        HStack(spacing: 0) {
            ForEach(Weekday.allCases, id: \.self) { weekday in
                Text(weekday.shortName)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dateCells: some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                dateCell(day)
            }
        }
    }

    private func dateCell(_ day: CalendarDay) -> some View {
        let isSelected = day == selected
        return Button {
            onSelect(day)
        } label: {
            ZStack {
                if isSelected {
                    Circle().fill(Theme.navy).frame(width: 30, height: 30)
                }
                Text("\(day.day)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Theme.navy)
                if daysWithSessions.contains(day) {
                    Circle()
                        .fill(isSelected ? Color.white : Theme.navy)
                        .frame(width: 4, height: 4)
                        .offset(y: 9.5)
                }
            }
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
