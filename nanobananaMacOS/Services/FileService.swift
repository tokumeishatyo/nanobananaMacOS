import Foundation
import AppKit
import UniformTypeIdentifiers

/// ファイル操作結果
enum FileOperationResult {
    case success
    case cancelled
    case failure(message: String)
}

/// ファイルサービスプロトコル
protocol FileServiceProtocol {
    func saveYAML(content: String, suggestedFileName: String) async -> FileOperationResult
    func loadYAML() async -> (result: FileOperationResult, content: String?)
}

/// ファイルサービス実装
@MainActor
final class FileService: FileServiceProtocol {

    /// YAMLをファイルに保存
    /// - Parameters:
    ///   - content: 保存するYAML内容
    ///   - suggestedFileName: 推奨ファイル名（タイトルから取得）
    /// - Returns: 操作結果
    func saveYAML(content: String, suggestedFileName: String) async -> FileOperationResult {
        let savePanel = NSSavePanel()
        // YAMLはplainTextとして扱い、拡張子で制御
        savePanel.allowedContentTypes = [.plainText]
        savePanel.allowsOtherFileTypes = true
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "YAMLを保存"
        savePanel.message = "YAMLファイルの保存先を選択してください"

        // 推奨ファイル名を設定（拡張子を除去し、.yamlを追加）
        let cleanFileName = suggestedFileName
            .replacingOccurrences(of: ".yaml", with: "")
            .replacingOccurrences(of: ".yml", with: "")
        let fileName = (cleanFileName.isEmpty ? "output" : cleanFileName) + ".yaml"
        savePanel.nameFieldStringValue = fileName

        guard let window = NSApp.keyWindow else {
            return .failure(message: "ウィンドウが見つかりません")
        }

        let response = await savePanel.beginSheetModal(for: window)

        guard response == .OK, let url = savePanel.url else {
            return .cancelled
        }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return .success
        } catch {
            return .failure(message: "ファイルの保存に失敗しました: \(error.localizedDescription)")
        }
    }

    /// YAMLファイルを読み込む
    /// - Returns: 操作結果と読み込んだ内容
    func loadYAML() async -> (result: FileOperationResult, content: String?) {
        let openPanel = NSOpenPanel()
        // YAMLはplainTextとして扱う
        openPanel.allowedContentTypes = [.plainText]
        openPanel.allowsOtherFileTypes = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.title = "YAMLを読込"
        openPanel.message = "読み込むYAMLファイルを選択してください"

        guard let window = NSApp.keyWindow else {
            return (.failure(message: "ウィンドウが見つかりません"), nil)
        }

        let response = await openPanel.beginSheetModal(for: window)

        guard response == .OK, let url = openPanel.url else {
            return (.cancelled, nil)
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return (.success, content)
        } catch {
            return (.failure(message: "ファイルの読み込みに失敗しました: \(error.localizedDescription)"), nil)
        }
    }

    /// 画像をファイルに保存
    /// - Parameters:
    ///   - image: 保存する画像
    ///   - suggestedFileName: 推奨ファイル名
    /// - Returns: 操作結果
    func saveImage(image: NSImage, suggestedFileName: String) async -> FileOperationResult {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "画像を保存"
        savePanel.message = "画像ファイルの保存先を選択してください"

        // 推奨ファイル名を設定
        let cleanFileName = suggestedFileName
            .replacingOccurrences(of: ".png", with: "")
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".jpeg", with: "")
        let fileName = (cleanFileName.isEmpty ? "image" : cleanFileName) + ".png"
        savePanel.nameFieldStringValue = fileName

        guard let window = NSApp.keyWindow else {
            return .failure(message: "ウィンドウが見つかりません")
        }

        let response = await savePanel.beginSheetModal(for: window)

        guard response == .OK, let url = savePanel.url else {
            return .cancelled
        }

        // 画像をPNGとして保存
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return .failure(message: "画像データの変換に失敗しました")
        }

        do {
            try pngData.write(to: url)
            return .success
        } catch {
            return .failure(message: "画像の保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
