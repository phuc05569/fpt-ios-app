import SwiftUI

/// Horizontally scrolling semester picker shown at the top of the report screens.
struct SemesterChipBar: View {
    let semesters: [Semester]
    let selected: Semester?
    let onSelect: (Semester) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 9) {
                ForEach(semesters) { semester in
                    chip(semester, isSelected: semester == selected)
                }
            }
            .padding(.horizontal, 12)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()   // lets the selected chip's glow render outside the scroll bounds
        .padding(.top, 13)
    }

    private func chip(_ semester: Semester, isSelected: Bool) -> some View {
        Button {
            onSelect(semester)
        } label: {
            HStack(spacing: 7) {
                Image(systemName: symbolName(for: semester))
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? Theme.orange : Theme.chipIcon)
                    .frame(width: 22, height: 22)
                    .background(isSelected ? Color.white.opacity(0.25) : Theme.canvas, in: Circle())
                Text(semester.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isSelected ? Color.white : Theme.navy)
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .frame(height: 38)
            .background(isSelected ? Theme.orange : Color.white, in: Capsule())
            .overlay {
                if !isSelected {
                    Capsule().strokeBorder(Theme.chipBorder, lineWidth: 1)
                }
            }
            .shadow(color: isSelected ? Theme.orange.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    // Approximations of the screenshot's tree / sun / sprout icons.
    private func symbolName(for semester: Semester) -> String {
        if semester.name.hasPrefix("FALL") { return "tree.fill" }
        if semester.name.hasPrefix("SUMMER") { return "sun.max.fill" }
        return "leaf.fill"
    }
}
