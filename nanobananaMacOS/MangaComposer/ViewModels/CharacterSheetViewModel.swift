// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Character Sheet ViewModel
/// 登場人物生成シートのViewModel（カード画像ベース）
@MainActor
final class CharacterSheetViewModel: ObservableObject {
    // MARK: - Sheet Title
    @Published var sheetTitle: String = ""

    // MARK: - Background Settings
    @Published var backgroundSourceType: BackgroundSourceType = .prompt  // .file or .prompt
    @Published var backgroundImagePath: String = ""
    @Published var backgroundDescription: String = ""

    // MARK: - Card Images (1〜3枚)
    /// 生成済みキャラクターカードの画像パス
    @Published var cardImagePaths: [String] = [""]

    // MARK: - Constants
    static let minCardCount = 1
    static let maxCardCount = 3

    // MARK: - Computed Properties

    /// 有効なカード数（パスが空でないもの）
    var validCardCount: Int {
        cardImagePaths.filter { !$0.isEmpty }.count
    }

    /// カードを追加可能か
    var canAddCard: Bool {
        cardImagePaths.count < Self.maxCardCount
    }

    /// カードを削除可能か
    var canRemoveCard: Bool {
        cardImagePaths.count > Self.minCardCount
    }

    /// 入力が有効かどうか（YAML生成可能か）
    var isValid: Bool {
        // シートタイトルが必須
        guard !sheetTitle.isEmpty else { return false }

        // 背景設定が有効か
        switch backgroundSourceType {
        case .prompt:
            guard !backgroundDescription.isEmpty else { return false }
        case .file:
            guard !backgroundImagePath.isEmpty else { return false }
        }

        // 最低1枚のカード画像が有効か
        guard validCardCount >= 1 else { return false }

        return true
    }

    // MARK: - Actions

    /// カードスロットを追加
    func addCard() {
        guard canAddCard else { return }
        cardImagePaths.append("")
    }

    /// カードを削除
    func removeCard(at index: Int) {
        guard canRemoveCard, cardImagePaths.indices.contains(index) else { return }
        cardImagePaths.remove(at: index)
    }

    /// カード画像パスを設定
    func setCardImagePath(_ path: String, at index: Int) {
        guard cardImagePaths.indices.contains(index) else { return }
        cardImagePaths[index] = path
    }

    /// リセット
    func reset() {
        sheetTitle = ""
        backgroundSourceType = .prompt
        backgroundImagePath = ""
        backgroundDescription = ""
        cardImagePaths = [""]
    }

    // MARK: - Placeholders

    var sheetTitlePlaceholder: String {
        "例: 登場人物"
    }

    var backgroundDescriptionPlaceholder: String {
        "キャラクターシートの背景の様子を説明する"
    }
}
