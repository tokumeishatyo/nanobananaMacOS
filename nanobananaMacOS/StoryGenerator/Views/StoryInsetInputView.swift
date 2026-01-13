// rule.mdを読むこと
import SwiftUI

// MARK: - Story Inset Input View
/// インセット入力部品（inset_visualization時のみ表示）
struct StoryInsetInputView: View {
    @ObservedObject var character: StoryPanelCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Internal Background（必須）
            VStack(alignment: .leading, spacing: 4) {
                Text("背景（必須）")
                    .font(.caption)
                TextField("背景を入力（例: castle ballroom, chandeliers）", text: $character.internalBackground, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...2)
            }

            // MARK: - Internal Outfit
            VStack(alignment: .leading, spacing: 4) {
                Text("衣装")
                    .font(.caption)
                TextField("衣装を入力（任意、例: pink ball gown, tiara）", text: $character.internalOutfit, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...2)
            }

            // MARK: - Internal Situation（必須）
            VStack(alignment: .leading, spacing: 4) {
                Text("行動（必須）")
                    .font(.caption)
                TextField("行動を入力（例: dancing waltz with prince）", text: $character.internalSituation, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...2)
            }

            // MARK: - Internal Emotion（必須）
            VStack(alignment: .leading, spacing: 4) {
                Text("表情（必須）")
                    .font(.caption)
                TextField("表情を入力（例: blushing, lovestruck）", text: $character.internalEmotion, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...2)
            }

            // MARK: - Internal Dialogue
            VStack(alignment: .leading, spacing: 4) {
                Text("インセット内セリフ")
                    .font(.caption)
                TextField("インセット内のセリフ（任意）", text: $character.internalDialogue, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...2)
            }

            Divider()

            // MARK: - Guests Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("ゲスト")
                        .font(.caption)
                        .fontWeight(.medium)

                    Text("（最大\(StoryGeneratorViewModel.maxGuestsPerInset)人）")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if character.canAddGuest {
                        Button(action: { character.addGuest() }) {
                            Label("追加", systemImage: "plus.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                    }
                }

                if character.guests.isEmpty {
                    Text("ゲストなし（必要な場合は「追加」）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 2)
                } else {
                    ForEach(Array(character.guests.enumerated()), id: \.element.id) { index, guest in
                        StoryGuestInputView(
                            guest: guest,
                            index: index,
                            canRemove: character.canRemoveGuest,
                            onRemove: { character.removeGuest(at: index) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Story Guest Input View
/// ゲスト入力部品
struct StoryGuestInputView: View {
    @ObservedObject var guest: StoryGuest
    let index: Int
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Text("ゲスト \(index + 1)")
                        .font(.caption2)
                        .fontWeight(.medium)

                    Spacer()

                    if canRemove {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ゲスト名
                HStack {
                    Text("名前:")
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    TextField("ゲスト名", text: $guest.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }

                // ゲスト外見
                HStack {
                    Text("外見:")
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    TextField("外見を入力", text: $guest.guestDescription)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }

                // ゲストのセリフ
                HStack {
                    Text("セリフ:")
                        .font(.caption)
                        .frame(width: 50, alignment: .leading)
                    TextField("セリフ（任意）", text: $guest.dialogue)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }
            .padding(.vertical, 2)
        }
        .background(Color.blue.opacity(0.03))
    }
}

// MARK: - Preview
#Preview {
    let character = StoryPanelCharacter()
    character.renderMode = .insetVisualization
    return StoryInsetInputView(character: character)
        .frame(width: 500)
        .padding()
}
