// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manga Creation Form View
/// 漫画作成の入力フォーム
struct MangaCreationFormView: View {
    @ObservedObject var viewModel: MangaCreationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            Text("漫画作成")
                .font(.headline)
                .padding(.top, 8)

            Text("1〜4コマの漫画を作成します。各コマにキャラクターを配置し、セリフと特徴を設定できます。")
                .font(.caption)
                .foregroundColor(.secondary)

            // MARK: - Panels
            ForEach(Array(viewModel.panels.enumerated()), id: \.element.id) { index, panel in
                MangaPanelFormView(
                    panel: panel,
                    panelIndex: index,
                    canRemove: viewModel.canRemovePanel,
                    onRemove: {
                        viewModel.removePanel(at: index)
                    }
                )
            }

            // MARK: - Add Panel Button
            if viewModel.canAddPanel {
                Button(action: {
                    viewModel.addPanel()
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("コマを追加")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Manga Panel Form View
/// 1コマ分の入力フォーム
struct MangaPanelFormView: View {
    @ObservedObject var panel: MangaPanel
    let panelIndex: Int
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Panel Header
                HStack {
                    Text("コマ \(panelIndex + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    if canRemove {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Scene (Required)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("シーン")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("※位置情報を含めると精度向上")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    TextField("シーン", text: $panel.scene, prompt: Text("例: ビーチを走る二人。左側にこよみ、右隣にりん。"))
                        .textFieldStyle(.roundedBorder)
                }

                // MARK: - Narration (Optional)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ナレーション")
                        .font(.caption)
                        .fontWeight(.medium)
                    TextField("ナレーション", text: $panel.narration, prompt: Text("ナレーション（任意）"))
                        .textFieldStyle(.roundedBorder)
                }

                // MARK: - Narration Position
                HStack {
                    Text("ナレーション位置")
                        .font(.caption)
                        .fontWeight(.medium)
                    Picker("", selection: $panel.narrationPosition) {
                        ForEach(NarrationPosition.allCases, id: \.self) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)

                    // 縦書きインジケーター
                    if panel.narrationPosition.isVertical {
                        Text("（縦書き）")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Mob Characters Toggle
                HStack(spacing: 16) {
                    Toggle(isOn: $panel.hasMobCharacters) {
                        Text("モブキャラを含める")
                            .font(.caption)
                    }
                    .toggleStyle(.checkbox)
                    .help("群衆・通行人など背景の人物を描画します")

                    // 「モブもしっかり描く」は hasMobCharacters がオンの時のみ表示
                    if panel.hasMobCharacters {
                        Toggle(isOn: $panel.drawMobsClearly) {
                            Text("モブもしっかり描く")
                                .font(.caption)
                        }
                        .toggleStyle(.checkbox)
                        .help("オフ: モブはぼやける（被写界深度）\nオン: モブもはっきり描く")
                    }
                }

                Divider()

                // MARK: - Characters
                Text("キャラクター")
                    .font(.caption)
                    .fontWeight(.medium)

                // 横並びのキャラクタースロット
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(panel.characters.enumerated()), id: \.element.id) { charIndex, character in
                        PanelCharacterSlotView(
                            character: character,
                            characterIndex: charIndex,
                            canRemove: panel.canRemoveCharacter,
                            onRemove: {
                                panel.removeCharacter(at: charIndex)
                            }
                        )
                    }

                    // 追加ボタン
                    if panel.canAddCharacter {
                        Button(action: {
                            panel.addCharacter()
                        }) {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20))
                                Text("追加")
                                    .font(.caption2)
                            }
                            .frame(width: 80, height: 100)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Panel Character Slot View
/// コマ内のキャラクタースロット（ドラッグ＆ドロップ対応）
struct PanelCharacterSlotView: View {
    @ObservedObject var character: PanelCharacter
    let characterIndex: Int
    let canRemove: Bool
    let onRemove: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Character Header
            HStack {
                Text("キャラ \(characterIndex + 1)")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                if canRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 120)

            // MARK: - Character Name (Required)
            VStack(alignment: .leading, spacing: 2) {
                Text("名前")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.name, prompt: Text("キャラ名（必須）"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 120)
            }

            // MARK: - Image Drop Zone
            ZStack {
                if character.imagePath.isEmpty {
                    // 空のスロット
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(isTargeted ? .accentColor : .gray)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
                        )

                    VStack(spacing: 2) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("D&D")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    // 画像プレビュー
                    if let nsImage = NSImage(contentsOfFile: character.imagePath) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        // 画像読み込み失敗
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                    Text("読込失敗")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            )
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
            .onTapGesture {
                selectImage()
            }

            // MARK: - Dialogue
            VStack(alignment: .leading, spacing: 2) {
                Text("セリフ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.dialogue, prompt: Text("セリフ"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 120)
            }

            // MARK: - Features
            VStack(alignment: .leading, spacing: 2) {
                Text("特徴")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.features, prompt: Text("表情・ポーズ"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 120)
            }
        }
        .frame(width: 120, alignment: .leading)  // 固定幅でずれ防止
    }

    // MARK: - Drop Handling
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
            guard error == nil,
                  let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  isImageFile(url: url) else {
                return
            }

            DispatchQueue.main.async {
                character.imagePath = url.path
            }
        }
        return true
    }

    private func isImageFile(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["png", "jpg", "jpeg"].contains(ext)
    }

    // MARK: - File Selection
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg]

        if panel.runModal() == .OK, let url = panel.url {
            character.imagePath = url.path
        }
    }
}

// MARK: - Preview
#Preview {
    MangaCreationFormView(viewModel: MangaCreationViewModel())
        .frame(width: 500)
        .padding()
}
