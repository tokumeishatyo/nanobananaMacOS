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
        var panels: [MangaStoryPanel] = []

        let lines = content.components(separatedBy: .newlines)
        var currentSection: String?
        var currentPanel: Int?
        var currentPanelScene: String?
        var currentPanelNarration: String?
        var currentPanelMob: Bool = false
        var currentPanelCharacters: [MangaStoryPanelCharacter] = []
        var currentCharName: String?
        var currentCharDialogue: String?
        var currentCharFeature: String?
        var inPanelCharacters = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // 空行はスキップ
            if trimmed.isEmpty { continue }

            // タイトル
            if trimmed.hasPrefix("title:") {
                title = extractValue(from: trimmed, key: "title:")
                currentSection = nil
                continue
            }

            // セクション開始（トップレベルのみ）
            // 注: panelsセクション内のcharacters:は別途処理
            if trimmed == "characters:" && currentSection == nil {
                currentSection = "characters"
                continue
            }
            if trimmed == "panels:" {
                currentSection = "panels"
                continue
            }

            // charactersセクション
            if currentSection == "characters" {
                if trimmed.hasPrefix("- id:") || trimmed.hasPrefix("-  id:") {
                    // 新しいキャラクター開始（idから始まる場合）
                    continue
                }
                if trimmed.hasPrefix("id:") {
                    // id行（ハイフンなし）
                    continue
                }
                if trimmed.hasPrefix("- name:") {
                    // 新しいキャラクター（nameから始まる場合）
                    let name = extractValue(from: trimmed, key: "- name:")
                    if let name = name, !name.isEmpty {
                        characters.append(MangaStoryCharacter(characterId: nil, name: name))
                    }
                    continue
                }
                if trimmed.hasPrefix("name:") {
                    // name行（ハイフンなし、前のidに続く）
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
                    if let panelNum = currentPanel {
                        // 最後のキャラクターを追加
                        if let name = currentCharName {
                            currentPanelCharacters.append(MangaStoryPanelCharacter(
                                name: name,
                                dialogue: currentCharDialogue,
                                features: currentCharFeature
                            ))
                        }
                        panels.append(MangaStoryPanel(
                            panel: panelNum,
                            scene: currentPanelScene,
                            narration: currentPanelNarration,
                            mob: currentPanelMob,
                            characters: currentPanelCharacters
                        ))
                    }
                    // リセット
                    currentPanel = Int(extractValue(from: trimmed, key: "- panel:") ?? "0")
                    currentPanelScene = nil
                    currentPanelNarration = nil
                    currentPanelMob = false
                    currentPanelCharacters = []
                    currentCharName = nil
                    currentCharDialogue = nil
                    currentCharFeature = nil
                    inPanelCharacters = false
                    continue
                }

                if trimmed.hasPrefix("scene:") {
                    currentPanelScene = extractValue(from: trimmed, key: "scene:")
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
                    if trimmed.hasPrefix("- name:") {
                        // 前のキャラクターを保存
                        if let name = currentCharName {
                            currentPanelCharacters.append(MangaStoryPanelCharacter(
                                name: name,
                                dialogue: currentCharDialogue,
                                features: currentCharFeature
                            ))
                        }
                        currentCharName = extractValue(from: trimmed, key: "- name:")
                        currentCharDialogue = nil
                        currentCharFeature = nil
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
                }
            }
        }

        // 最後のパネルを保存
        if let panelNum = currentPanel {
            if let name = currentCharName {
                currentPanelCharacters.append(MangaStoryPanelCharacter(
                    name: name,
                    dialogue: currentCharDialogue,
                    features: currentCharFeature
                ))
            }
            panels.append(MangaStoryPanel(
                panel: panelNum,
                scene: currentPanelScene,
                narration: currentPanelNarration,
                mob: currentPanelMob,
                characters: currentPanelCharacters
            ))
        }

        return MangaStoryYAML(title: title, characters: characters, panels: panels)
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
        guard let yaml = parsedYAML,
              let characters = yaml.characters else {
            characterMatchResults = []
            return
        }

        characterMatchResults = characters.map { yamlChar in
            let matched = savedCharacters.first { $0.name == yamlChar.name }
            return CharacterMatchResult(
                yamlName: yamlChar.name,
                matchedCharacter: matched
            )
        }
    }

    /// 内容をクリア
    func clear() {
        yamlPath = ""
        parsedYAML = nil
        characterMatchResults = []
        errorMessage = nil
    }
}
