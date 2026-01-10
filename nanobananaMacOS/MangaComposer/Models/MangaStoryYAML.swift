// MangaStoryYAML.swift
// 漫画ストーリーYAMLのパース用モデル

import Foundation

// MARK: - Manga Story YAML Model

/// 漫画ストーリーYAMLのルート構造
struct MangaStoryYAML: Decodable {
    let title: String?
    let characters: [MangaStoryCharacter]?
    let panels: [MangaStoryPanel]?
}

/// YAMLの登場人物
struct MangaStoryCharacter: Decodable, Identifiable {
    var id: String { characterId ?? name }

    let characterId: String?
    let name: String

    enum CodingKeys: String, CodingKey {
        case characterId = "id"
        case name
    }
}

/// YAMLのコマ
struct MangaStoryPanel: Decodable, Identifiable {
    var id: Int { panel }

    let panel: Int
    let scene: String?
    let narration: String?
    let mob: Bool?
    let characters: [MangaStoryPanelCharacter]?
}

/// YAMLのコマ内キャラクター
struct MangaStoryPanelCharacter: Decodable, Identifiable {
    let id = UUID()

    let name: String?
    let dialogue: String?
    let features: String?
    let position: String?       // 配置位置（auto, left, center, right）
    let renderMode: String?     // 描画モード（full_body, bubble_only）
    let bubbleStyle: String?    // 吹き出し形状（auto, normal, shout, scream, thought）
    let visible: Bool?          // 後方互換性用（true→full_body, false→bubble_only）

    enum CodingKeys: String, CodingKey {
        case name
        case dialogue
        case features
        case position
        case renderMode = "render_mode"
        case bubbleStyle = "bubble_style"
        case visible
    }
}

// MARK: - Character Match Result

/// キャラクターのDB照合結果
struct CharacterMatchResult: Identifiable {
    let id = UUID()
    let yamlName: String                    // YAMLに記載された名前
    let matchedCharacter: SavedCharacter?   // 一致したDBキャラクター（nilなら未登録）

    /// DBに登録されているか
    var isMatched: Bool {
        matchedCharacter != nil
    }
}
