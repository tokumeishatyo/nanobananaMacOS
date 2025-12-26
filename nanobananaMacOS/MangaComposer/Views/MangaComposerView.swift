// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manga Composer View
/// 漫画ページコンポーザーのメイン画面
struct MangaComposerView: View {
    @StateObject private var viewModel = MangaComposerViewModel()
    @Environment(\.windowDismiss) private var windowDismiss

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
        .frame(width: 500, height: 600)
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
        case .characterSheet:
            CharacterSheetFormView(viewModel: viewModel.characterSheetViewModel)
        case .mangaCreation:
            // 後日実装
            VStack {
                Text("漫画作成機能は後日実装予定です")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack {
            Spacer()

            Button("適用") {
                viewModel.apply()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!viewModel.canApply)

            Button("キャンセル") {
                viewModel.cancel()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
    }

    // MARK: - Setup
    private func setupCallbacks() {
        viewModel.onApply = {
            windowDismiss?()
        }
        viewModel.onCancel = {
            windowDismiss?()
        }
    }
}

// MARK: - Character Sheet Form View
/// 登場人物生成シートの入力フォーム
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
                HStack {
                    TextField("背景画像", text: $viewModel.backgroundImagePath)
                        .textFieldStyle(.roundedBorder)
                    Button("選択...") {
                        selectBackgroundImage()
                    }
                }
            } else {
                TextField("背景説明", text: $viewModel.backgroundDescription, prompt: Text(viewModel.backgroundDescriptionPlaceholder), axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
            }

            // MARK: - Characters
            sectionHeader("キャラクター設定（\(viewModel.characters.count)名）")

            ForEach(Array(viewModel.characters.enumerated()), id: \.element.id) { index, character in
                characterEntryView(index: index, character: character)
            }

            // Add/Remove buttons
            HStack {
                if viewModel.canAddCharacter {
                    Button("キャラクターを追加") {
                        viewModel.addCharacter()
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.top, 8)
    }

    private func characterEntryView(index: Int, character: CharacterEntry) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("キャラクター \(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    if viewModel.canRemoveCharacter {
                        Button(action: {
                            viewModel.removeCharacter(at: index)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                TextField("名前", text: Binding(
                    get: { character.name },
                    set: { character.name = $0 }
                ))
                .textFieldStyle(.roundedBorder)

                HStack {
                    TextField("キャラ画像", text: Binding(
                        get: { character.imagePath },
                        set: { character.imagePath = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    Button("選択...") {
                        selectCharacterImage(for: character)
                    }
                }

                TextField("キャラ情報（箇条書き推奨）", text: Binding(
                    get: { character.info },
                    set: { character.info = $0 }
                ), prompt: Text(CharacterEntry.infoPlaceholder), axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...6)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - File Selection
    private func selectBackgroundImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg]

        if panel.runModal() == .OK, let url = panel.url {
            viewModel.backgroundImagePath = url.path
        }
    }

    private func selectCharacterImage(for character: CharacterEntry) {
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
    MangaComposerView()
}
