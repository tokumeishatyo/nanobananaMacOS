import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

/// コマ内の画像データ（詳細漫画コンポーザー用）
struct ComposerPanelImage: Identifiable {
    let id = UUID()
    var image: NSImage?
    var filePath: String = ""
    var filename: String = ""
}

/// コマデータ（詳細漫画コンポーザー用）
class ComposerPanel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var leftImage: ComposerPanelImage = ComposerPanelImage()
    @Published var rightImage: ComposerPanelImage? = nil  // nilなら分割なし

    /// 分割されているか
    var isSplit: Bool {
        rightImage != nil
    }

    /// 左右分割を追加
    func addSplit() {
        if rightImage == nil {
            rightImage = ComposerPanelImage()
        }
    }

    /// 左側の画像を削除（分割時のみ、右を左に移動）
    func removeLeftImage() {
        if let right = rightImage {
            leftImage = right
            rightImage = nil
        } else {
            leftImage = ComposerPanelImage()
        }
    }

    /// 右側の画像を削除（分割解除）
    func removeRightImage() {
        rightImage = nil
    }
}

/// 詳細漫画コンポーザーのViewModel
@MainActor
final class DetailedMangaComposerViewModel: ObservableObject {

    // MARK: - Published Properties

    /// タイトル
    @Published var title: String = ""

    /// 作者名
    @Published var authorName: String = ""

    /// コマリスト
    @Published var panels: [ComposerPanel] = []

    /// プレビュー画像
    @Published var previewImage: NSImage? = nil

    /// エラーメッセージ
    @Published var errorMessage: String? = nil

    /// 成功メッセージ
    @Published var successMessage: String? = nil

    // MARK: - Constants

    /// 合成時の横幅（ピクセル）
    static let outputWidth: CGFloat = 500

    // MARK: - Initializer

    init() {
        // 初期状態で1コマ表示
        panels.append(ComposerPanel())
    }

    // MARK: - Panel Management

    /// コマを追加
    func addPanel() {
        panels.append(ComposerPanel())
    }

    /// コマを削除
    func removePanel(_ panel: ComposerPanel) {
        // 最低1コマは残す
        if panels.count > 1 {
            panels.removeAll { $0.id == panel.id }
        }
    }

    /// 指定コマに左右分割を追加
    func addSplitToPanel(_ panel: ComposerPanel) {
        panel.addSplit()
        objectWillChange.send()
    }

    /// 左画像を削除
    func removeLeftImage(from panel: ComposerPanel) {
        panel.removeLeftImage()
        objectWillChange.send()
    }

    /// 右画像を削除（分割解除）
    func removeRightImage(from panel: ComposerPanel) {
        panel.removeRightImage()
        objectWillChange.send()
    }

    // MARK: - Image Loading

    /// ファイル選択ダイアログを表示（左画像用）
    func selectLeftImage(for panel: ComposerPanel) {
        selectImage { [weak self] image, path, filename in
            panel.leftImage = ComposerPanelImage(image: image, filePath: path, filename: filename)
            self?.objectWillChange.send()
        }
    }

    /// ファイル選択ダイアログを表示（右画像用）
    func selectRightImage(for panel: ComposerPanel) {
        selectImage { [weak self] image, path, filename in
            panel.rightImage = ComposerPanelImage(image: image, filePath: path, filename: filename)
            self?.objectWillChange.send()
        }
    }

    /// 共通のファイル選択処理
    private func selectImage(completion: @escaping (NSImage, String, String) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .webP, .gif]

        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url, completion: completion)
        }
    }

    /// URLから画像を読み込み
    private func loadImage(from url: URL, completion: @escaping (NSImage, String, String) -> Void) {
        let ext = url.pathExtension.lowercased()
        guard ["png", "jpg", "jpeg", "webp", "gif"].contains(ext) else {
            errorMessage = "対応していない画像形式です（PNG, JPEG, WebP, GIF のみ）"
            clearErrorAfterDelay()
            return
        }

        guard let image = NSImage(contentsOf: url) else {
            errorMessage = "画像を読み込めませんでした"
            clearErrorAfterDelay()
            return
        }

        completion(image, url.path, url.lastPathComponent)
    }

    // MARK: - Drag & Drop

    /// ドロップされたファイルを処理（左画像用）
    func handleDropForLeftImage(_ providers: [NSItemProvider], panel: ComposerPanel) -> Bool {
        handleDrop(providers) { [weak self] image, path, filename in
            panel.leftImage = ComposerPanelImage(image: image, filePath: path, filename: filename)
            self?.objectWillChange.send()
        }
    }

    /// ドロップされたファイルを処理（右画像用）
    func handleDropForRightImage(_ providers: [NSItemProvider], panel: ComposerPanel) -> Bool {
        handleDrop(providers) { [weak self] image, path, filename in
            panel.rightImage = ComposerPanelImage(image: image, filePath: path, filename: filename)
            self?.objectWillChange.send()
        }
    }

    /// 共通のドロップ処理
    private func handleDrop(_ providers: [NSItemProvider], completion: @escaping (NSImage, String, String) -> Void) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        return
                    }
                    Task { @MainActor [weak self] in
                        self?.loadImage(from: url, completion: completion)
                    }
                }
                return true
            }
        }
        return false
    }

    // MARK: - Preview & Compose

    /// プレビューを更新
    func updatePreview() {
        guard let composedImage = composeImages() else {
            errorMessage = "プレビュー生成に失敗しました。画像を設定してください。"
            clearErrorAfterDelay()
            return
        }
        previewImage = composedImage
    }

    /// 合成して保存
    func composeAndSave() {
        guard let composedImage = composeImages() else {
            errorMessage = "合成に失敗しました。画像を設定してください。"
            clearErrorAfterDelay()
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = generateOutputFilename()

        if savePanel.runModal() == .OK, let url = savePanel.url {
            saveImageAsPNG(composedImage, to: url)
        }
    }

    /// 画像を合成（実装はStep 2で行う）
    private func composeImages() -> NSImage? {
        // TODO: Step 2で実装
        // 現在はプレースホルダー

        // 最低1つの画像が設定されているかチェック
        let hasAnyImage = panels.contains { panel in
            panel.leftImage.image != nil || panel.rightImage?.image != nil
        }

        if !hasAnyImage {
            return nil
        }

        // プレースホルダー: 最初のパネルの左画像を返す
        return panels.first?.leftImage.image
    }

    /// 出力ファイル名を生成
    private func generateOutputFilename() -> String {
        if !title.isEmpty {
            return "\(title)_composed.png"
        }
        return "manga_composed.png"
    }

    /// 画像をPNGとして保存
    private func saveImageAsPNG(_ image: NSImage, to url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            errorMessage = "PNG形式への変換に失敗しました"
            clearErrorAfterDelay()
            return
        }

        do {
            try pngData.write(to: url)
            successMessage = "保存しました: \(url.lastPathComponent)"
            clearSuccessAfterDelay()
        } catch {
            errorMessage = "ファイルの保存に失敗しました: \(error.localizedDescription)"
            clearErrorAfterDelay()
        }
    }

    // MARK: - Reset

    /// すべてクリア
    func clear() {
        title = ""
        authorName = ""
        panels = [ComposerPanel()]
        previewImage = nil
        errorMessage = nil
        successMessage = nil
    }

    // MARK: - Message Handling

    private func clearErrorAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.errorMessage = nil
        }
    }

    private func clearSuccessAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self?.successMessage = nil
        }
    }
}
