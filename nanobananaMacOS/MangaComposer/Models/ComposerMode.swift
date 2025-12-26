// rule.mdを読むこと
import Foundation

// MARK: - Composer Mode
/// 漫画ページコンポーザーのモード定義
enum ComposerMode: String, CaseIterable, Identifiable {
    case characterCard = "キャラクターカード作成"
    case characterSheet = "登場人物生成シート"
    case mangaCreation = "漫画作成"

    var id: String { rawValue }

    /// モードが有効か
    var isEnabled: Bool {
        switch self {
        case .characterCard: return true
        case .characterSheet: return true
        case .mangaCreation: return true
        }
    }

    /// モードの説明
    var description: String {
        switch self {
        case .characterCard:
            return "キャラクター1名分のカードを生成"
        case .characterSheet:
            return "1〜3名のキャラクターを紹介する画像を生成"
        case .mangaCreation:
            return "1〜4コマの漫画を生成"
        }
    }
}

// BackgroundSourceType は DropdownOptions.swift で定義済み
