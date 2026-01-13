// rule.mdを読むこと
import Foundation

// MARK: - Story YAML Generator
/// ストーリーYAML生成サービス
/// v2形式（actors対応）で1コマ/4コマ両対応
final class StoryYAMLGenerator {

    // MARK: - Generation Context
    /// YAML生成に必要なデータをまとめた構造体
    struct GenerationContext {
        let title: String
        let selectedCharacters: [SavedCharacter]
        let panels: [StoryPanel]
        let enableTranslation: Bool

        /// 翻訳対象のテキストを収集（将来の翻訳機能用）
        var textsToTranslate: [TranslatableText] {
            var texts: [TranslatableText] = []

            for (panelIndex, panel) in panels.enumerated() {
                // シーン
                if !panel.scene.isEmpty {
                    texts.append(TranslatableText(
                        key: "panel_\(panelIndex)_scene",
                        original: panel.scene
                    ))
                }

                for (charIndex, character) in panel.characters.enumerated() {
                    // features
                    if !character.features.isEmpty {
                        texts.append(TranslatableText(
                            key: "panel_\(panelIndex)_char_\(charIndex)_features",
                            original: character.features
                        ))
                    }

                    // インセット用フィールド
                    if character.renderMode == .insetVisualization {
                        if !character.internalBackground.isEmpty {
                            texts.append(TranslatableText(
                                key: "panel_\(panelIndex)_char_\(charIndex)_internal_background",
                                original: character.internalBackground
                            ))
                        }
                        if !character.internalOutfit.isEmpty {
                            texts.append(TranslatableText(
                                key: "panel_\(panelIndex)_char_\(charIndex)_internal_outfit",
                                original: character.internalOutfit
                            ))
                        }
                        if !character.internalSituation.isEmpty {
                            texts.append(TranslatableText(
                                key: "panel_\(panelIndex)_char_\(charIndex)_internal_situation",
                                original: character.internalSituation
                            ))
                        }
                        if !character.internalEmotion.isEmpty {
                            texts.append(TranslatableText(
                                key: "panel_\(panelIndex)_char_\(charIndex)_internal_emotion",
                                original: character.internalEmotion
                            ))
                        }

                        // ゲストの外見
                        for (guestIndex, guest) in character.guests.enumerated() {
                            if !guest.guestDescription.isEmpty {
                                texts.append(TranslatableText(
                                    key: "panel_\(panelIndex)_char_\(charIndex)_guest_\(guestIndex)_description",
                                    original: guest.guestDescription
                                ))
                            }
                        }
                    }
                }
            }

            return texts
        }
    }

    /// 翻訳対象テキスト
    struct TranslatableText {
        let key: String
        var original: String
        var translated: String?

        var effectiveValue: String {
            translated ?? original
        }
    }

    // MARK: - Generate YAML

    /// YAMLを生成（翻訳なし版）
    func generate(context: GenerationContext) -> String {
        // 翻訳なしの場合はそのまま生成
        return generateYAMLString(context: context, translations: [:])
    }

    /// YAMLを生成（翻訳あり版 - 将来実装用）
    /// - Parameters:
    ///   - context: 生成コンテキスト
    ///   - translations: 翻訳結果（key -> translated text）
    func generate(context: GenerationContext, translations: [String: String]) -> String {
        return generateYAMLString(context: context, translations: translations)
    }

    // MARK: - Private Methods

    private func generateYAMLString(context: GenerationContext, translations: [String: String]) -> String {
        var yaml = ""

        // ヘッダーコメント
        yaml += "# ====================================================\n"
        yaml += "# 漫画ストーリー YAML\n"
        yaml += "# ====================================================\n\n"

        // タイトル
        yaml += "title: \"\(escapeYAML(context.title))\"\n\n"

        // Actorsセクション
        yaml += generateActorsSection(characters: context.selectedCharacters)

        // Charactersセクション（後方互換性用）
        yaml += generateCharactersSection(characters: context.selectedCharacters)

        // Panelsセクション
        yaml += generatePanelsSection(
            panels: context.panels,
            selectedCharacters: context.selectedCharacters,
            translations: translations
        )

        return yaml
    }

    // MARK: - Actors Section

    private func generateActorsSection(characters: [SavedCharacter]) -> String {
        guard !characters.isEmpty else { return "" }

        var section = "# ====================================================\n"
        section += "# Actors (Component Registry)\n"
        section += "# ====================================================\n"
        section += "actors:\n"

        for (index, character) in characters.enumerated() {
            let actorKey = actorKeyForIndex(index)
            section += "  \(actorKey):\n"
            section += "    name: \"\(escapeYAML(character.name))\"\n"
            section += "    face_reference: \"\"\n"
            section += "    chibi_reference: \"\"\n"

            // appearance_compilation
            if !character.faceFeatures.isEmpty || !character.bodyFeatures.isEmpty {
                section += "    appearance_compilation:\n"
                if !character.faceFeatures.isEmpty {
                    section += "      Face: \"\(escapeYAML(character.faceFeatures))\"\n"
                }
                if !character.bodyFeatures.isEmpty {
                    section += "      Body: \"\(escapeYAML(character.bodyFeatures))\"\n"
                }
            }
            section += "\n"
        }

        return section
    }

    // MARK: - Characters Section

    private func generateCharactersSection(characters: [SavedCharacter]) -> String {
        guard !characters.isEmpty else { return "" }

        var section = "# ====================================================\n"
        section += "# Characters (従来形式)\n"
        section += "# ====================================================\n"
        section += "characters:\n"

        for (index, character) in characters.enumerated() {
            section += "  - id: \"\(index + 1)\"\n"
            section += "    name: \"\(escapeYAML(character.name))\"\n"
        }
        section += "\n"

        return section
    }

    // MARK: - Panels Section

    private func generatePanelsSection(
        panels: [StoryPanel],
        selectedCharacters: [SavedCharacter],
        translations: [String: String]
    ) -> String {
        var section = "# ====================================================\n"
        section += "# Panels\n"
        section += "# ====================================================\n"
        section += "panels:\n"

        for (panelIndex, panel) in panels.enumerated() {
            section += "  - panel: \(panel.panelNumber)\n"

            // シーン（翻訳対象）
            let sceneKey = "panel_\(panelIndex)_scene"
            let sceneValue = translations[sceneKey] ?? panel.scene
            section += "    scene: \"\(escapeYAML(sceneValue))\"\n"

            // ナレーション
            if !panel.narration.isEmpty {
                section += "    narration: \"\(escapeYAML(panel.narration))\"\n"
            }

            // モブ
            section += "    mob: \(panel.hasMob)\n"

            // キャラクター
            if !panel.characters.isEmpty {
                section += "    characters:\n"
                for (charIndex, character) in panel.characters.enumerated() {
                    section += generateCharacterEntry(
                        character: character,
                        panelIndex: panelIndex,
                        charIndex: charIndex,
                        selectedCharacters: selectedCharacters,
                        translations: translations
                    )
                }
            }
            section += "\n"
        }

        return section
    }

    // MARK: - Character Entry

    private func generateCharacterEntry(
        character: StoryPanelCharacter,
        panelIndex: Int,
        charIndex: Int,
        selectedCharacters: [SavedCharacter],
        translations: [String: String]
    ) -> String {
        var entry = ""

        // アクター参照とキャラ名
        if let selectedId = character.selectedCharacterId,
           let charIndex = selectedCharacters.firstIndex(where: { $0.id == selectedId }) {
            let actorKey = actorKeyForIndex(charIndex)
            let charName = selectedCharacters[charIndex].name
            entry += "      - actor: \"\(actorKey)\"\n"
            entry += "        name: \"\(escapeYAML(charName))\"\n"
        } else {
            entry += "      - actor: \"\"\n"
            entry += "        name: \"\"\n"
        }

        // render_mode
        entry += "        render_mode: \"\(character.renderMode.rawValue)\"\n"

        // render_modeによって出力を分岐
        if character.renderMode == .insetVisualization {
            entry += generateInsetFields(
                character: character,
                panelIndex: panelIndex,
                charIndex: charIndex,
                translations: translations
            )
        } else {
            entry += generateNormalFields(
                character: character,
                panelIndex: panelIndex,
                charIndex: charIndex,
                translations: translations
            )
        }

        return entry
    }

    // MARK: - Normal Fields (full_body, bubble_only, text_only)

    private func generateNormalFields(
        character: StoryPanelCharacter,
        panelIndex: Int,
        charIndex: Int,
        translations: [String: String]
    ) -> String {
        var fields = ""

        // dialogue
        if !character.dialogue.isEmpty {
            fields += "        dialogue: \"\(escapeYAML(character.dialogue))\"\n"
        }

        // features（翻訳対象）
        let featuresKey = "panel_\(panelIndex)_char_\(charIndex)_features"
        let featuresValue = translations[featuresKey] ?? character.features
        if !featuresValue.isEmpty {
            fields += "        features: \"\(escapeYAML(featuresValue))\"\n"
        }

        return fields
    }

    // MARK: - Inset Fields

    private func generateInsetFields(
        character: StoryPanelCharacter,
        panelIndex: Int,
        charIndex: Int,
        translations: [String: String]
    ) -> String {
        var fields = ""

        // internal_background（翻訳対象）
        let bgKey = "panel_\(panelIndex)_char_\(charIndex)_internal_background"
        let bgValue = translations[bgKey] ?? character.internalBackground
        if !bgValue.isEmpty {
            fields += "        internal_background: \"\(escapeYAML(bgValue))\"\n"
        }

        // internal_outfit（翻訳対象）
        let outfitKey = "panel_\(panelIndex)_char_\(charIndex)_internal_outfit"
        let outfitValue = translations[outfitKey] ?? character.internalOutfit
        if !outfitValue.isEmpty {
            fields += "        internal_outfit: \"\(escapeYAML(outfitValue))\"\n"
        }

        // internal_situation（翻訳対象）
        let situationKey = "panel_\(panelIndex)_char_\(charIndex)_internal_situation"
        let situationValue = translations[situationKey] ?? character.internalSituation
        if !situationValue.isEmpty {
            fields += "        internal_situation: \"\(escapeYAML(situationValue))\"\n"
        }

        // internal_emotion（翻訳対象）
        let emotionKey = "panel_\(panelIndex)_char_\(charIndex)_internal_emotion"
        let emotionValue = translations[emotionKey] ?? character.internalEmotion
        if !emotionValue.isEmpty {
            fields += "        internal_emotion: \"\(escapeYAML(emotionValue))\"\n"
        }

        // internal_dialogue
        if !character.internalDialogue.isEmpty {
            fields += "        internal_dialogue: \"\(escapeYAML(character.internalDialogue))\"\n"
        }

        // guests（複数対応）
        if !character.guests.isEmpty {
            fields += "        guests:\n"
            for (guestIndex, guest) in character.guests.enumerated() {
                fields += "          - name: \"\(escapeYAML(guest.name))\"\n"

                // description（翻訳対象）
                let descKey = "panel_\(panelIndex)_char_\(charIndex)_guest_\(guestIndex)_description"
                let descValue = translations[descKey] ?? guest.guestDescription
                fields += "            description: \"\(escapeYAML(descValue))\"\n"

                // dialogue
                if !guest.dialogue.isEmpty {
                    fields += "            dialogue: \"\(escapeYAML(guest.dialogue))\"\n"
                }
            }
        }

        return fields
    }

    // MARK: - Utilities

    /// インデックスからアクターキーを生成（actor_A, actor_B, ...）
    private func actorKeyForIndex(_ index: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if index < letters.count {
            let letter = letters[letters.index(letters.startIndex, offsetBy: index)]
            return "actor_\(letter)"
        } else {
            return "actor_\(index + 1)"
        }
    }

    /// YAML文字列のエスケープ
    private func escapeYAML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
