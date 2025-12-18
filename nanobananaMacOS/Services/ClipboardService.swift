import Foundation
import AppKit

/// クリップボードサービスプロトコル
protocol ClipboardServiceProtocol {
    func copyToClipboard(text: String)
    func getFromClipboard() -> String?
}

/// クリップボードサービス実装
final class ClipboardService: ClipboardServiceProtocol {

    /// テキストをクリップボードにコピー
    /// - Parameter text: コピーするテキスト
    func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// クリップボードからテキストを取得
    /// - Returns: クリップボードのテキスト（存在しない場合はnil）
    func getFromClipboard() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }
}
