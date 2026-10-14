import SwiftUI

/// Messages tab: a live-filtered list of messages, measured from the Messages reference screenshot.
struct MessagesView: View {
    let service: any StudentService
    @State private var state: LoadState<[Message]> = .loading
    @State private var query = ""

    // Explicit: private @State properties would make the synthesized memberwise init private.
    init(service: any StudentService) {
        self.service = service
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                Text("🔍").font(.system(size: 15))   // the reference shows the emoji magnifier
                TextField("Search", text: $query, prompt: Text("Search...").foregroundStyle(Theme.textTertiary))
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.navy)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
            }
            .padding(.horizontal, 15)
            .frame(height: 36.5)
            .background {   // shadow on the shape only, so the text is not shadowed
                RoundedRectangle(cornerRadius: 12.5).fill(Theme.card).shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12.5)

            DemoNotice(text: DemoNotice.unofficial)   // the list includes attendance updates
                .padding(.horizontal, 16)
                .padding(.top, 10)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
        .task { await load() }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            ProgressView().tint(Theme.navy).frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            RetryMessage(message: message) { Task { await load() } }
        case .loaded(let messages):
            let shown = messages.filter { $0.matches(query) }
            ScrollView {
                if shown.isEmpty {
                    DecoratedEmptyState(title: "Showing 0 results", message: "Try searching with a different keyword.") {
                        Image(systemName: "bell.fill").font(.system(size: 29))
                    }
                    .padding(.top, 8.5)
                } else {
                    MessageList(messages: shown)
                        .padding(.top, 12.5)
                        .padding(.bottom, 16)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private func load() async {
        state = .loading
        do {
            state = .loaded(try await service.messages())
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

/// Rows shared by the Messages and Notification screens; each row opens the full message.
struct MessageList: View {
    let messages: [Message]

    var body: some View {
        LazyVStack(spacing: 10.5) {
            ForEach(messages) { message in
                NavigationLink {
                    MessageDetailView(message: message)
                } label: {
                    MessageRow(message: message)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct MessageRow: View {
    let message: Message
    var showsChevron = true

    var body: some View {
        ReportCard(accent: Theme.orange, verticalPadding: 12.5, leadingPadding: 10, trailingPadding: 12) {
            HStack(spacing: 11) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Theme.orange)
                    .frame(width: 41.5, height: 41.5)
                    .background(Color(light: 0xFFF7ED, dark: 0x4E402B), in: .rect(cornerRadius: 12.5))
                VStack(alignment: .leading, spacing: 0) {
                    Text(message.title)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(Theme.navy)
                    Text("\(message.age()) · \(message.sender)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(.top, 3)
                    Text(message.body)
                        .font(.system(size: 12.5))
                        .lineSpacing(2)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(light: 0xD1D5DB, dark: 0x4B5563))
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Opened from a message row. No reference screenshot yet: it shows the same card with the full text.
struct MessageDetailView: View {
    let message: Message

    var body: some View {
        ScrollView {
            MessageRow(message: message, showsChevron: false)
                .textSelection(.enabled)
                .padding(16)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(message.title)
        .navigationBarTitleDisplayMode(.inline)
        .navyNavigationBar()
    }
}

#Preview {
    NavigationStack { MessagesView(service: MockStudentService(delay: .zero)) }.tint(.white)
}
