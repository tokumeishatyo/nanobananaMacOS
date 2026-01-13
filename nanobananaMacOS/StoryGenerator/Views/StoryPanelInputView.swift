// rule.mdを読むこと
import SwiftUI

// MARK: - Story Panel Input View
/// コマ入力部品
struct StoryPanelInputView: View {
    @ObservedObject var panel: StoryPanel
    let panelMode: StoryPanelMode
    let selectedCharacters: [SavedCharacter]

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Panel Header
                HStack {
                    Text("コマ\(panel.panelNumber)")
                        .font(.headline)

                    Spacer()

                    // キャラクター数表示
                    Text("\(panel.characters.count)/\(StoryGeneratorViewModel.maxCharactersPerPanel)人")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // MARK: - Scene Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("シーン（必須）")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("場所、状況を入力", text: $panel.scene, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }

                // MARK: - Narration Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("ナレーション")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    TextField("ナレーション（任意）", text: $panel.narration, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                }

                // MARK: - Mob Toggle
                Toggle("モブを含める", isOn: $panel.hasMob)
                    .toggleStyle(.checkbox)

                Divider()

                // MARK: - Characters Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("キャラクター")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        if panel.canAddCharacter && !selectedCharacters.isEmpty {
                            Button(action: { panel.addCharacter() }) {
                                Label("追加", systemImage: "plus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                    }

                    if panel.characters.isEmpty {
                        Text("「追加」ボタンでキャラクターを追加してください")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(Array(panel.characters.enumerated()), id: \.element.id) { index, character in
                            StoryPanelCharacterInputView(
                                character: character,
                                index: index,
                                panelMode: panelMode,
                                selectedCharacters: selectedCharacters,
                                canRemove: panel.canRemoveCharacter,
                                onRemove: { panel.removeCharacter(at: index) }
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview
#Preview {
    let panel = StoryPanel(panelNumber: 1)
    return StoryPanelInputView(
        panel: panel,
        panelMode: .single,
        selectedCharacters: []
    )
    .frame(width: 550)
    .padding()
}
