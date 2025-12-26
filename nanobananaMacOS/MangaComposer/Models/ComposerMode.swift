// rule.mdを読むこと
import Foundation

// MARK: - Composer Mode
/// 漫画ページコンポーザーのモード定義
enum ComposerMode: String, CaseIterable, Identifiable {
    case characterSheet = "登場人物生成シート"
    case mangaCreation = "漫画作成"

    var id: String { rawValue }

    /// モードが有効か（漫画作成は後日実装）
    var isEnabled: Bool {
        switch self {
        case .characterSheet: return true
        case .mangaCreation: return false  // 後日実装
        }
    }

    /// モードの説明
    var description: String {
        switch self {
        case .characterSheet:
            return "1〜3名のキャラクターを紹介する画像を生成"
        case .mangaCreation:
            return "登場人物を使って漫画を生成（後日実装）"
        }
    }
}

// BackgroundSourceType は DropdownOptions.swift で定義済み
