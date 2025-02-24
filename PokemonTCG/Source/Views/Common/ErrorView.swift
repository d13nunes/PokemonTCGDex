import SwiftUI

struct ErrorView: View {
  let message: String
  let onRetry: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 50))
        .foregroundColor(.red)

      Text(message)
        .font(.headline)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)

      Button(action: onRetry) {
        Text("Try Again")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .background(Color.blue)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
    .padding()
  }
}

#Preview {
  ErrorView(
    message: "Something went wrong. Please try again.",
    onRetry: {}
  )
}
