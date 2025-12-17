import SwiftUI

/// ラベル付きテキストフィールドビュー
struct LabeledTextFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
    }
}

#Preview {
    VStack {
        LabeledTextFieldView(label: "タイトル:", placeholder: "作品タイトル", text: .constant(""))
        LabeledTextFieldView(label: "APIキー:", placeholder: "Google AI API Key", text: .constant(""), isSecure: true)
    }
    .padding()
}
