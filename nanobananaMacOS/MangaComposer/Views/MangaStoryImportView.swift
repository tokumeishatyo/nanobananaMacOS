// MangaStoryImportView.swift
// 漫画ストーリーYAMLインポートウィンドウ

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Manga Story Import View

struct MangaStoryImportView: View {
    @ObservedObject var viewModel: MangaStoryImportViewModel
    let onApply: (MangaStoryYAML, [CharacterMatchResult]) -> Void
    let onCancel: () -> Void

    @State private var isTargeted = false
    @State private var showingFilePicker = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("漫画ストーリー読み込み")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // MARK: - Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Drop Zone
                    YAMLDropZoneView(
                        yamlPath: viewModel.yamlPath,
                        isTargeted: $isTargeted,
                        showingFilePicker: $showingFilePicker,
                        onDrop: { url in
                            viewModel.loadYAML(from: url)
                        },
                        onClear: {
                            viewModel.clear()
                        }
                    )

                    // MARK: - Error Message
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // MARK: - Preview
                    if viewModel.hasLoadedYAML {
                        Divider()

                        StoryPreviewView(viewModel: viewModel)
                    }
                }
                .padding()
            }

            Divider()

            // MARK: - Footer Buttons
            HStack {
                // 未登録警告
                if viewModel.hasLoadedYAML && !viewModel.allCharactersMatched {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("未登録のキャラクターが\(viewModel.unmatchedCount)人います")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                Button("クリア") {
                    viewModel.clear()
                }
                .disabled(!viewModel.hasLoadedYAML)

                Button("キャンセル") {
                    onCancel()
                }

                Button("OK") {
                    if let yaml = viewModel.parsedYAML {
                        onApply(yaml, viewModel.characterMatchResults)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canApply)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 600, height: 700)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "yaml") ?? .plainText, UTType(filenameExtension: "yml") ?? .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.loadYAML(from: url)
                }
            case .failure(let error):
                viewModel.errorMessage = "ファイル選択エラー: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - YAML Drop Zone View

struct YAMLDropZoneView: View {
    let yamlPath: String
    @Binding var isTargeted: Bool
    @Binding var showingFilePicker: Bool
    let onDrop: (URL) -> Void
    let onClear: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.gray.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2, dash: yamlPath.isEmpty ? [8] : [])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
                )

            if yamlPath.isEmpty {
                // 未選択時
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("YAMLファイルをドラッグ＆ドロップ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("または")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("ファイルを選択") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                // 選択済み
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)

                    Text(yamlPath)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 120)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }

            let ext = url.pathExtension.lowercased()
            guard ext == "yaml" || ext == "yml" else { return }

            DispatchQueue.main.async {
                onDrop(url)
            }
        }
        return true
    }
}

// MARK: - Story Preview View

struct StoryPreviewView: View {
    @ObservedObject var viewModel: MangaStoryImportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Title
            if !viewModel.title.isEmpty {
                HStack {
                    Text("タイトル:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(viewModel.title)
                        .font(.subheadline)
                }
            }

            // MARK: - Characters Section
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("登場人物")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("（\(viewModel.characterMatchResults.count)人）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ForEach(viewModel.characterMatchResults) { result in
                        CharacterMatchRowView(result: result)
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: - Panels Section
            if let panels = viewModel.parsedYAML?.panels {
                ForEach(panels) { panel in
                    PanelPreviewView(panel: panel)
                }
            }
        }
    }
}

// MARK: - Character Match Row View

struct CharacterMatchRowView: View {
    let result: CharacterMatchResult

    var body: some View {
        HStack {
            Text("・\(result.yamlName)")
                .font(.caption)

            Spacer()

            if result.isMatched {
                HStack(spacing: 4) {
                    Text("DB照合OK")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            } else {
                HStack(spacing: 4) {
                    Text("未登録")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(result.isMatched ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        )
    }
}

// MARK: - Panel Preview View

struct PanelPreviewView: View {
    let panel: MangaStoryPanel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Text("コマ \(panel.panel)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }

                // Scene
                if let scene = panel.scene, !scene.isEmpty {
                    HStack(alignment: .top) {
                        Text("シーン:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text(scene)
                            .font(.caption)
                    }
                }

                // Narration
                if let narration = panel.narration, !narration.isEmpty {
                    HStack(alignment: .top) {
                        Text("ナレーション:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text(narration)
                            .font(.caption)
                    }
                }

                // Mob
                HStack {
                    Text("モブ:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                    Text(panel.mob == true ? "あり" : "なし")
                        .font(.caption)
                }

                // Characters
                if let characters = panel.characters, !characters.isEmpty {
                    Divider()

                    ForEach(characters) { character in
                        PanelCharacterPreviewView(character: character)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Panel Character Preview View

struct PanelCharacterPreviewView: View {
    let character: MangaStoryPanelCharacter

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Name
            Text(character.name ?? "(不明)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                // Dialogue
                if let dialogue = character.dialogue, !dialogue.isEmpty {
                    Text("「\(dialogue)」")
                        .font(.caption)
                }

                // Features
                if let features = character.features, !features.isEmpty {
                    Text("(\(features))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    MangaStoryImportView(
        viewModel: MangaStoryImportViewModel(savedCharacters: []),
        onApply: { _, _ in },
        onCancel: {}
    )
}
