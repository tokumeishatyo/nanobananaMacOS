// rule.mdを読むこと
import SwiftUI

// MARK: - Inset Settings View
/// インセット設定UI（render_mode: inset_visualization時に表示）
/// 夢・回想・テレビ画面など、吹き出し内に別世界を描画する設定
struct InsetSettingsView: View {
    @ObservedObject var character: PanelCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: - Section Header
            HStack {
                Image(systemName: "sparkles.rectangle.stack")
                    .foregroundColor(.purple)
                Text("インセット設定")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }

            Divider()

            // MARK: - Frame & World (枠と世界観)
            InsetFrameSettingsView(character: character)

            Divider()

            // MARK: - Actor & Acting (キャラクターと演技)
            InsetActorSettingsView(character: character)

            Divider()

            // MARK: - Visual Adjustments (ビジュアル調整 - UI選択)
            InsetVisualSettingsView(character: character)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Inset Frame Settings View
/// 枠と世界観の設定（ストーリーYAML用テキスト入力）
struct InsetFrameSettingsView: View {
    @ObservedObject var character: PanelCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("枠と世界観")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // Container Type (枠の形状)
            VStack(alignment: .leading, spacing: 2) {
                Text("枠の形状")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.containerType,
                         prompt: Text("例: fluffy thought bubble, TV screen"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Internal Background (背景)
            VStack(alignment: .leading, spacing: 2) {
                Text("背景")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.internalBackground,
                         prompt: Text("例: castle ballroom, starry sky"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Inset Actor Settings View
/// キャラクターと演技の設定（ストーリーYAML用テキスト入力）
struct InsetActorSettingsView: View {
    @ObservedObject var character: PanelCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("キャラクターと演技")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // Internal Outfit (衣装)
            VStack(alignment: .leading, spacing: 2) {
                Text("衣装")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.internalOutfit,
                         prompt: Text("例: pink ball gown, tiara"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Internal Emotion (表情)
            VStack(alignment: .leading, spacing: 2) {
                Text("表情")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.internalEmotion,
                         prompt: Text("例: blushing, lovestruck"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Internal Situation (行動)
            VStack(alignment: .leading, spacing: 2) {
                Text("行動")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.internalSituation,
                         prompt: Text("例: dancing waltz with prince"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Guest Name (ゲスト名)
            VStack(alignment: .leading, spacing: 2) {
                Text("ゲスト名")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.guestName,
                         prompt: Text("例: Prince, Monster（任意）"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Guest Description (ゲスト外見)
            VStack(alignment: .leading, spacing: 2) {
                Text("ゲスト外見")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.guestDescription,
                         prompt: Text("例: handsome blonde prince（任意）"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // Internal Dialogue (セリフ)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("セリフ")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("形式: キャラ名: 'セリフ'")
                        .font(.caption2)
                        .foregroundColor(.purple.opacity(0.7))
                }
                TextField("", text: $character.internalDialogue,
                         prompt: Text("例: Prince: 'You are beautiful.'"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Inset Visual Settings View
/// ビジュアル調整（UI選択 - autoオプション付き）
struct InsetVisualSettingsView: View {
    @ObservedObject var character: PanelCharacter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ビジュアル調整")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // 2列グリッドで表示
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                // Internal Reference (参照画像)
                VStack(alignment: .leading, spacing: 2) {
                    Text("参照")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.internalReference) {
                        ForEach(InternalReference.allCases, id: \.self) { ref in
                            Text(ref.displayLabel).tag(ref)
                        }
                    }
                    .labelsHidden()
                }

                // Internal Shot Type (構図)
                VStack(alignment: .leading, spacing: 2) {
                    Text("構図")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.internalShotType) {
                        ForEach(InternalShotType.allCases, id: \.self) { shot in
                            Text(shot.displayLabel).tag(shot)
                        }
                    }
                    .labelsHidden()
                }

                // Internal Lighting (照明)
                VStack(alignment: .leading, spacing: 2) {
                    Text("照明")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.internalLighting) {
                        ForEach(InternalLighting.allCases, id: \.self) { light in
                            Text(light.displayLabel).tag(light)
                        }
                    }
                    .labelsHidden()
                }

                // Internal Filter (フィルタ)
                VStack(alignment: .leading, spacing: 2) {
                    Text("フィルタ")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.internalFilter) {
                        ForEach(InternalFilter.allCases, id: \.self) { filter in
                            Text(filter.displayLabel).tag(filter)
                        }
                    }
                    .labelsHidden()
                }

                // Inset Border Style (枠線)
                VStack(alignment: .leading, spacing: 2) {
                    Text("枠線")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.insetBorderStyle) {
                        ForEach(InsetBorderStyle.allCases, id: \.self) { border in
                            Text(border.displayLabel).tag(border)
                        }
                    }
                    .labelsHidden()
                }

                // Internal Bubble Style (吹き出し)
                VStack(alignment: .leading, spacing: 2) {
                    Text("吹き出し")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Picker("", selection: $character.internalBubbleStyle) {
                        ForEach(InternalBubbleStyle.allCases, id: \.self) { bubble in
                            Text(bubble.displayLabel).tag(bubble)
                        }
                    }
                    .labelsHidden()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let character = PanelCharacter()
    character.renderMode = .insetVisualization
    return InsetSettingsView(character: character)
        .frame(width: 300)
        .padding()
}
