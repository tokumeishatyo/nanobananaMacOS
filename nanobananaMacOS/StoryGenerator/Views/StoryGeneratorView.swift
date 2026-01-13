// rule.mdを読むこと
import SwiftUI

// MARK: - Story Generator View
/// ストーリーYAML生成のメイン画面
struct StoryGeneratorView: View {
    @StateObject private var viewModel = StoryGeneratorViewModel()
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.windowDismiss) private var windowDismiss

    @State private var showPreviewDialog = false
    @State private var generatedYAML: String = ""

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
        .sheet(isPresented: $showPreviewDialog) {
            StoryPreviewDialog(
                yaml: generatedYAML,
                onConfirm: {
                    copyToClipboard()
                    showPreviewDialog = false
                },
                onCancel: {
                    showPreviewDialog = false
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
        // TODO: Phase 4で実装
        generatedYAML = "# Generated YAML\ntitle: \"\(viewModel.storyTitle)\"\n# ..."
        showPreviewDialog = true
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedYAML, forType: .string)
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
