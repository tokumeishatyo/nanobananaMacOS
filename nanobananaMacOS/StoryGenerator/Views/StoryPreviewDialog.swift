// rule.mdを読むこと
import SwiftUI

// MARK: - Story Preview Dialog
/// YAML生成確認ダイアログ
struct StoryPreviewDialog: View {
    let yaml: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("確認")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // MARK: - YAML Preview
            ScrollView {
                VStack(alignment: .leading) {
                    Text(yaml)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .frame(maxHeight: 400)

            Divider()

            // MARK: - Action Buttons
            HStack {
                Button("戻る") {
                    onCancel()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("OK・コピー") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
        }
        .frame(width: 550, height: 500)
    }
}

// MARK: - Preview
#Preview {
    StoryPreviewDialog(
        yaml: """
        title: "テストストーリー"

        actors:
          actor_A:
            name: "テストキャラ"
            face_reference: ""
            chibi_reference: ""

        panels:
          - panel: 1
            scene: "test scene"
            narration: "テストナレーション"
            mob: false
            characters:
              - actor: "actor_A"
                name: "テストキャラ"
                render_mode: "full_body"
                dialogue: "テストセリフ"
                features: "smiling"
        """,
        onConfirm: {},
        onCancel: {}
    )
}
