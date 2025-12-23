// rule.mdを読むこと
import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

/// 画像ファイル選択ダイアログのViewModel
@MainActor
final class ImageFileSelectionViewModel: ObservableObject {

    // MARK: - Types

    /// 必要なファイル情報
    struct RequiredFile: Identifiable {
        let id = UUID()
        let filename: String
        var isMatched: Bool = false
        var image: NSImage? = nil
    }

    // MARK: - Published Properties

    /// 必要なファイルのリスト
    @Published var requiredFiles: [RequiredFile] = []

    /// エラーメッセージ（ファイル名不一致時など）
    @Published var errorMessage: String? = nil

    /// すべてのファイルが揃ったかどうか
    var isAllFilesMatched: Bool {
        !requiredFiles.isEmpty && requiredFiles.allSatisfy { $0.isMatched }
    }

    // MARK: - Callbacks

    /// OKボタン押下時のコールバック
    var onComplete: (@MainActor ([String: NSImage]) -> Void)?

    /// キャンセルボタン押下時のコールバック
    var onCancel: (@MainActor () -> Void)?

    // MARK: - Initialization

    /// 必要なファイル名リストで初期化
    init(requiredFilenames: [String]) {
        self.requiredFiles = requiredFilenames.map { RequiredFile(filename: $0) }
    }

    // MARK: - Public Methods

    /// ドロップされたファイルを処理
    func handleDroppedFiles(_ providers: [NSItemProvider]) {
        for provider in providers {
            // ファイルURLを取得
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        return
                    }
                    Task { @MainActor [weak self] in
                        self?.processFile(at: url)
                    }
                }
            }
        }
    }

    /// ファイル選択ダイアログを表示
    func showFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg]

        if panel.runModal() == .OK {
            for url in panel.urls {
                processFile(at: url)
            }
        }
    }

    /// OKボタン押下
    func confirmSelection() {
        var result: [String: NSImage] = [:]
        for file in requiredFiles where file.isMatched {
            if let image = file.image {
                result[file.filename] = image
            }
        }
        onComplete?(result)
    }

    /// キャンセルボタン押下
    func cancel() {
        onCancel?()
    }

    // MARK: - Private Methods

    /// ファイルを処理してマッチング
    private func processFile(at url: URL) {
        let droppedFilename = url.lastPathComponent

        // 必要なファイルリストからマッチするものを探す
        if let index = requiredFiles.firstIndex(where: { $0.filename == droppedFilename && !$0.isMatched }) {
            // 画像を読み込み
            guard let image = NSImage(contentsOf: url) else {
                errorMessage = "画像ファイルを読み込めませんでした: \(droppedFilename)"
                clearErrorAfterDelay()
                return
            }

            // マッチ成功
            requiredFiles[index].isMatched = true
            requiredFiles[index].image = image
            errorMessage = nil
        } else if requiredFiles.contains(where: { $0.filename == droppedFilename && $0.isMatched }) {
            // 既にマッチ済み
            errorMessage = "このファイルは既に選択されています: \(droppedFilename)"
            clearErrorAfterDelay()
        } else {
            // ファイル名不一致
            errorMessage = "ファイル名が一致しません: \(droppedFilename)"
            clearErrorAfterDelay()
        }
    }

    /// エラーメッセージを数秒後にクリア
    private func clearErrorAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self?.errorMessage = nil
        }
    }
}
