// rule.mdを読むこと
import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

/// 画像リサイズツールのViewModel
@MainActor
final class ImageResizeViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 選択された画像
    @Published var selectedImage: NSImage? = nil

    /// 選択されたファイルパス
    @Published var selectedFilePath: String = ""

    /// 選択されたファイル名
    @Published var selectedFilename: String = ""

    /// 元画像の幅（ピクセル）
    @Published var originalWidth: Int = 0

    /// 元画像の高さ（ピクセル）
    @Published var originalHeight: Int = 0

    /// 目標の幅（ピクセル）- ユーザー入力
    @Published var targetWidthString: String = ""

    /// 計算された高さ（ピクセル）
    @Published var calculatedHeight: Int = 0

    /// エラーメッセージ
    @Published var errorMessage: String? = nil

    /// 成功メッセージ
    @Published var successMessage: String? = nil

    /// リサイズ後のプレビュー画像
    @Published var previewImage: NSImage? = nil

    // MARK: - Computed Properties

    /// 画像が選択されているか
    var isImageSelected: Bool {
        selectedImage != nil
    }

    /// 目標の幅（Int）
    var targetWidth: Int {
        Int(targetWidthString) ?? 0
    }

    /// 保存ボタンが有効か
    var canSave: Bool {
        isImageSelected && targetWidth > 0 && calculatedHeight > 0
    }

    /// プレビューボタンが有効か
    var canPreview: Bool {
        canSave
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init() {
        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 目標幅が変更されたら高さを自動計算
        $targetWidthString
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.calculateHeight()
            }
            .store(in: &cancellables)
    }

    /// 高さを自動計算（アスペクト比維持）
    private func calculateHeight() {
        guard originalWidth > 0, originalHeight > 0 else {
            calculatedHeight = 0
            return
        }

        guard let width = Int(targetWidthString), width > 0 else {
            calculatedHeight = 0
            return
        }

        let aspectRatio = Double(originalHeight) / Double(originalWidth)
        calculatedHeight = Int(Double(width) * aspectRatio)
    }

    // MARK: - Public Methods

    /// ファイル選択ダイアログを表示
    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .webP, .gif]

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
        guard ["png", "jpg", "jpeg", "webp", "gif"].contains(ext) else {
            errorMessage = "対応していない画像形式です（PNG, JPEG, WebP, GIF のみ）"
            clearErrorAfterDelay()
            return
        }

        // 画像読み込み
        guard let image = NSImage(contentsOf: url) else {
            errorMessage = "画像を読み込めませんでした"
            clearErrorAfterDelay()
            return
        }

        // ピクセルサイズを取得
        guard let pixelSize = image.pixelSize else {
            errorMessage = "画像サイズを取得できませんでした"
            clearErrorAfterDelay()
            return
        }

        selectedImage = image
        selectedFilePath = url.path
        selectedFilename = url.lastPathComponent
        originalWidth = pixelSize.width
        originalHeight = pixelSize.height
        errorMessage = nil
        successMessage = nil
        previewImage = nil

        // 初期値として元の幅を設定
        targetWidthString = String(originalWidth)
    }

    /// プレビューを生成
    func generatePreview() {
        guard let image = selectedImage, targetWidth > 0, calculatedHeight > 0 else {
            return
        }

        previewImage = resizeImage(image, toWidth: CGFloat(targetWidth), toHeight: CGFloat(calculatedHeight))
    }

    /// リサイズして保存
    func save() {
        guard let image = selectedImage, targetWidth > 0, calculatedHeight > 0 else {
            return
        }

        // リサイズ実行
        guard let resizedImage = resizeImage(image, toWidth: CGFloat(targetWidth), toHeight: CGFloat(calculatedHeight)) else {
            errorMessage = "リサイズに失敗しました"
            clearErrorAfterDelay()
            return
        }

        // 保存ダイアログ
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = generateOutputFilename()

        if panel.runModal() == .OK, let url = panel.url {
            saveImageAsPNG(resizedImage, to: url)
        }
    }

    /// 入力内容をクリア（初期状態に戻す）
    func clear() {
        selectedImage = nil
        selectedFilePath = ""
        selectedFilename = ""
        originalWidth = 0
        originalHeight = 0
        targetWidthString = ""
        calculatedHeight = 0
        errorMessage = nil
        successMessage = nil
        previewImage = nil
    }

    // MARK: - Private Helper Methods

    /// 出力ファイル名を生成
    private func generateOutputFilename() -> String {
        if !selectedFilename.isEmpty {
            let name = (selectedFilename as NSString).deletingPathExtension
            return "\(name)_resize.png"
        }
        return "resized.png"
    }

    /// 画像をリサイズ
    private func resizeImage(_ image: NSImage, toWidth width: CGFloat, toHeight height: CGFloat) -> NSImage? {
        let newSize = NSSize(width: width, height: height)

        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(width),
            pixelsHigh: Int(height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }

        bitmapRep.size = newSize
        NSGraphicsContext.saveGraphicsState()

        if let context = NSGraphicsContext(bitmapImageRep: bitmapRep) {
            NSGraphicsContext.current = context
            context.imageInterpolation = .high

            image.draw(
                in: NSRect(origin: .zero, size: newSize),
                from: NSRect(origin: .zero, size: image.size),
                operation: .copy,
                fraction: 1.0
            )
        }

        NSGraphicsContext.restoreGraphicsState()

        let resizedImage = NSImage(size: newSize)
        resizedImage.addRepresentation(bitmapRep)
        return resizedImage
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

    /// エラーメッセージを数秒後にクリア
    private func clearErrorAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.errorMessage = nil
        }
    }

    /// 成功メッセージを数秒後にクリア
    private func clearSuccessAfterDelay() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self?.successMessage = nil
        }
    }
}

// MARK: - NSImage Extension

extension NSImage {
    /// ピクセルサイズを取得
    var pixelSize: (width: Int, height: Int)? {
        guard let rep = self.representations.first else { return nil }
        return (rep.pixelsWide, rep.pixelsHigh)
    }
}
