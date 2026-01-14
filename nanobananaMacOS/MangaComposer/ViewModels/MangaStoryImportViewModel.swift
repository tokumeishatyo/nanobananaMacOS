// MangaStoryImportViewModel.swift
// 漫画ストーリーYAMLインポートのViewModel

import Foundation
import SwiftUI
import Combine

// MARK: - Manga Story Import ViewModel

@MainActor
final class MangaStoryImportViewModel: ObservableObject {

    // MARK: - Input
    @Published var yamlPath: String = ""

    // MARK: - Parsed Data
    @Published var parsedYAML: MangaStoryYAML?
    @Published var characterMatchResults: [CharacterMatchResult] = []

    // MARK: - State
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Dependencies
    private let savedCharacters: [SavedCharacter]

    init(savedCharacters: [SavedCharacter]) {
        self.savedCharacters = savedCharacters
    }

    // MARK: - Computed Properties

    /// YAMLが読み込まれているか
    var hasLoadedYAML: Bool {
        parsedYAML != nil
    }

    /// タイトル（表示用）
    var title: String {
        parsedYAML?.title ?? ""
    }

    /// 全キャラクターがDBに登録されているか
    var allCharactersMatched: Bool {
        !characterMatchResults.isEmpty &&
        characterMatchResults.allSatisfy { $0.isMatched }
    }

    /// OKボタンを有効にするか
    var canApply: Bool {
        parsedYAML != nil && allCharactersMatched
    }

    /// 未登録キャラクター数
    var unmatchedCount: Int {
        characterMatchResults.filter { !$0.isMatched }.count
    }

    /// パネル数
    var panelCount: Int {
        parsedYAML?.panels?.count ?? 0
    }

    // MARK: - Actions

    /// YAMLファイルを読み込み
    func loadYAML(from url: URL) {
        isLoading = true
        errorMessage = nil

        do {
            // セキュリティスコープのアクセス開始
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let content = try String(contentsOf: url, encoding: .utf8)
            let yaml = try parseYAML(content)

            parsedYAML = yaml
            yamlPath = url.lastPathComponent

            // キャラクター照合
            matchCharacters()

        } catch {
            errorMessage = "YAMLの読み込みに失敗しました: \(error.localizedDescription)"
            parsedYAML = nil
            characterMatchResults = []
        }

        isLoading = false
    }

    /// YAMLをパース（簡易パーサー）
    private func parseYAML(_ content: String) throws -> MangaStoryYAML {
        // 簡易YAMLパーサー
        // 注: 本格的なYAMLパースにはYamsライブラリの導入を推奨
        var title: String?
        var characters: [MangaStoryCharacter] = []
        var actors: [String: MangaStoryActor] = [:]  // v2: actorsセクション
        var panels: [MangaStoryPanel] = []

        let lines = content.components(separatedBy: .newlines)
        var currentSection: String?
        var currentPanel: Int?
        var currentPanelScene: String?
        var currentPanelTags: String?
        var currentPanelNarration: String?
        var currentPanelMob: Bool = false
        var currentPanelCharacters: [MangaStoryPanelCharacter] = []

        // パネル内キャラクター用
        var currentCharActor: String?
        var currentCharName: String?
        var currentCharDialogue: String?
        var currentCharFeature: String?
        var currentCharPosition: String?
        var currentCharRenderMode: String?
        var currentCharBubbleStyle: String?
        var currentCharVisible: Bool?
        // インセット設定
        var currentCharContainerType: String?
        var currentCharInternalBackground: String?
        var currentCharInternalOutfit: String?
        var currentCharInternalSituation: String?
        var currentCharInternalEmotion: String?
        var currentCharGuestName: String?
        var currentCharGuestDescription: String?
        var currentCharInternalDialogue: [String] = []

        var inPanelCharacters = false
        var inInternalDialogue = false

        // actorsセクション用
        var currentActorKey: String?
        var currentActorName: String?
        var currentActorFaceRef: String?
        var currentActorChibiRef: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // 空行・コメントはスキップ
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            // タイトル
            if trimmed.hasPrefix("title:") {
                title = extractValue(from: trimmed, key: "title:")
                currentSection = nil
                continue
            }

            // セクション開始（トップレベルのみ）
            if trimmed == "characters:" && currentSection == nil {
                currentSection = "characters"
                continue
            }
            if trimmed == "actors:" {
                currentSection = "actors"
                continue
            }
            if trimmed == "panels:" {
                // 前のアクターを保存
                saveCurrentActor()
                currentSection = "panels"
                continue
            }

            // actorsセクション（v2フォーマット）
            if currentSection == "actors" {
                // actor_A: のような行
                if trimmed.hasSuffix(":") && !trimmed.hasPrefix("-") && !trimmed.hasPrefix("name:") && !trimmed.hasPrefix("face_reference:") && !trimmed.hasPrefix("chibi_reference:") && !trimmed.hasPrefix("appearance_compilation:") && !trimmed.hasPrefix("Face:") && !trimmed.hasPrefix("Body:") && !trimmed.hasPrefix("Outfit:") {
                    // 前のアクターを保存
                    saveCurrentActor()
                    currentActorKey = String(trimmed.dropLast())
                    currentActorName = nil
                    currentActorFaceRef = nil
                    currentActorChibiRef = nil
                    continue
                }
                if trimmed.hasPrefix("name:") {
                    currentActorName = extractValue(from: trimmed, key: "name:")
                    continue
                }
                if trimmed.hasPrefix("face_reference:") {
                    currentActorFaceRef = extractValue(from: trimmed, key: "face_reference:")
                    continue
                }
                if trimmed.hasPrefix("chibi_reference:") {
                    currentActorChibiRef = extractValue(from: trimmed, key: "chibi_reference:")
                    continue
                }
                // appearance_compilation内のフィールドはスキップ
                continue
            }

            // charactersセクション（v1フォーマット）
            if currentSection == "characters" {
                if trimmed.hasPrefix("- id:") || trimmed.hasPrefix("-  id:") {
                    continue
                }
                if trimmed.hasPrefix("id:") {
                    continue
                }
                if trimmed.hasPrefix("- name:") {
                    let name = extractValue(from: trimmed, key: "- name:")
                    if let name = name, !name.isEmpty {
                        characters.append(MangaStoryCharacter(characterId: nil, name: name))
                    }
                    continue
                }
                if trimmed.hasPrefix("name:") {
                    let name = extractValue(from: trimmed, key: "name:")
                    if let name = name, !name.isEmpty {
                        characters.append(MangaStoryCharacter(characterId: nil, name: name))
                    }
                    continue
                }
            }

            // panelsセクション
            if currentSection == "panels" {
                // 新しいパネル開始
                if trimmed.hasPrefix("- panel:") {
                    // 前のパネルを保存
                    savePanelIfNeeded()
                    // リセット
                    currentPanel = Int(extractValue(from: trimmed, key: "- panel:") ?? "0")
                    resetPanelState()
                    continue
                }

                if trimmed.hasPrefix("scene:") {
                    currentPanelScene = extractValue(from: trimmed, key: "scene:")
                    continue
                }
                if trimmed.hasPrefix("tags:") {
                    currentPanelTags = extractValue(from: trimmed, key: "tags:")
                    continue
                }
                if trimmed.hasPrefix("narration:") {
                    currentPanelNarration = extractValue(from: trimmed, key: "narration:")
                    continue
                }
                if trimmed.hasPrefix("mob:") {
                    let mobValue = extractValue(from: trimmed, key: "mob:")
                    currentPanelMob = (mobValue == "true")
                    continue
                }
                if trimmed == "characters:" {
                    inPanelCharacters = true
                    continue
                }

                // パネル内キャラクター
                if inPanelCharacters {
                    // 新しいキャラクター開始のチェック（- actor: または - name:）
                    // NOTE: internal_dialogue配列内でも新しいキャラクター開始を優先して検出
                    if trimmed.hasPrefix("- actor:") || trimmed.hasPrefix("- name:") {
                        // internal_dialogue配列内だった場合は終了
                        if inInternalDialogue {
                            inInternalDialogue = false
                        }
                        // 前のキャラクターを保存
                        saveCurrentCharacter()
                        resetCharacterState()

                        if trimmed.hasPrefix("- actor:") {
                            currentCharActor = extractValue(from: trimmed, key: "- actor:")
                        } else {
                            currentCharName = extractValue(from: trimmed, key: "- name:")
                        }
                        continue
                    }

                    // internal_dialogue配列内
                    if inInternalDialogue {
                        if trimmed.hasPrefix("- ") {
                            let dialogueLine = String(trimmed.dropFirst(2))
                                .trimmingCharacters(in: .whitespaces)
                                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                            currentCharInternalDialogue.append(dialogueLine)
                            continue
                        } else {
                            // 配列終了
                            inInternalDialogue = false
                        }
                    }

                    // キャラクターのフィールド
                    if trimmed.hasPrefix("name:") {
                        currentCharName = extractValue(from: trimmed, key: "name:")
                        continue
                    }
                    if trimmed.hasPrefix("actor:") {
                        currentCharActor = extractValue(from: trimmed, key: "actor:")
                        continue
                    }
                    if trimmed.hasPrefix("dialogue:") {
                        currentCharDialogue = extractValue(from: trimmed, key: "dialogue:")
                        continue
                    }
                    if trimmed.hasPrefix("features:") {
                        currentCharFeature = extractValue(from: trimmed, key: "features:")
                        continue
                    }
                    if trimmed.hasPrefix("position:") {
                        currentCharPosition = extractValue(from: trimmed, key: "position:")
                        continue
                    }
                    if trimmed.hasPrefix("render_mode:") {
                        currentCharRenderMode = extractValue(from: trimmed, key: "render_mode:")
                        continue
                    }
                    if trimmed.hasPrefix("bubble_style:") {
                        currentCharBubbleStyle = extractValue(from: trimmed, key: "bubble_style:")
                        continue
                    }
                    if trimmed.hasPrefix("visible:") {
                        let visibleValue = extractValue(from: trimmed, key: "visible:")
                        currentCharVisible = (visibleValue == "true")
                        continue
                    }

                    // インセット設定
                    if trimmed.hasPrefix("container_type:") {
                        currentCharContainerType = extractValue(from: trimmed, key: "container_type:")
                        continue
                    }
                    if trimmed.hasPrefix("internal_background:") {
                        currentCharInternalBackground = extractValue(from: trimmed, key: "internal_background:")
                        continue
                    }
                    if trimmed.hasPrefix("internal_outfit:") {
                        currentCharInternalOutfit = extractValue(from: trimmed, key: "internal_outfit:")
                        continue
                    }
                    if trimmed.hasPrefix("internal_situation:") {
                        currentCharInternalSituation = extractValue(from: trimmed, key: "internal_situation:")
                        continue
                    }
                    if trimmed.hasPrefix("internal_emotion:") {
                        currentCharInternalEmotion = extractValue(from: trimmed, key: "internal_emotion:")
                        continue
                    }
                    if trimmed.hasPrefix("guest_name:") {
                        currentCharGuestName = extractValue(from: trimmed, key: "guest_name:")
                        continue
                    }
                    if trimmed.hasPrefix("guest_description:") {
                        currentCharGuestDescription = extractValue(from: trimmed, key: "guest_description:")
                        continue
                    }
                    if trimmed == "internal_dialogue:" {
                        inInternalDialogue = true
                        currentCharInternalDialogue = []
                        continue
                    }
                    // internal_dialogue: "single line" 形式
                    if trimmed.hasPrefix("internal_dialogue:") && !trimmed.hasSuffix(":") {
                        if let value = extractValue(from: trimmed, key: "internal_dialogue:") {
                            currentCharInternalDialogue = [value]
                        }
                        continue
                    }
                }
            }
        }

        // 最後のパネルを保存
        savePanelIfNeeded()

        return MangaStoryYAML(title: title, characters: characters.isEmpty ? nil : characters, actors: actors.isEmpty ? nil : actors, panels: panels.isEmpty ? nil : panels)

        // ローカル関数: 現在のアクターを保存
        func saveCurrentActor() {
            if let key = currentActorKey, let name = currentActorName {
                actors[key] = MangaStoryActor(
                    name: name,
                    faceReference: currentActorFaceRef,
                    chibiReference: currentActorChibiRef,
                    appearanceCompilation: nil
                )
            }
        }

        // ローカル関数: 現在のキャラクターを保存
        func saveCurrentCharacter() {
            if currentCharActor != nil || currentCharName != nil {
                let internalDialogueValue: InternalDialogueValue? = currentCharInternalDialogue.isEmpty ? nil :
                    (currentCharInternalDialogue.count == 1 ? .string(currentCharInternalDialogue[0]) : .array(currentCharInternalDialogue))

                currentPanelCharacters.append(MangaStoryPanelCharacter(
                    actor: currentCharActor,
                    name: currentCharName,
                    dialogue: currentCharDialogue,
                    features: currentCharFeature,
                    position: currentCharPosition,
                    renderMode: currentCharRenderMode,
                    bubbleStyle: currentCharBubbleStyle,
                    visible: currentCharVisible,
                    containerType: currentCharContainerType,
                    internalBackground: currentCharInternalBackground,
                    internalOutfit: currentCharInternalOutfit,
                    internalSituation: currentCharInternalSituation,
                    internalEmotion: currentCharInternalEmotion,
                    guestName: currentCharGuestName,
                    guestDescription: currentCharGuestDescription,
                    internalDialogue: internalDialogueValue
                ))
            }
        }

        // ローカル関数: キャラクター状態をリセット
        func resetCharacterState() {
            currentCharActor = nil
            currentCharName = nil
            currentCharDialogue = nil
            currentCharFeature = nil
            currentCharPosition = nil
            currentCharRenderMode = nil
            currentCharBubbleStyle = nil
            currentCharVisible = nil
            currentCharContainerType = nil
            currentCharInternalBackground = nil
            currentCharInternalOutfit = nil
            currentCharInternalSituation = nil
            currentCharInternalEmotion = nil
            currentCharGuestName = nil
            currentCharGuestDescription = nil
            currentCharInternalDialogue = []
            inInternalDialogue = false
        }

        // ローカル関数: パネル状態をリセット
        func resetPanelState() {
            currentPanelScene = nil
            currentPanelTags = nil
            currentPanelNarration = nil
            currentPanelMob = false
            currentPanelCharacters = []
            resetCharacterState()
            inPanelCharacters = false
        }

        // ローカル関数: パネルを保存
        func savePanelIfNeeded() {
            if let panelNum = currentPanel {
                saveCurrentCharacter()
                panels.append(MangaStoryPanel(
                    panel: panelNum,
                    scene: currentPanelScene,
                    tags: currentPanelTags,
                    narration: currentPanelNarration,
                    mob: currentPanelMob,
                    characters: currentPanelCharacters.isEmpty ? nil : currentPanelCharacters
                ))
            }
        }
    }

    /// 値を抽出（key: "value" → "value"）
    private func extractValue(from line: String, key: String) -> String? {
        guard line.contains(key) else { return nil }
        var value = line.replacingOccurrences(of: key, with: "")
            .trimmingCharacters(in: .whitespaces)
        // クォートを除去
        if value.hasPrefix("\"") && value.hasSuffix("\"") {
            value = String(value.dropFirst().dropLast())
        }
        return value.isEmpty ? nil : value
    }

    /// キャラクターをDBと照合
    private func matchCharacters() {
        guard let yaml = parsedYAML else {
            characterMatchResults = []
            return
        }

        var results: [CharacterMatchResult] = []
        var processedNames: Set<String> = []

        // 1. actorsセクションから照合（v2フォーマット）
        if let actors = yaml.actors {
            for (actorKey, actor) in actors {
                guard let name = actor.name, !processedNames.contains(name) else { continue }
                processedNames.insert(name)

                let matched = savedCharacters.first { $0.name == name }
                results.append(CharacterMatchResult(
                    yamlName: name,
                    actorKey: actorKey,
                    matchedCharacter: matched,
                    faceReference: actor.faceReference,
                    chibiReference: actor.chibiReference
                ))
            }
        }

        // 2. charactersセクションから照合（v1フォーマット）
        if let characters = yaml.characters {
            for yamlChar in characters {
                guard !processedNames.contains(yamlChar.name) else { continue }
                processedNames.insert(yamlChar.name)

                let matched = savedCharacters.first { $0.name == yamlChar.name }
                results.append(CharacterMatchResult(
                    yamlName: yamlChar.name,
                    matchedCharacter: matched
                ))
            }
        }

        characterMatchResults = results
    }

    /// 内容をクリア
    func clear() {
        yamlPath = ""
        parsedYAML = nil
        characterMatchResults = []
        errorMessage = nil
    }
}
