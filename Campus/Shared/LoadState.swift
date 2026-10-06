import SwiftUI

enum LoadState<Value> {
    case loading
    case loaded(Value)
    case failed(String)
}

/// Error message with a Retry button, shown when loading fails.
struct RetryMessage: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: retry)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.orange)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
