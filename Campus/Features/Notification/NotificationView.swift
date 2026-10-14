import SwiftUI

/// Notification screen: search box with an orange search button over the notification list.
/// The reference shows an empty list, so the empty state is what normally appears.
struct NotificationView: View {
    let service: any StudentService
    @State private var state: LoadState<[Message]> = .loading
    @State private var draft = ""
    @State private var query = ""   // applied when the search button or the keyboard's Search key is pressed

    init(service: any StudentService) {
        self.service = service
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("Search", text: $draft, prompt: Text("Search...").foregroundStyle(Theme.textTertiary))
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.navy)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { query = draft }
                Button {
                    query = draft
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 37.5, height: 37.5)
                        .background(Theme.orange, in: .rect(cornerRadius: 10))
                }
                .accessibilityLabel("Search")
            }
            .padding(.leading, 15)
            .padding(.trailing, 6)
            .frame(height: 53.5)
            .background {   // shadow on the shape only, so the text is not shadowed
                RoundedRectangle(cornerRadius: 12.5).fill(Theme.card).shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12.5)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Notification")
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
        case .loaded(let notifications):
            let shown = notifications.filter { $0.matches(query) }
            ScrollView {
                if shown.isEmpty {
                    DecoratedEmptyState(title: "Showing \(shown.count) results", message: "Try searching with a different keyword.") {
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
            state = .loaded(try await service.notifications())
        } catch is CancellationError {
            // View went away; nothing to report.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack { NotificationView(service: MockStudentService(delay: .zero)) }.tint(.white)
}
