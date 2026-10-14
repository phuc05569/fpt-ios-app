import SwiftUI

/// Student Fee: navy balance card with the green "FPT DNG" button, then the paid-fees section.
/// The reference shows a 0.0 VND balance and no paid invoices.
struct StudentFeeView: View {
    let service: any StudentService
    /// Where "FPT DNG" leads. Not visible in the reference, so it is unset and the button does nothing yet.
    let paymentURL: URL?

    @Environment(\.openURL) private var openURL
    @State private var state: LoadState<Double> = .loading

    init(service: any StudentService, paymentURL: URL? = nil) {
        self.service = service
        self.paymentURL = paymentURL
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                balanceCard
                DemoNotice(text: DemoNotice.unofficial)
                    .padding(.top, 12)
                Text("STUDENT'S FEE HAVE BEEN PAID")
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.leading, 0.5)
                    .padding(.top, 21)
                    .accessibilityAddTraits(.isHeader)
                // shortcut: no invoice model yet (the reference has none); add one when a screenshot with paid fees arrives.
                DecoratedEmptyState(title: "No fee records found", message: "No invoices have been recorded for this account.") {
                    ReceiptGlyph().frame(width: 23.5, height: 31.5)
                }
                .padding(.top, 15)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Student Fee")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await load() }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 14.5) {
            HStack(spacing: 13.5) {
                WalletGlyph()
                    .frame(width: 21.5, height: 19)
                    .frame(width: 43.5, height: 43.5)
                    .background(Color.white.opacity(0.15), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("Balance")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: 0xCBD5E1))
                    Group {
                        switch state {
                        case .loaded(let balance): Text(verbatim: "\(balance) VND")   // Swift prints 0 as "0.0", as in the reference
                        case .loading: Text(" ")
                        case .failed: Text("–")
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
                }
            }
            Button {
                if let paymentURL { openURL(paymentURL) }
            } label: {
                Label("FPT DNG", systemImage: "arrow.up.right.square")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36.5)
                    .background(Theme.green, in: .rect(cornerRadius: 10))
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 16).fill(Theme.bar).shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        }
    }

    private func load() async {
        do {
            state = .loaded(try await service.feeBalance())
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

/// Wallet: white rounded body with a flap line and a clasp dot, drawn because SF Symbols has no close match.
private struct WalletGlyph: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3.5, style: .continuous)
            .fill(Color.white)
            .overlay(alignment: .top) {
                Theme.bar.opacity(0.9).frame(height: 1).padding(.top, 3).padding(.horizontal, 2)
            }
            .overlay(alignment: .trailing) {
                Circle().fill(Theme.bar).frame(width: 3.5, height: 3.5).padding(.trailing, 3).offset(y: 2)
            }
    }
}

/// Receipt with zig-zag top and bottom edges and three text lines (the Student Fee empty-state icon).
struct ReceiptGlyph: View {
    var body: some View {
        ReceiptShape()
            .fill(Color(hex: 0x94A3B8))
            .overlay {
                VStack(spacing: 4.5) {
                    ForEach(0..<3, id: \.self) { _ in
                        Capsule().fill(Color(light: 0xD8E0EA, dark: 0x2E3B50)).frame(width: 14, height: 2)
                    }
                }
            }
    }
}

private struct ReceiptShape: Shape {
    func path(in rect: CGRect) -> Path {
        let teeth = 4
        let step = rect.width / CGFloat(teeth)
        let depth: CGFloat = 2.5
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        for i in 0..<teeth {   // top edge, left to right
            path.addLine(to: CGPoint(x: rect.minX + step * (CGFloat(i) + 0.5), y: rect.minY + depth))
            path.addLine(to: CGPoint(x: rect.minX + step * CGFloat(i + 1), y: rect.minY))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        for i in (0..<teeth).reversed() {   // bottom edge, right to left
            path.addLine(to: CGPoint(x: rect.minX + step * (CGFloat(i) + 0.5), y: rect.maxY - depth))
            path.addLine(to: CGPoint(x: rect.minX + step * CGFloat(i), y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack { StudentFeeView(service: MockStudentService(delay: .zero)) }.tint(.white)
}
