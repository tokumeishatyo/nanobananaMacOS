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

    enum CodingKeys: String, CodingKey {
        case name
        case dialogue
        case features
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
