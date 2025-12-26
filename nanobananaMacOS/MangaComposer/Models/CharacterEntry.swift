// rule.mdを読むこと
import Foundation
import Combine

// MARK: - Character Entry
/// 登場人物シートのキャラクター情報
/// 1〜3名分を管理
final class CharacterEntry: ObservableObject, Identifiable {
    let id: UUID
    @Published var name: String
    @Published var imagePath: String
    @Published var info: String

    init(
        id: UUID = UUID(),
        name: String = "",
        imagePath: String = "",
        info: String = ""
    ) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.info = info
    }

    /// 入力が有効かどうか（名前、画像、説明すべて必須）
    var isValid: Bool {
        !name.isEmpty && !imagePath.isEmpty && !info.isEmpty
    }

    /// プレースホルダーテキスト
    static var infoPlaceholder: String {
        """
        例（箇条書き推奨）：
        ・年齢: 16
        ・性格: 明るく活発、リーダー格
        """
    }

    /// コピーを作成
    func copy() -> CharacterEntry {
        CharacterEntry(
            name: self.name,
            imagePath: self.imagePath,
            info: self.info
        )
    }
}

// MARK: - Character Entry Constants
extension CharacterEntry {
    /// 最小キャラクター数
    static let minCount = 1
    /// 最大キャラクター数
    static let maxCount = 3
}
