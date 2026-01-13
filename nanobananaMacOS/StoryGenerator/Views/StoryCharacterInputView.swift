// rule.mdを読むこと
import SwiftUI

// MARK: - Story Character Input View
/// キャラクター入力部品
struct StoryPanelCharacterInputView: View {
    @ObservedObject var character: StoryPanelCharacter
    let index: Int
    let panelMode: StoryPanelMode
    let selectedCharacters: [SavedCharacter]
    let canRemove: Bool
    let onRemove: () -> Void

    /// 利用可能なrender_mode
    private var availableRenderModes: [StoryRenderMode] {
        if panelMode == .fourPanel {
            return StoryRenderMode.fourPanelModes
        } else {
            return StoryRenderMode.allCases
        }
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                // MARK: - Header
                HStack {
                    Text("キャラクター \(index + 1)")
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    if canRemove {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Character Selection
                HStack {
                    Text("キャラ:")
                        .frame(width: 80, alignment: .leading)

                    Picker("", selection: $character.selectedCharacterId) {
                        Text("選択してください").tag(nil as UUID?)
                        ForEach(selectedCharacters) { char in
                            Text(char.name).tag(char.id as UUID?)
                        }
                    }
                    .labelsHidden()
                }

                // MARK: - Render Mode Selection
                HStack {
                    Text("描画モード:")
                        .frame(width: 80, alignment: .leading)

                    Picker("", selection: $character.renderMode) {
                        ForEach(availableRenderModes, id: \.self) { mode in
                            Text(mode.displayLabel).tag(mode)
                        }
                    }
                    .labelsHidden()
                }

                // MARK: - Mode-specific Fields
                if character.renderMode == .insetVisualization {
                    // インセットモード
                    insetInputFields
                } else {
                    // 通常モード（full_body, bubble_only, text_only）
                    normalInputFields
                }
            }
            .padding(.vertical, 4)
        }
        .background(Color.gray.opacity(0.05))
    }

    // MARK: - Normal Input Fields
    @ViewBuilder
    private var normalInputFields: some View {
        // セリフ
        VStack(alignment: .leading, spacing: 4) {
            Text("セリフ")
                .font(.caption)
            TextField("セリフ（任意）", text: $character.dialogue, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...2)
        }

        // features（必須）
        VStack(alignment: .leading, spacing: 4) {
            Text("features（必須）")
                .font(.caption)
            TextField("表情、ポーズを入力", text: $character.features, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...2)
        }
    }

    // MARK: - Inset Input Fields
    @ViewBuilder
    private var insetInputFields: some View {
        StoryInsetInputView(character: character)
    }
}

// MARK: - Preview
#Preview {
    let character = StoryPanelCharacter()
    return StoryPanelCharacterInputView(
        character: character,
        index: 0,
        panelMode: .single,
        selectedCharacters: [
            SavedCharacter(name: "テストキャラ", faceFeatures: "黒髪ロング")
        ],
        canRemove: true,
        onRemove: {}
    )
    .frame(width: 500)
    .padding()
}
