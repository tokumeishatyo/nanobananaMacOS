// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manga Creation Form View
/// 漫画作成の入力フォーム
struct MangaCreationFormView: View {
    @ObservedObject var viewModel: MangaCreationViewModel
    let savedCharacters: [SavedCharacter]
    let savedWardrobes: [SavedWardrobe]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            HStack {
                Text("漫画作成")
                    .font(.headline)
                Spacer()
                // YAML読み込みボタン
                Button(action: openYAMLImport) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                        Text("YAML読み込み")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)

            Text("1〜4コマの漫画を作成します。登場人物と衣装を登録してから、各コマで組み合わせを選択してください。")
                .font(.caption)
                .foregroundColor(.secondary)

            // MARK: - 登場人物セクション
            ActorsSectionView(viewModel: viewModel, savedCharacters: savedCharacters)

            // MARK: - 衣装セクション
            WardrobesSectionView(viewModel: viewModel, savedWardrobes: savedWardrobes)

            // MARK: - 登録/クリアボタン
            RegistrationButtonsView(viewModel: viewModel)

            Divider()

            // MARK: - Panels
            ForEach(Array(viewModel.panels.enumerated()), id: \.element.id) { index, panel in
                MangaPanelFormView(
                    panel: panel,
                    panelIndex: index,
                    canRemove: viewModel.canRemovePanel,
                    registeredActors: viewModel.registeredActors,
                    registeredWardrobes: viewModel.registeredWardrobes,
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

    // MARK: - YAML Import

    /// YAML読み込みウィンドウを開く
    private func openYAMLImport() {
        WindowManager.shared.openMangaStoryImportWindow(
            savedCharacters: savedCharacters
        ) { yaml, matchResults in
            // インポート結果をViewModelに反映
            viewModel.applyImportedStory(
                yaml: yaml,
                matchResults: matchResults,
                savedCharacters: savedCharacters
            )
        }
    }
}

// MARK: - Actors Section View
/// 登場人物セクション
struct ActorsSectionView: View {
    @ObservedObject var viewModel: MangaCreationViewModel
    let savedCharacters: [SavedCharacter]

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Header
                HStack {
                    Text("登場人物")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("（1〜3人）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                // MARK: - Actors
                ForEach(Array(viewModel.actors.enumerated()), id: \.element.id) { index, actor in
                    ActorEntryView(
                        actor: actor,
                        actorIndex: index,
                        canRemove: viewModel.canRemoveActor,
                        savedCharacters: savedCharacters,
                        onRemove: {
                            viewModel.removeActor(at: index)
                        }
                    )
                }

                // MARK: - Add Actor Button
                if viewModel.canAddActor {
                    Button(action: {
                        viewModel.addActor()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("キャラを追加")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Actor Entry View
/// 登場人物の入力フォーム（1人分）
struct ActorEntryView: View {
    @ObservedObject var actor: ActorEntry
    let actorIndex: Int
    let canRemove: Bool
    let savedCharacters: [SavedCharacter]
    let onRemove: () -> Void

    private var actorLabel: String {
        let labels = ["A", "B", "C"]
        return "キャラ\(labels[actorIndex])"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Header
            HStack {
                Text(actorLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
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

            // MARK: - Character Selection (Required)
            HStack {
                Text("キャラクタ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)

                if savedCharacters.isEmpty {
                    Text("キャラクタが未登録です")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Picker("", selection: Binding(
                        get: { actor.selectedCharacterId },
                        set: { newId in
                            if let id = newId,
                               let character = savedCharacters.first(where: { $0.id == id }) {
                                actor.selectCharacter(character)
                            } else {
                                actor.clearSelection()
                            }
                        }
                    )) {
                        Text("選択してください").tag(nil as UUID?)
                        ForEach(savedCharacters) { character in
                            Text(character.name).tag(character.id as UUID?)
                        }
                    }
                    .labelsHidden()
                }
            }

            // MARK: - Face Sheet Path (Required)
            VStack(alignment: .leading, spacing: 2) {
                Text("顔三面図")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ImageDropField(
                    imagePath: $actor.faceSheetPath,
                    placeholder: "顔三面図をドロップ（必須）",
                    height: 50
                )
            }

            // MARK: - Face Features (Auto-filled, Editable)
            HStack {
                Text("顔の特徴")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                TextField("", text: $actor.faceFeatures, prompt: Text("キャラクタ選択で自動入力"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // MARK: - Body Features (Auto-filled, Editable)
            HStack {
                Text("体型の特徴")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                TextField("", text: $actor.bodyFeatures, prompt: Text("キャラクタ選択で自動入力"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // MARK: - Personality (Auto-filled, Editable)
            HStack {
                Text("パーソナリティ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                TextField("", text: $actor.personality, prompt: Text("キャラクタ選択で自動入力"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Wardrobes Section View
/// 衣装セクション
struct WardrobesSectionView: View {
    @ObservedObject var viewModel: MangaCreationViewModel
    let savedWardrobes: [SavedWardrobe]

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Header
                HStack {
                    Text("衣装")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("（1〜10体）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if savedWardrobes.isEmpty {
                        Text("衣装管理で登録してください")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }

                // MARK: - Wardrobes (横並び)
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(viewModel.wardrobes.enumerated()), id: \.element.id) { index, wardrobe in
                        WardrobeEntryView(
                            wardrobe: wardrobe,
                            wardrobeIndex: index,
                            savedWardrobes: savedWardrobes,
                            canRemove: viewModel.canRemoveWardrobe,
                            onRemove: {
                                viewModel.removeWardrobe(at: index)
                            }
                        )
                    }
                }

                // MARK: - Add Wardrobe Button
                if viewModel.canAddWardrobe {
                    Button(action: {
                        viewModel.addWardrobe()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("衣装を追加")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Wardrobe Entry View
/// 衣装の入力フォーム（1体分）
struct WardrobeEntryView: View {
    @ObservedObject var wardrobe: WardrobeEntry
    let wardrobeIndex: Int
    let savedWardrobes: [SavedWardrobe]
    let canRemove: Bool
    let onRemove: () -> Void

    private var wardrobeLabel: String {
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        return "衣装\(labels[wardrobeIndex])"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // MARK: - Header
            HStack {
                Text(wardrobeLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
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

            // MARK: - Wardrobe Selection (Required)
            if savedWardrobes.isEmpty {
                Text("衣装未登録")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            } else {
                Picker("", selection: Binding(
                    get: { wardrobe.name },
                    set: { newValue in
                        wardrobe.name = newValue
                        // 選択した衣装の説明を自動入力
                        if let saved = savedWardrobes.first(where: { $0.name == newValue }) {
                            wardrobe.selectSavedWardrobe(saved)
                        }
                    }
                )) {
                    Text("選択してください").tag("")
                    ForEach(savedWardrobes) { saved in
                        Text(saved.name).tag(saved.name)
                    }
                }
                .labelsHidden()
                .font(.caption2)
            }

            // MARK: - Outfit Sheet Path (Required)
            ImageDropField(
                imagePath: $wardrobe.outfitSheetPath,
                placeholder: "衣装シートをドロップ",
                height: 50
            )

            // MARK: - Features (Auto-filled, Editable)
            TextField("", text: $wardrobe.features, prompt: Text("衣装の説明（自動入力）"))
                .textFieldStyle(.roundedBorder)
                .font(.caption2)
        }
        .padding(6)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(6)
    }
}

// MARK: - Registration Buttons View
/// 登録/クリアボタン
struct RegistrationButtonsView: View {
    @ObservedObject var viewModel: MangaCreationViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.registerActorsAndWardrobes()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("登録")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasValidInput)

            Button(action: {
                viewModel.clearActorsAndWardrobes()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("クリア")
                }
            }
            .buttonStyle(.bordered)

            Spacer()

            // 登録状態表示
            if viewModel.hasRegisteredActors || viewModel.hasRegisteredWardrobes {
                Text("登録済み: キャラ\(viewModel.registeredActors.count)人、衣装\(viewModel.registeredWardrobes.count)体")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }

    private var hasValidInput: Bool {
        viewModel.actors.contains { $0.isValid } || viewModel.wardrobes.contains { $0.isValid }
    }
}

// MARK: - Manga Panel Form View
/// 1コマ分の入力フォーム
struct MangaPanelFormView: View {
    @ObservedObject var panel: MangaPanel
    let panelIndex: Int
    let canRemove: Bool
    let registeredActors: [ActorEntry]
    let registeredWardrobes: [WardrobeEntry]
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
                HStack {
                    Text("キャラクター")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("（左から右への配置順）")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // 横並びのキャラクタースロット
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(panel.characters.enumerated()), id: \.element.id) { charIndex, character in
                        PanelCharacterSlotView(
                            character: character,
                            characterIndex: charIndex,
                            canRemove: panel.canRemoveCharacter,
                            registeredActors: registeredActors,
                            registeredWardrobes: registeredWardrobes,
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
/// コマ内のキャラクタースロット（ドロップダウン選択式）
struct PanelCharacterSlotView: View {
    @ObservedObject var character: PanelCharacter
    let characterIndex: Int
    let canRemove: Bool
    let registeredActors: [ActorEntry]
    let registeredWardrobes: [WardrobeEntry]
    let onRemove: () -> Void

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
            .frame(width: 150)

            // MARK: - Actor Selection (Dropdown)
            VStack(alignment: .leading, spacing: 2) {
                Text("キャラ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Picker("", selection: $character.selectedActorId) {
                    Text("(未選択)").tag(nil as UUID?)
                    ForEach(registeredActors) { actor in
                        Text(actor.displayLabel).tag(actor.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                .disabled(registeredActors.isEmpty)
            }

            // MARK: - Wardrobe Selection (Dropdown)
            VStack(alignment: .leading, spacing: 2) {
                Text("衣装")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Picker("", selection: $character.selectedWardrobeId) {
                    Text("(未選択)").tag(nil as UUID?)
                    ForEach(registeredWardrobes) { wardrobe in
                        Text(wardrobe.displayLabel).tag(wardrobe.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                .disabled(registeredWardrobes.isEmpty)
            }

            // MARK: - Dialogue
            VStack(alignment: .leading, spacing: 2) {
                Text("セリフ")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.dialogue, prompt: Text("セリフ"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 150)
            }

            // MARK: - Features
            VStack(alignment: .leading, spacing: 2) {
                Text("特徴")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", text: $character.features, prompt: Text("表情・ポーズ"))
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 150)
            }
        }
        .frame(width: 150, alignment: .leading)  // 固定幅でずれ防止
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Preview
#Preview {
    MangaCreationFormView(
        viewModel: MangaCreationViewModel(),
        savedCharacters: [],
        savedWardrobes: []
    )
    .frame(width: 500)
    .padding()
}
