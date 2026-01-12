// rule.mdを読むこと
// MangaStoryYAML.swift
// 漫画ストーリーYAMLのパース用モデル

import Foundation

// MARK: - Manga Story YAML Model

/// 漫画ストーリーYAMLのルート構造
struct MangaStoryYAML: Decodable {
    let title: String?
    let characters: [MangaStoryCharacter]?
    let actors: [String: MangaStoryActor]?  // Component Registry（actor_A, actor_B等）
    let panels: [MangaStoryPanel]?

    /// 手動生成用イニシャライザ（簡易パーサー用）
    init(
        title: String? = nil,
        characters: [MangaStoryCharacter]? = nil,
        actors: [String: MangaStoryActor]? = nil,
        panels: [MangaStoryPanel]? = nil
    ) {
        self.title = title
        self.characters = characters
        self.actors = actors
        self.panels = panels
    }
}

/// YAMLの登場人物（後方互換性用）
struct MangaStoryCharacter: Decodable, Identifiable {
    var id: String { characterId ?? name }

    let characterId: String?
    let name: String

    enum CodingKeys: String, CodingKey {
        case characterId = "id"
        case name
    }
}

// MARK: - Actor (Component Registry)

/// YAMLのアクター定義（Component Registry）
struct MangaStoryActor: Decodable {
    let name: String?
    let faceReference: String?       // 顔三面図パス
    let chibiReference: String?      // ちび三面図パス
    let appearanceCompilation: MangaStoryAppearance?

    enum CodingKeys: String, CodingKey {
        case name
        case faceReference = "face_reference"
        case chibiReference = "chibi_reference"
        case appearanceCompilation = "appearance_compilation"
    }
}

/// YAMLの外見情報
struct MangaStoryAppearance: Decodable {
    let face: String?
    let body: String?
    let outfit: String?

    enum CodingKeys: String, CodingKey {
        case face = "Face"
        case body = "Body"
        case outfit = "Outfit"
    }
}

// MARK: - Panel

/// YAMLのコマ
struct MangaStoryPanel: Decodable, Identifiable {
    var id: Int { panelNumber ?? panel ?? 0 }

    let panel: Int?              // 後方互換性
    let panelNumber: Int?        // 新形式
    let scene: String?
    let tags: String?            // シーンタグ
    let narration: String?
    let mob: Bool?
    let characters: [MangaStoryPanelCharacter]?

    enum CodingKeys: String, CodingKey {
        case panel
        case panelNumber = "panel_number"
        case scene
        case tags
        case narration
        case mob
        case characters
    }

    /// 手動生成用イニシャライザ（簡易パーサー用）
    init(
        panel: Int? = nil,
        panelNumber: Int? = nil,
        scene: String? = nil,
        tags: String? = nil,
        narration: String? = nil,
        mob: Bool? = nil,
        characters: [MangaStoryPanelCharacter]? = nil
    ) {
        self.panel = panel
        self.panelNumber = panelNumber
        self.scene = scene
        self.tags = tags
        self.narration = narration
        self.mob = mob
        self.characters = characters
    }
}

// MARK: - Panel Character

/// YAMLのコマ内キャラクター
struct MangaStoryPanelCharacter: Decodable, Identifiable {
    let id = UUID()

    // 基本情報
    let actor: String?           // actorsセクションへの参照（actor_A等）
    let name: String?
    let dialogue: String?
    let features: String?
    let position: String?        // 配置位置（9分割グリッド対応）
    let renderMode: String?      // 描画モード
    let bubbleStyle: String?     // 吹き出し形状
    let visible: Bool?           // 後方互換性用

    // MARK: - Inset Settings (インセット設定)

    // 枠と世界観
    let containerType: String?       // 枠の形状
    let borderStyle: String?         // 枠線スタイル
    let internalStyle: String?       // 内部の画風
    let internalBackground: String?  // 内部の背景
    let internalLighting: String?    // 内部の照明
    let internalFilter: String?      // 内部のフィルタ

    // キャラクターと演技
    let internalReference: String?   // 参照画像タイプ（face/chibi）
    let internalActorName: String?   // 内部でのキャラクター呼称
    let internalOutfit: String?      // 内部での衣装
    let internalShotType: String?    // 内部での構図
    let internalSituation: String?   // 内部での行動
    let internalEmotion: String?     // 内部での表情
    let internalBubbleStyle: String? // 内部の吹き出しスタイル

    // ゲスト
    let guestName: String?           // ゲスト名
    let guestDescription: String?    // ゲスト外見

    // セリフ（配列または文字列）
    let internalDialogue: InternalDialogueValue?

    enum CodingKeys: String, CodingKey {
        case actor
        case name
        case dialogue
        case features
        case position
        case renderMode = "render_mode"
        case bubbleStyle = "bubble_style"
        case visible

        // Inset Settings
        case containerType = "container_type"
        case borderStyle = "border_style"
        case internalStyle = "internal_style"
        case internalBackground = "internal_background"
        case internalLighting = "internal_lighting"
        case internalFilter = "internal_filter"
        case internalReference = "internal_reference"
        case internalActorName = "internal_actor_name"
        case internalOutfit = "internal_outfit"
        case internalShotType = "internal_shot_type"
        case internalSituation = "internal_situation"
        case internalEmotion = "internal_emotion"
        case internalBubbleStyle = "internal_bubble_style"
        case guestName = "guest_name"
        case guestDescription = "guest_description"
        case internalDialogue = "internal_dialogue"
    }

    /// 手動生成用イニシャライザ（簡易パーサー用・後方互換性）
    init(
        actor: String? = nil,
        name: String? = nil,
        dialogue: String? = nil,
        features: String? = nil,
        position: String? = nil,
        renderMode: String? = nil,
        bubbleStyle: String? = nil,
        visible: Bool? = nil,
        // Inset Settings（すべてデフォルトnil）
        containerType: String? = nil,
        borderStyle: String? = nil,
        internalStyle: String? = nil,
        internalBackground: String? = nil,
        internalLighting: String? = nil,
        internalFilter: String? = nil,
        internalReference: String? = nil,
        internalActorName: String? = nil,
        internalOutfit: String? = nil,
        internalShotType: String? = nil,
        internalSituation: String? = nil,
        internalEmotion: String? = nil,
        internalBubbleStyle: String? = nil,
        guestName: String? = nil,
        guestDescription: String? = nil,
        internalDialogue: InternalDialogueValue? = nil
    ) {
        self.actor = actor
        self.name = name
        self.dialogue = dialogue
        self.features = features
        self.position = position
        self.renderMode = renderMode
        self.bubbleStyle = bubbleStyle
        self.visible = visible
        self.containerType = containerType
        self.borderStyle = borderStyle
        self.internalStyle = internalStyle
        self.internalBackground = internalBackground
        self.internalLighting = internalLighting
        self.internalFilter = internalFilter
        self.internalReference = internalReference
        self.internalActorName = internalActorName
        self.internalOutfit = internalOutfit
        self.internalShotType = internalShotType
        self.internalSituation = internalSituation
        self.internalEmotion = internalEmotion
        self.internalBubbleStyle = internalBubbleStyle
        self.guestName = guestName
        self.guestDescription = guestDescription
        self.internalDialogue = internalDialogue
    }
}

// MARK: - Internal Dialogue Value

/// internal_dialogueの配列/文字列両対応
enum InternalDialogueValue: Decodable {
    case string(String)
    case array([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // まず配列としてデコードを試みる
        if let array = try? container.decode([String].self) {
            self = .array(array)
            return
        }

        // 次に文字列としてデコードを試みる
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }

        throw DecodingError.typeMismatch(
            InternalDialogueValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected String or [String] for internal_dialogue"
            )
        )
    }

    /// 文字列として取得（配列の場合は改行で結合）
    var stringValue: String {
        switch self {
        case .string(let str):
            return str
        case .array(let arr):
            return arr.joined(separator: "\n")
        }
    }

    /// 配列として取得（文字列の場合は1要素の配列）
    var arrayValue: [String] {
        switch self {
        case .string(let str):
            return [str]
        case .array(let arr):
            return arr
        }
    }
}

// MARK: - Character Match Result

/// キャラクターのDB照合結果
struct CharacterMatchResult: Identifiable {
    let id = UUID()
    let yamlName: String                    // YAMLに記載された名前
    let actorKey: String?                   // actorsセクションのキー（actor_A等）
    let matchedCharacter: SavedCharacter?   // 一致したDBキャラクター（nilなら未登録）
    let faceReference: String?              // 顔三面図パス（actorsセクションから）
    let chibiReference: String?             // ちび三面図パス（actorsセクションから）

    /// DBに登録されているか
    var isMatched: Bool {
        matchedCharacter != nil
    }

    /// 後方互換性用イニシャライザ
    init(yamlName: String, matchedCharacter: SavedCharacter?) {
        self.yamlName = yamlName
        self.actorKey = nil
        self.matchedCharacter = matchedCharacter
        self.faceReference = nil
        self.chibiReference = nil
    }

    /// 完全版イニシャライザ
    init(yamlName: String, actorKey: String?, matchedCharacter: SavedCharacter?, faceReference: String?, chibiReference: String?) {
        self.yamlName = yamlName
        self.actorKey = actorKey
        self.matchedCharacter = matchedCharacter
        self.faceReference = faceReference
        self.chibiReference = chibiReference
    }
}
