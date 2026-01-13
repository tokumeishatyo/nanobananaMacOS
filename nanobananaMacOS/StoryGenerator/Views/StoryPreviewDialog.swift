// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Story Preview Dialog
/// YAML生成確認ダイアログ
struct StoryPreviewDialog: View {
    let yaml: String
    let suggestedFileName: String
    let onSaved: () -> Void
    let onCancel: () -> Void

    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("確認")
                    .font(.headline)
                Spacer()
                Text("内容を確認してファイル保存してください")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

                Button("ファイル保存") {
                    saveToFile()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
        }
        .frame(width: 600, height: 550)
        .alert("保存エラー", isPresented: $showSaveError) {
            Button("OK") {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: - Save to File
    private func saveToFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "yaml") ?? .plainText]
        savePanel.nameFieldStringValue = suggestedFileName
        savePanel.title = "ストーリーYAMLを保存"
        savePanel.message = "漫画コンポーザーで読み込むYAMLファイルを保存します"

        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                try yaml.write(to: url, atomically: true, encoding: .utf8)
                onSaved()
            } catch {
                saveErrorMessage = "ファイルの保存に失敗しました: \(error.localizedDescription)"
                showSaveError = true
            }
        }
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
        suggestedFileName: "story.yaml",
        onSaved: {},
        onCancel: {}
    )
}
