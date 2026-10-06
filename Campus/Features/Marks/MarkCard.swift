import SwiftUI

struct MarkCard: View {
    let mark: CourseMark

    private var tint: Color { mark.status == .passed ? Theme.green : Theme.red }

    private var statusText: String {
        switch mark.status {
        case .passed: "Passed"
        case .notPassed: "Not passed"
        case .exempted: "Exempted"
        }
    }

    var body: some View {
        ReportCard(accent: tint) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    title
                        .lineSpacing(2.4)
                        .padding(.bottom, 2.4)   // the reference gives every title line an 18pt box, including the last
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusPill(text: statusText, color: tint)
                }

                Rectangle()
                    .fill(Theme.divider)
                    .frame(height: 1)
                    .padding(.top, 8.5)

                Text("Class name: \(mark.className)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 9)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("Average:")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                    if let average = mark.average {
                        Text(String(format: "%.1f", average))   // "." regardless of device locale, as in the screenshot
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(tint)
                    }
                }
                .padding(.top, 6.5)
            }
        }
    }

    // Bold navy code followed by the regular grey course name, wrapping as one paragraph.
    // Some entries (e.g. exempted courses) have no separate name.
    private var title: Text {
        let code = Text(mark.courseCode)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Theme.navy)
        guard !mark.courseName.isEmpty else { return code }
        return code + Text(" - \(mark.courseName)")
            .font(.system(size: 13))
            .foregroundStyle(Theme.textSecondary)
    }
}
