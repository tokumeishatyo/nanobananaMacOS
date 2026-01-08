// rule.mdを読むこと
import Foundation

// MARK: - SavedWardrobe
/// 衣装データベース用モデル
/// 漫画コンポーザーで使用する衣装情報を保存
struct SavedWardrobe: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String           // 衣装名（一意、必須）
    var description: String    // 衣装の説明

    init(
        id: UUID = UUID(),
        name: String,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
    }
}
