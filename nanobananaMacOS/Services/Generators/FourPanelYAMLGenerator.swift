import Foundation

/// 4コマ漫画YAML生成（Python版_generate_four_panel_yaml準拠）
final class FourPanelYAMLGenerator {

    // MARK: - Generate

    /// 4コマ漫画YAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: FourPanelSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "4コマ漫画" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // スタイル設定
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)

        // キャラクターセクション生成
        let charactersSection = generateCharactersSection(settings: settings)

        // パネルセクション生成
        let panelsSection = generatePanelsSection(settings: settings)

        // YAML生成
        var yaml = """
【画像生成指示 / Image Generation Instructions】
以下のYAML指示に従って、4コマ漫画を1枚の画像として生成してください。
添付したキャラクター設定画を参考に、キャラクターの外見を一貫させてください。

Generate a 4-panel manga as a single image following the YAML instructions below.
Use the attached character reference sheets to maintain consistent character appearances.

---

# 4コマ漫画生成 (four_panel_manga.yaml準拠)
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"
color_mode: "\(colorModeValue)"
output_style: "\(outputStyleValue)"

# 登場人物
characters:\(charactersSection)

# 4コマの内容
panels:\(panelsSection)
# レイアウト指示
layout_instruction: |
  4コマ漫画を縦1列に配置してください。
  横並びにせず、上から下へ1コマずつ縦に4つ並べてください。
  出力画像は縦長（9:16または2:5の比率）で、4コマ漫画だけが画像全体を占めるようにしてください。
  余白は不要です。
  各キャラクターの外見は添付画像と説明を忠実に再現してください。
  セリフは吹き出しで表示し、指定された位置に配置してください。
  ナレーションがある場合は、コマの上部または下部にテキストボックスで表示してください。
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return yaml
    }

    // MARK: - Private Methods

    /// キャラクターセクションを生成
    private func generateCharactersSection(settings: FourPanelSettingsViewModel) -> String {
        var section = ""

        // キャラクター1
        if !settings.character1Name.isEmpty || !settings.character1ImagePath.isEmpty {
            let name = settings.character1Name.isEmpty ? "キャラ1" : settings.character1Name
            let imageRef = settings.character1ImagePath.isEmpty
                ? "添付画像1を参照してください"
                : "添付画像1（\(YAMLUtilities.getFileName(from: settings.character1ImagePath))）を参照してください"
            let description = YAMLUtilities.convertNewlinesToComma(settings.character1Description)

            section += """

  - name: "\(YAMLUtilities.escapeYAMLString(name))"
    reference: "\(imageRef)"
    description: "\(description)"
"""
        }

        // キャラクター2（任意）
        if !settings.character2Name.isEmpty || !settings.character2ImagePath.isEmpty {
            let name = settings.character2Name.isEmpty ? "キャラ2" : settings.character2Name
            let imageRef = settings.character2ImagePath.isEmpty
                ? "添付画像2を参照してください"
                : "添付画像2（\(YAMLUtilities.getFileName(from: settings.character2ImagePath))）を参照してください"
            let description = YAMLUtilities.convertNewlinesToComma(settings.character2Description)

            section += """

  - name: "\(YAMLUtilities.escapeYAMLString(name))"
    reference: "\(imageRef)"
    description: "\(description)"
"""
        }

        return section
    }

    /// パネルセクションを生成
    private func generatePanelsSection(settings: FourPanelSettingsViewModel) -> String {
        let panelLabels = ["起", "承", "転", "結"]
        var section = ""

        for (index, panel) in settings.panels.enumerated() {
            let label = index < panelLabels.count ? panelLabels[index] : String(index + 1)
            let panelNumber = index + 1

            // シーン説明
            let prompt = YAMLUtilities.convertNewlinesToComma(panel.scene)

            // セリフセクション生成
            let speechesSection = generateSpeechesSection(panel: panel, settings: settings)

            // ナレーション
            let narrationLine: String
            if !panel.narration.isEmpty {
                narrationLine = "\n    narration: \"\(YAMLUtilities.escapeYAMLString(panel.narration))\""
            } else {
                narrationLine = ""
            }

            section += """

  # --- \(panelNumber)コマ目（\(label)）---
  - panel_number: \(panelNumber)
    prompt: "\(prompt)"
    speeches:\(speechesSection)\(narrationLine)
"""
        }

        return section
    }

    /// セリフセクションを生成
    private func generateSpeechesSection(panel: MangaPanelData, settings: FourPanelSettingsViewModel) -> String {
        var speeches = ""

        // セリフ1
        if panel.speech1Char != .none && !panel.speech1Text.isEmpty {
            let characterName = getCharacterName(panel.speech1Char, settings: settings)
            let position = getPositionValue(panel.speech1Position)
            speeches += """

      - character: "\(YAMLUtilities.escapeYAMLString(characterName))"
        content: "\(YAMLUtilities.escapeYAMLString(panel.speech1Text))"
        position: "\(position)"
"""
        }

        // セリフ2
        if panel.speech2Char != .none && !panel.speech2Text.isEmpty {
            let characterName = getCharacterName(panel.speech2Char, settings: settings)
            let position = getPositionValue(panel.speech2Position)
            speeches += """

      - character: "\(YAMLUtilities.escapeYAMLString(characterName))"
        content: "\(YAMLUtilities.escapeYAMLString(panel.speech2Text))"
        position: "\(position)"
"""
        }

        return speeches
    }

    /// キャラクター名を取得
    private func getCharacterName(_ character: SpeechCharacter, settings: FourPanelSettingsViewModel) -> String {
        switch character {
        case .character1:
            return settings.character1Name.isEmpty ? "キャラ1" : settings.character1Name
        case .character2:
            return settings.character2Name.isEmpty ? "キャラ2" : settings.character2Name
        case .none:
            return ""
        }
    }

    /// 位置の値を取得
    private func getPositionValue(_ position: SpeechPosition) -> String {
        switch position {
        case .left:
            return "left"
        case .right:
            return "right"
        }
    }

    /// 出力スタイル値を取得（Python版OUTPUT_STYLES準拠）
    private func getOutputStyleValue(_ style: OutputStyle) -> String {
        switch style {
        case .anime:
            return "manga"  // 4コマ漫画ではmangaスタイル
        case .pixelArt:
            return "pixel_art"
        case .chibi:
            return "chibi"
        case .realistic:
            return "realistic"
        case .watercolor:
            return "watercolor"
        case .oilPainting:
            return "oil_painting"
        }
    }
}
