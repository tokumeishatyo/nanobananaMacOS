// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 衣装管理ウィンドウ
struct WardrobeDatabaseView: View {
    @ObservedObject var viewModel: WardrobeDatabaseViewModel
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
                    // 登録済み衣装一覧
                    wardrobeListSection

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
        .frame(width: 500, height: 500)
        .fileExporter(
            isPresented: $showExportDialog,
            document: WardrobeExportDocument(wardrobes: viewModel.wardrobes),
            contentType: .json,
            defaultFilename: "wardrobes_export.json"
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
                    alertMessage = "インポートが完了しました（\(viewModel.wardrobes.count)件）"
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
            .disabled(viewModel.wardrobes.isEmpty)

            Button {
                showImportDialog = true
            } label: {
                Label("インポート", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Wardrobe List Section

    private var wardrobeListSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("登録済み衣装")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(viewModel.wardrobes.count)件")
                        .foregroundColor(.secondary)
                }

                if viewModel.wardrobes.isEmpty {
                    Text("登録されている衣装はありません")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.wardrobes) { wardrobe in
                        wardrobeRow(wardrobe)
                    }
                }
            }
            .padding(10)
        }
    }

    private func wardrobeRow(_ wardrobe: SavedWardrobe) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(wardrobe.name)
                    .fontWeight(.medium)
                if !wardrobe.description.isEmpty {
                    Text(wardrobe.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 編集中の場合はハイライト
            if viewModel.editingWardrobeId == wardrobe.id {
                Text("編集中")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }

            Button("編集") {
                viewModel.startEditing(wardrobe)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button("削除") {
                viewModel.delete(wardrobe)
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
                    Text(viewModel.editingWardrobeId == nil ? "新規登録" : "編集")
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
                    // 衣装名
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("衣装名")
                            Text("*")
                                .foregroundColor(.red)
                        }
                        TextField("衣装名を入力", text: $viewModel.formName)
                            .textFieldStyle(.roundedBorder)
                        if let error = viewModel.nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 衣装の説明
                    VStack(alignment: .leading, spacing: 4) {
                        Text("衣装の説明")
                        TextEditor(text: $viewModel.formDescription)
                            .frame(height: 80)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .overlay(
                                Group {
                                    if viewModel.formDescription.isEmpty {
                                        Text("衣装の説明を入力（任意）")
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
    WardrobeDatabaseView(
        viewModel: WardrobeDatabaseViewModel(
            service: WardrobeDatabaseService()
        )
    )
}

// MARK: - WardrobeExportDocument
/// fileExporter用のドキュメントタイプ
struct WardrobeExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    /// 事前にシリアライズされたデータ
    private let serializedData: Data

    @MainActor
    init(wardrobes: [SavedWardrobe]) {
        let exportData = WardrobeExportData(wardrobes: wardrobes)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.serializedData = (try? encoder.encode(exportData)) ?? Data()
    }

    init(configuration: ReadConfiguration) throws {
        // 読み込みはfileImporterで行うため、ここでは空データで初期化
        serializedData = Data()
    }

    nonisolated func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: serializedData)
    }
}
