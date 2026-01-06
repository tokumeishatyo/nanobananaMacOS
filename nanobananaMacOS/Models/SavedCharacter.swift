import Foundation

// MARK: - SavedCharacter
/// キャラクターデータベース用モデル
/// 漫画コンポーザーで使用するキャラクター情報を保存
struct SavedCharacter: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String           // キャラクタ名（一意、必須）
    var faceFeatures: String   // 顔の特徴（必須）
    var bodyFeatures: String   // 体型の特徴
    var personality: String    // パーソナリティ

    init(
        id: UUID = UUID(),
        name: String,
        faceFeatures: String,
        bodyFeatures: String = "",
        personality: String = ""
    ) {
        self.id = id
        self.name = name
        self.faceFeatures = faceFeatures
        self.bodyFeatures = bodyFeatures
        self.personality = personality
    }
}
