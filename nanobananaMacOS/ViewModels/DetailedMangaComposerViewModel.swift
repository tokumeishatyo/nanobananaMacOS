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

    /// キャンバス横幅（ピクセル）
    static let canvasWidth: CGFloat = 920
    /// コマ横幅（ピクセル）
    static let panelWidth: CGFloat = 900
    /// 分割コマの各画像横幅（ピクセル）
    static let splitPanelWidth: CGFloat = 445
    /// 分割コマ間の余白（ピクセル）
    static let splitPanelGap: CGFloat = 10
    /// 左右余白（ピクセル）
    static let horizontalMargin: CGFloat = 10
    /// 縦余白（ピクセル）
    static let verticalMargin: CGFloat = 10
    /// タイトルフォントサイズ
    static let titleFontSize: CGFloat = 48
    /// 作者フォントサイズ
    static let authorFontSize: CGFloat = 18
    /// ヘッダー高さ（タイトル・作者エリア）
    static let headerHeight: CGFloat = 60

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

    /// 画像を合成
    private func composeImages() -> NSImage? {
        // タイトル必須チェック
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "タイトルは必須です"
            clearErrorAfterDelay()
            return nil
        }

        // 最低1つの画像が設定されているかチェック
        let hasAnyImage = panels.contains { panel in
            panel.leftImage.image != nil || (panel.isSplit && panel.rightImage?.image != nil)
        }

        if !hasAnyImage {
            errorMessage = "少なくとも1つの画像を設定してください"
            clearErrorAfterDelay()
            return nil
        }

        // 各コマの高さを計算
        var panelHeights: [CGFloat] = []
        for panel in panels {
            if let height = calculatePanelHeight(panel) {
                panelHeights.append(height)
            }
        }

        // キャンバスの総高さを計算
        // ヘッダー + 余白 + (コマ高さ + 余白) * コマ数
        let totalPanelHeight = panelHeights.reduce(0, +)
        let totalMargins = Self.verticalMargin * CGFloat(panelHeights.count + 1)
        let canvasHeight = Self.headerHeight + totalMargins + totalPanelHeight

        // キャンバス作成（白背景）
        guard let canvas = createWhiteCanvas(width: Self.canvasWidth, height: canvasHeight) else {
            return nil
        }

        // 描画開始
        canvas.lockFocus()

        // タイトル・作者を描画
        drawHeader(canvasHeight: canvasHeight)

        // 各コマを描画
        var currentY = canvasHeight - Self.headerHeight - Self.verticalMargin
        for (index, panel) in panels.enumerated() {
            if index < panelHeights.count {
                let panelHeight = panelHeights[index]
                currentY -= panelHeight
                drawPanel(panel, atY: currentY, height: panelHeight)
                currentY -= Self.verticalMargin
            }
        }

        canvas.unlockFocus()

        return canvas
    }

    /// コマの高さを計算
    private func calculatePanelHeight(_ panel: ComposerPanel) -> CGFloat? {
        if panel.isSplit {
            // 分割コマ
            guard let leftImage = panel.leftImage.image,
                  let rightImage = panel.rightImage?.image else {
                // 片方だけでも画像があれば処理
                if let leftImage = panel.leftImage.image {
                    return resizedHeight(for: leftImage, targetWidth: Self.splitPanelWidth)
                }
                if let rightImage = panel.rightImage?.image {
                    return resizedHeight(for: rightImage, targetWidth: Self.splitPanelWidth)
                }
                return nil
            }

            // 両方の画像を250pxにリサイズした時の高さを計算
            let leftHeight = resizedHeight(for: leftImage, targetWidth: Self.splitPanelWidth)
            let rightHeight = resizedHeight(for: rightImage, targetWidth: Self.splitPanelWidth)

            // 短い方に合わせる
            return min(leftHeight, rightHeight)
        } else {
            // 単一コマ
            guard let image = panel.leftImage.image else {
                return nil
            }
            return resizedHeight(for: image, targetWidth: Self.panelWidth)
        }
    }

    /// 画像をターゲット幅にリサイズした時の高さを計算
    private func resizedHeight(for image: NSImage, targetWidth: CGFloat) -> CGFloat {
        let aspectRatio = image.size.height / image.size.width
        return targetWidth * aspectRatio
    }

    /// 白背景のキャンバスを作成
    private func createWhiteCanvas(width: CGFloat, height: CGFloat) -> NSImage? {
        let canvas = NSImage(size: NSSize(width: width, height: height))
        canvas.lockFocus()

        // 白で塗りつぶし
        NSColor.white.setFill()
        NSBezierPath.fill(NSRect(x: 0, y: 0, width: width, height: height))

        canvas.unlockFocus()
        return canvas
    }

    /// ヘッダー（タイトル・作者）を描画
    private func drawHeader(canvasHeight: CGFloat) {
        let titleFont = NSFont.boldSystemFont(ofSize: Self.titleFontSize)
        let authorFont = NSFont.systemFont(ofSize: Self.authorFontSize)

        // ヘッダーの開始Y座標（キャンバス上部）
        let headerTop = canvasHeight - Self.headerHeight

        // タイトル（左寄せ）
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: NSColor.black
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let titleY = headerTop + (Self.headerHeight - Self.titleFontSize) / 2
        titleString.draw(at: NSPoint(x: Self.horizontalMargin, y: titleY))

        // 作者（右寄せ、空欄でなければ）
        if !authorName.trimmingCharacters(in: .whitespaces).isEmpty {
            let authorAttributes: [NSAttributedString.Key: Any] = [
                .font: authorFont,
                .foregroundColor: NSColor.darkGray
            ]
            let authorString = NSAttributedString(string: authorName, attributes: authorAttributes)
            let authorWidth = authorString.size().width
            let authorX = Self.canvasWidth - Self.horizontalMargin - authorWidth
            let authorY = headerTop + (Self.headerHeight - Self.authorFontSize) / 2
            authorString.draw(at: NSPoint(x: authorX, y: authorY))
        }
    }

    /// コマを描画
    private func drawPanel(_ panel: ComposerPanel, atY y: CGFloat, height: CGFloat) {
        if panel.isSplit {
            drawSplitPanel(panel, atY: y, height: height)
        } else {
            drawSinglePanel(panel, atY: y, height: height)
        }
    }

    /// 単一コマを描画
    private func drawSinglePanel(_ panel: ComposerPanel, atY y: CGFloat, height: CGFloat) {
        guard let image = panel.leftImage.image else { return }

        // 500pxにリサイズ
        let resizedImage = resizeImage(image, toWidth: Self.panelWidth, toHeight: height)

        // 中央に配置（左右20px余白）
        resizedImage?.draw(
            in: NSRect(x: Self.horizontalMargin, y: y, width: Self.panelWidth, height: height),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 1.0
        )
    }

    /// 分割コマを描画
    private func drawSplitPanel(_ panel: ComposerPanel, atY y: CGFloat, height: CGFloat) {
        // 左画像
        if let leftImage = panel.leftImage.image {
            let leftResized = resizeImageToFit(leftImage, maxWidth: Self.splitPanelWidth, maxHeight: height)
            if let resized = leftResized {
                // 中央寄せ
                let offsetX = (Self.splitPanelWidth - resized.size.width) / 2
                let offsetY = (height - resized.size.height) / 2
                resized.draw(
                    in: NSRect(
                        x: Self.horizontalMargin + offsetX,
                        y: y + offsetY,
                        width: resized.size.width,
                        height: resized.size.height
                    ),
                    from: NSRect.zero,
                    operation: .sourceOver,
                    fraction: 1.0
                )
            }
        }

        // 右画像（左コマ + コマ間余白の後から開始）
        if let rightImage = panel.rightImage?.image {
            let rightResized = resizeImageToFit(rightImage, maxWidth: Self.splitPanelWidth, maxHeight: height)
            if let resized = rightResized {
                // 中央寄せ
                let offsetX = (Self.splitPanelWidth - resized.size.width) / 2
                let offsetY = (height - resized.size.height) / 2
                // 右コマの開始X = 左余白 + 左コマ幅 + コマ間余白
                let rightStartX = Self.horizontalMargin + Self.splitPanelWidth + Self.splitPanelGap
                resized.draw(
                    in: NSRect(
                        x: rightStartX + offsetX,
                        y: y + offsetY,
                        width: resized.size.width,
                        height: resized.size.height
                    ),
                    from: NSRect.zero,
                    operation: .sourceOver,
                    fraction: 1.0
                )
            }
        }
    }

    /// 画像を指定サイズにリサイズ
    private func resizeImage(_ image: NSImage, toWidth width: CGFloat, toHeight height: CGFloat) -> NSImage? {
        let newSize = NSSize(width: width, height: height)
        let resizedImage = NSImage(size: newSize)

        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1.0
        )
        resizedImage.unlockFocus()

        return resizedImage
    }

    /// 画像を最大サイズに収まるようにリサイズ（アスペクト比維持）
    private func resizeImageToFit(_ image: NSImage, maxWidth: CGFloat, maxHeight: CGFloat) -> NSImage? {
        let originalSize = image.size
        let widthRatio = maxWidth / originalSize.width
        let heightRatio = maxHeight / originalSize.height
        let ratio = min(widthRatio, heightRatio)

        let newWidth = originalSize.width * ratio
        let newHeight = originalSize.height * ratio

        return resizeImage(image, toWidth: newWidth, toHeight: newHeight)
    }

    /// 出力ファイル名を生成
    private func generateOutputFilename() -> String {
        if !title.trimmingCharacters(in: .whitespaces).isEmpty {
            return "\(title).png"
        }
        return "manga.png"
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
