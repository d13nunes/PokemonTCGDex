import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  let onTextChanged: (String) -> Void
  @FocusState private var isFocused: Bool

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
        .frame(width: 20, height: 20)

      TextField("Search cards...", text: $text)
        .textFieldStyle(.plain)
        .focused($isFocused)
        .onChange(of: text) { _, newValue in
          onTextChanged(newValue)
        }
        .font(.body)
        .tint(.blue)

      if !text.isEmpty {
        Button(action: {
          text = ""
          onTextChanged("")
          isFocused = false
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(Color(.systemGray3))
            .frame(width: 20, height: 20)
        }
        .transition(.opacity)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color(.systemGray6))
    .cornerRadius(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color(.systemGray4), lineWidth: 0.5)
    )
    .onAppear {
      isFocused = true
      isFocused = false
    }
  }
}

#Preview {
  VStack {
    SearchBar(text: .constant(""), onTextChanged: { _ in })
    SearchBar(text: .constant("Pikachu"), onTextChanged: { _ in })
  }
  .padding()
}
