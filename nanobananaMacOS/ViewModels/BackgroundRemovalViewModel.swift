// rule.mdを読むこと
import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

/// 背景透過ツールのViewModel
/// 対応OS: macOS 14.0以降
@available(macOS 14.0, *)
@MainActor
final class BackgroundRemovalViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 選択された画像
    @Published var selectedImage: NSImage? = nil

    /// 選択されたファイル名
    @Published var selectedFilename: String? = nil

    /// 処理結果の画像
    @Published var resultImage: NSImage? = nil

    /// 処理中フラグ
    @Published var isProcessing: Bool = false

    /// エラーメッセージ
    @Published var errorMessage: String? = nil

    /// 完了ダイアログ表示フラグ
    @Published var showCompletionDialog: Bool = false

    // MARK: - Computed Properties

    /// 透過処理ボタンが有効か
    var canProcess: Bool {
        selectedImage != nil && !isProcessing
    }

    // MARK: - Public Methods

    /// ファイル選択ダイアログを表示
    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg]

        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }

    /// ドロップされたファイルを処理
    func handleDroppedProviders(_ providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        return
                    }
                    Task { @MainActor [weak self] in
                        self?.loadImage(from: url)
                    }
                }
            }
        }
    }

    /// URLから画像を読み込み
    func loadImage(from url: URL) {
        // 拡張子チェック
        let ext = url.pathExtension.lowercased()
        guard ["png", "jpg", "jpeg"].contains(ext) else {
            errorMessage = "PNG または JPEG ファイルを選択してください"
            clearErrorAfterDelay()
            return
        }

        // 画像読み込み
        guard let image = NSImage(contentsOf: url) else {
            errorMessage = "画像を読み込めませんでした"
            clearErrorAfterDelay()
            return
        }

        selectedImage = image
        selectedFilename = url.lastPathComponent
        errorMessage = nil

        // 結果をリセット
        resultImage = nil
        showCompletionDialog = false
    }

    /// 透過処理を実行
    func processImage() async {
        guard let image = selectedImage else { return }

        isProcessing = true
        errorMessage = nil

        do {
            let result = try await BackgroundRemovalService.removeBackground(from: image)
            resultImage = result
            showCompletionDialog = true
        } catch {
            errorMessage = error.localizedDescription
            clearErrorAfterDelay()
        }

        isProcessing = false
    }

    /// 結果をファイルに保存
    func saveResult() {
        guard let image = resultImage else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = generateOutputFilename()

        if panel.runModal() == .OK, let url = panel.url {
            saveImageAsPNG(image, to: url)
        }
    }

    /// リセット（初期状態に戻す）
    func reset() {
        selectedImage = nil
        selectedFilename = nil
        resultImage = nil
        isProcessing = false
        errorMessage = nil
        showCompletionDialog = false
    }

    /// 完了ダイアログを閉じる
    func closeCompletionDialog() {
        showCompletionDialog = false
    }

    // MARK: - Private Methods

    /// 出力ファイル名を生成
    private func generateOutputFilename() -> String {
        if let originalName = selectedFilename {
            let name = (originalName as NSString).deletingPathExtension
            return "\(name)_transparent.png"
        }
        return "transparent.png"
    }

    /// 画像をPNGとして保存
    private func saveImageAsPNG(_ image: NSImage, to url: URL) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            errorMessage = "画像の保存に失敗しました"
            clearErrorAfterDelay()
            return
        }

        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = image.size

        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            errorMessage = "PNG形式への変換に失敗しました"
            clearErrorAfterDelay()
            return
        }

        do {
            try pngData.write(to: url)
        } catch {
            errorMessage = "ファイルの保存に失敗しました: \(error.localizedDescription)"
            clearErrorAfterDelay()
        }
    }

    /// エラーメッセージを数秒後にクリア
    private func clearErrorAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.errorMessage = nil
        }
    }
}
