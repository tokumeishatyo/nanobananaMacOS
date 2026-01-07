import SwiftUI
import UniformTypeIdentifiers

/// キャラクター管理ウィンドウ
struct CharacterDatabaseView: View {
    @ObservedObject var viewModel: CharacterDatabaseViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss

    // エクスポート/インポート用
    @State private var showExportDialog = false
    @State private var showImportDialog = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var isSuccessAlert = false

    private func dismissWindow() {
        if let windowDismiss = windowDismiss {
            windowDismiss()
        } else {
            standardDismiss()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // コンテンツエリア
            ScrollView {
                VStack(spacing: 16) {
                    // 登録済みキャラクター一覧
                    characterListSection

                    // エクスポート/インポートボタン
                    exportImportSection

                    Divider()

                    // 新規登録/編集フォーム
                    formSection
                }
                .padding(16)
            }

            Divider()

            // ボタンエリア
            HStack {
                Spacer()
                Button("閉じる") {
                    dismissWindow()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(16)
        }
        .frame(width: 500, height: 600)
        .fileExporter(
            isPresented: $showExportDialog,
            document: CharacterExportDocument(characters: viewModel.characters),
            contentType: .json,
            defaultFilename: "characters_export.json"
        ) { result in
            switch result {
            case .success:
                alertMessage = "エクスポートが完了しました"
                isSuccessAlert = true
                showAlert = true
            case .failure(let error):
                alertMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
                isSuccessAlert = false
                showAlert = true
            }
        }
        .fileImporter(
            isPresented: $showImportDialog,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                // セキュリティスコープのアクセス開始
                guard url.startAccessingSecurityScopedResource() else {
                    alertMessage = "ファイルへのアクセス権限がありません"
                    isSuccessAlert = false
                    showAlert = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }

                if let errorMessage = viewModel.importFromFile(url: url) {
                    alertMessage = errorMessage
                    isSuccessAlert = false
                } else {
                    alertMessage = "インポートが完了しました（\(viewModel.characters.count)件）"
                    isSuccessAlert = true
                }
                showAlert = true
            case .failure(let error):
                alertMessage = "ファイルの選択に失敗しました: \(error.localizedDescription)"
                isSuccessAlert = false
                showAlert = true
            }
        }
        .alert(isSuccessAlert ? "完了" : "エラー", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - Export/Import Section

    private var exportImportSection: some View {
        HStack(spacing: 12) {
            Button {
                showExportDialog = true
            } label: {
                Label("エクスポート", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.characters.isEmpty)

            Button {
                showImportDialog = true
            } label: {
                Label("インポート", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Character List Section

    private var characterListSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("登録済みキャラクター")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(viewModel.characters.count)件")
                        .foregroundColor(.secondary)
                }

                if viewModel.characters.isEmpty {
                    Text("登録されているキャラクターはありません")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.characters) { character in
                        characterRow(character)
                    }
                }
            }
            .padding(10)
        }
    }

    private func characterRow(_ character: SavedCharacter) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(character.name)
                    .fontWeight(.medium)
                Text(character.faceFeatures)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // 編集中の場合はハイライト
            if viewModel.editingCharacterId == character.id {
                Text("編集中")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }

            Button("編集") {
                viewModel.startEditing(character)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button("削除") {
                viewModel.delete(character)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Form Section

    private var formSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(viewModel.editingCharacterId == nil ? "新規登録" : "編集")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    if !viewModel.isEditing {
                        Button("新規追加") {
                            viewModel.startNewEntry()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }

                if viewModel.isEditing {
                    // キャラクタ名
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("キャラクタ名")
                            Text("*")
                                .foregroundColor(.red)
                        }
                        TextField("キャラクタ名を入力", text: $viewModel.formName)
                            .textFieldStyle(.roundedBorder)
                        if let error = viewModel.nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 顔の特徴
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("顔の特徴")
                            Text("*")
                                .foregroundColor(.red)
                        }
                        TextEditor(text: $viewModel.formFaceFeatures)
                            .frame(height: 60)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .overlay(
                                Group {
                                    if viewModel.formFaceFeatures.isEmpty {
                                        Text("顔の特徴を入力（例：青い目、金髪ロングヘア）")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                        if let error = viewModel.faceFeaturesError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 体型の特徴
                    VStack(alignment: .leading, spacing: 4) {
                        Text("体型の特徴")
                        TextEditor(text: $viewModel.formBodyFeatures)
                            .frame(height: 40)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .overlay(
                                Group {
                                    if viewModel.formBodyFeatures.isEmpty {
                                        Text("体型の特徴を入力（任意）")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }

                    // パーソナリティ
                    VStack(alignment: .leading, spacing: 4) {
                        Text("パーソナリティ")
                        TextEditor(text: $viewModel.formPersonality)
                            .frame(height: 40)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .overlay(
                                Group {
                                    if viewModel.formPersonality.isEmpty {
                                        Text("パーソナリティを入力（任意）")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }

                    // 保存/キャンセルボタン
                    HStack {
                        Spacer()
                        Button("キャンセル") {
                            viewModel.cancelEditing()
                        }
                        .buttonStyle(.bordered)

                        Button("保存") {
                            _ = viewModel.save()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)
                } else {
                    Text("「新規追加」ボタンを押すか、上のリストから「編集」を選択してください")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
            .padding(10)
        }
    }
}

#Preview {
    CharacterDatabaseView(
        viewModel: CharacterDatabaseViewModel(
            service: CharacterDatabaseService()
        )
    )
}

// MARK: - CharacterExportDocument
/// fileExporter用のドキュメントタイプ
struct CharacterExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var characters: [SavedCharacter]

    init(characters: [SavedCharacter]) {
        self.characters = characters
    }

    init(configuration: ReadConfiguration) throws {
        // 読み込みはfileImporterで行うため、ここでは空配列で初期化
        characters = []
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let exportData = CharacterExportData(characters: characters)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportData)
        return FileWrapper(regularFileWithContents: data)
    }
}
