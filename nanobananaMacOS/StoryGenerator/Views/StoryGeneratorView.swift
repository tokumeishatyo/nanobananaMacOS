// rule.mdを読むこと
import SwiftUI

// MARK: - Preview Data
/// プレビューダイアログに渡すデータ
struct StoryPreviewData: Identifiable {
    let id = UUID()
    let yaml: String
    let suggestedFileName: String
}

// MARK: - Story Generator View
/// ストーリーYAML生成のメイン画面
struct StoryGeneratorView: View {
    @StateObject private var viewModel = StoryGeneratorViewModel()
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.windowDismiss) private var windowDismiss

    @State private var previewData: StoryPreviewData?

    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            headerSection

            Divider()

            // MARK: - Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 英訳チェックボックス
                    translationToggleSection

                    // モード選択
                    modeSelectionSection

                    // タイトル入力
                    titleInputSection

                    // キャラクタ選択
                    characterSelectionSection

                    // パネル入力
                    panelInputSection
                }
                .padding()
            }

            Divider()

            // MARK: - Action Buttons
            actionButtonsSection
        }
        .frame(width: 600, height: 800)
        .sheet(item: $previewData) { data in
            StoryPreviewDialog(
                yaml: data.yaml,
                suggestedFileName: data.suggestedFileName,
                onSaved: {
                    previewData = nil
                    windowDismiss?()
                },
                onCancel: {
                    previewData = nil
                }
            )
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("ストーリー作成")
                .font(.headline)
            Spacer()
        }
        .padding()
    }

    // MARK: - Translation Toggle Section
    private var translationToggleSection: some View {
        GroupBox {
            Toggle("必要項目を英訳する", isOn: $viewModel.enableTranslation)
                .toggleStyle(.checkbox)
        }
    }

    // MARK: - Mode Selection Section
    private var modeSelectionSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("コマ数")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Picker("", selection: $viewModel.panelMode) {
                    ForEach(StoryPanelMode.allCases, id: \.self) { mode in
                        Text(mode.displayLabel).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    // MARK: - Title Input Section
    private var titleInputSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text("タイトル")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("漫画のタイトル（必須）", text: $viewModel.storyTitle)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    // MARK: - Character Selection Section
    private var characterSelectionSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("使用キャラクタ")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(viewModel.selectedCharacterIds.count)人選択中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                let characters = mainViewModel.characterDatabaseService.characters
                if characters.isEmpty {
                    Text("キャラクタが登録されていません。\n先にキャラクタ管理でキャラクタを登録してください。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    // キャラクター選択リスト
                    ForEach(characters) { character in
                        CharacterSelectionRow(
                            character: character,
                            isSelected: viewModel.selectedCharacterIds.contains(character.id),
                            onToggle: {
                                viewModel.toggleCharacterSelection(character.id)
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Panel Input Section
    private var panelInputSection: some View {
        ForEach(viewModel.panels) { panel in
            StoryPanelInputView(
                panel: panel,
                panelMode: viewModel.panelMode,
                selectedCharacters: viewModel.getSelectedCharacters(
                    from: mainViewModel.characterDatabaseService.characters
                )
            )
        }
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack {
            Button("リセット") {
                viewModel.reset()
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("キャンセル") {
                windowDismiss?()
            }
            .keyboardShortcut(.escape)

            Button("YAML生成") {
                generateYAML()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isValid)
        }
        .padding()
    }

    // MARK: - Actions

    private func generateYAML() {
        let selectedCharacters = viewModel.getSelectedCharacters(
            from: mainViewModel.characterDatabaseService.characters
        )

        let context = StoryYAMLGenerator.GenerationContext(
            title: viewModel.storyTitle,
            selectedCharacters: selectedCharacters,
            panels: viewModel.panels,
            enableTranslation: viewModel.enableTranslation
        )

        let generator = StoryYAMLGenerator()

        // 翻訳機能は将来実装予定
        // enableTranslationがtrueでも現時点では翻訳なしで生成
        let yaml = generator.generate(context: context)

        // sheet(item:) でデータを確実に渡す
        previewData = StoryPreviewData(
            yaml: yaml,
            suggestedFileName: viewModel.suggestedFileName
        )
    }
}

// MARK: - Character Selection Row
/// キャラクター選択行
struct CharacterSelectionRow: View {
    let character: SavedCharacter
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.checkbox)

            Text(character.name)
                .lineLimit(1)

            Spacer()

            if !character.faceFeatures.isEmpty {
                Text(character.faceFeatures.prefix(30) + (character.faceFeatures.count > 30 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview
#Preview {
    StoryGeneratorView(mainViewModel: MainViewModel())
}
