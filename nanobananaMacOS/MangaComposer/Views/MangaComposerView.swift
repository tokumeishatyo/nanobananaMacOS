// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manga Composer View
/// 漫画ページコンポーザーのメイン画面
struct MangaComposerView: View {
    @StateObject private var viewModel = MangaComposerViewModel()
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.windowDismiss) private var windowDismiss

    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Mode Selection
            modeSelectionSection

            Divider()

            // MARK: - Content Area
            ScrollView {
                contentSection
                    .padding()
            }

            Divider()

            // MARK: - Action Buttons
            actionButtonsSection
        }
        .frame(width: 600, height: 1000)
        .onAppear {
            setupCallbacks()
        }
    }

    // MARK: - Mode Selection Section
    private var modeSelectionSection: some View {
        HStack(spacing: 12) {
            ForEach(ComposerMode.allCases) { mode in
                modeButton(for: mode)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func modeButton(for mode: ComposerMode) -> some View {
        let isSelected = viewModel.selectedMode == mode

        Button(action: {
            if mode.isEnabled {
                viewModel.selectedMode = mode
            }
        }) {
            Text(mode.rawValue)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? .accentColor : nil)
        .disabled(!mode.isEnabled)
    }

    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.selectedMode {
        case .characterCard:
            CharacterCardFormView(character: viewModel.characterCardEntry)
        case .characterSheet:
            CharacterSheetFormView(viewModel: viewModel.characterSheetViewModel)
        case .mangaCreation:
            MangaCreationFormView(
                viewModel: viewModel.mangaCreationViewModel,
                savedCharacters: mainViewModel.characterDatabaseService.characters
            )
        }
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack {
            Spacer()

            Button("適用") {
                viewModel.apply()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: .control)  // Ctrl+Enter で適用
            .disabled(!viewModel.canApply)

            Button("キャンセル") {
                viewModel.cancel()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
    }

    // MARK: - Setup
    private func setupCallbacks() {
        // クロージャ内で使用するためローカル変数にキャプチャ
        let mainVM = mainViewModel
        let vm = viewModel
        let dismiss = windowDismiss

        viewModel.onApply = {
            // 選択モードに応じて設定を保存
            switch vm.selectedMode {
            case .characterCard:
                // キャラクターカード設定を保存
                mainVM.characterCardEntry = vm.characterCardEntry.copy()
                mainVM.isCharacterCardMode = true
            case .characterSheet:
                // 登場人物シート設定を保存
                mainVM.characterSheetSettings = vm.characterSheetViewModel
                mainVM.isCharacterSheetMode = true
            case .mangaCreation:
                // 位置情報をシーンに追記
                vm.mangaCreationViewModel.appendPositionInfoToScenes()
                // 漫画作成設定を保存
                mainVM.mangaCreationSettings = vm.mangaCreationViewModel
                mainVM.isMangaCreationMode = true
            }
            dismiss?()
        }
        viewModel.onCancel = {
            dismiss?()
        }
    }
}

// MARK: - Character Card Form View
/// キャラクターカード作成の入力フォーム（1名分）
struct CharacterCardFormView: View {
    @ObservedObject var character: CharacterEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            Text("キャラクターカード")
                .font(.headline)
                .padding(.top, 8)

            Text("1枚のカードに名前・画像・説明を一体化して生成します。")
                .font(.caption)
                .foregroundColor(.secondary)

            // MARK: - Character Entry
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    // 名前
                    Text("名前")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("名前", text: $character.name, prompt: Text("キャラクター名"))
                        .textFieldStyle(.roundedBorder)

                    // 画像
                    Text("キャラ画像")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.top, 4)
                    ImageDropField(
                        imagePath: $character.imagePath,
                        placeholder: "キャラ画像をドロップ",
                        height: 60
                    )

                    // 情報
                    VStack(alignment: .leading, spacing: 4) {
                        Text("キャラ情報（箇条書き推奨）")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.top, 4)
                        TextEditor(text: $character.info)
                            .font(.body)
                            .frame(height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if character.info.isEmpty {
                                    Text(CharacterEntry.infoPlaceholder)
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Character Sheet Form View
/// 登場人物生成シートの入力フォーム（カード画像ベース）
struct CharacterSheetFormView: View {
    @ObservedObject var viewModel: CharacterSheetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Sheet Title
            sectionHeader("シートタイトル")
            TextField("シートタイトル", text: $viewModel.sheetTitle, prompt: Text(viewModel.sheetTitlePlaceholder))
                .textFieldStyle(.roundedBorder)

            // MARK: - Background Settings
            sectionHeader("背景設定")
            Picker("背景ソース", selection: $viewModel.backgroundSourceType) {
                ForEach(BackgroundSourceType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.backgroundSourceType == .file {
                ImageDropField(
                    imagePath: $viewModel.backgroundImagePath,
                    placeholder: "背景画像をドロップ",
                    height: 60
                )
            } else {
                TextField("背景説明", text: $viewModel.backgroundDescription, prompt: Text(viewModel.backgroundDescriptionPlaceholder), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
            }

            // MARK: - Card Images
            sectionHeader("カード画像（\(viewModel.cardImagePaths.count)枚）")

            Text("生成済みのキャラクターカード画像をドラッグ＆ドロップ")
                .font(.caption)
                .foregroundColor(.secondary)

            // 横並びのカードスロット
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(viewModel.cardImagePaths.enumerated()), id: \.offset) { index, path in
                    CardSlotView(
                        imagePath: path,
                        index: index,
                        canRemove: viewModel.canRemoveCard,
                        onImageDropped: { newPath in
                            viewModel.setCardImagePath(newPath, at: index)
                        },
                        onRemove: {
                            viewModel.removeCard(at: index)
                        }
                    )
                }

                // 追加ボタン
                if viewModel.canAddCard {
                    Button(action: {
                        viewModel.addCard()
                    }) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                            Text("追加")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 140)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - Card Slot View
/// カード画像スロット（ドラッグ＆ドロップ対応）
struct CardSlotView: View {
    let imagePath: String
    let index: Int
    let canRemove: Bool
    let onImageDropped: (String) -> Void
    let onRemove: () -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 4) {
            // カード番号と削除ボタン
            HStack {
                Text("カード \(index + 1)")
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
            .frame(width: 100)

            // ドロップエリア / プレビュー
            ZStack {
                if imagePath.isEmpty {
                    // 空のスロット
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(isTargeted ? .accentColor : .gray)
                        .frame(width: 100, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("ドロップ")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    // 画像プレビュー
                    if let nsImage = NSImage(contentsOfFile: imagePath) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 120)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        // 画像読み込み失敗
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 100, height: 120)
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
        }
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
                onImageDropped(url.path)
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
            onImageDropped(url.path)
        }
    }
}

// MARK: - Preview
#Preview {
    MangaComposerView(mainViewModel: MainViewModel())
}
