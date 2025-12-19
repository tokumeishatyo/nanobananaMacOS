import Foundation

/// ストーリーシーンYAML生成（Python版_generate_story_yaml準拠）
/// 注意: バトルシーン・ボスレイドは後日実装予定
final class StorySceneYAMLGenerator {

    // MARK: - Generate

    /// ストーリーシーンYAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: SceneBuilderSettingsViewModel) -> String {
        // 背景セクション
        let backgroundSection = generateBackgroundSection(settings: settings)

        // キャラクターセクション（動的生成、最大5人）
        let charactersSection = generateCharactersSection(settings: settings)

        // ダイアログセクション
        let dialogSection = generateDialogSection(settings: settings)

        // 装飾テキストオーバーレイセクション
        let textOverlaySection = generateTextOverlaySection(settings: settings)

        // スタイル設定（トップ画面から取得）
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)
        let aspectRatioValue = mainViewModel.selectedAspectRatio.rawValue

        // YAML生成
        let yaml = """
# Story Scene Composition (story_scene_composite.yaml準拠)
# Purpose: Combine characters and background into a story scene
# Note: Battle Scene and Boss Raid will be implemented later
type: story_scene_composition

\(backgroundSection)

scene_interaction:
  layout_type: "\(getLayoutValue(settings: settings))"
  distance: "\(settings.storyDistance.englishValue)"
\(charactersSection)
comic_overlay:
  enabled: true
  style: "Slice of Life / Visual Novel"
  narration_box:
    text: "\(YAMLUtilities.escapeYAMLString(settings.storyNarration))"
    position: "Top Left"
\(dialogSection)
post_processing:
  filter: "Soft Anime Look"
  bloom_effect: "Low"
\(textOverlaySection)
style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""

        return yaml
    }

    // MARK: - Private Methods

    /// 背景セクション生成
    private func generateBackgroundSection(settings: SceneBuilderSettingsViewModel) -> String {
        let blurAmount = Int(settings.storyBlurAmount)
        let moodValue = getMoodValue(settings: settings)

        if settings.backgroundSourceType == .file {
            let bgFileName = YAMLUtilities.getFileName(from: settings.backgroundImagePath)
            return """
background:
  source_image: "\(bgFileName)"
  blur_amount: \(blurAmount)
  lighting_mood: "\(moodValue)"
"""
        } else {
            let bgDescription = YAMLUtilities.escapeYAMLString(settings.backgroundDescription)
            return """
background:
  generate_from_prompt: true
  scene_description: "\(bgDescription)"
  blur_amount: \(blurAmount)
  lighting_mood: "\(moodValue)"
"""
        }
    }

    /// 配置パターン値を取得（カスタムの場合はテキストから）
    private func getLayoutValue(settings: SceneBuilderSettingsViewModel) -> String {
        if settings.storyLayout == .custom {
            let customValue = settings.storyCustomLayout.trimmingCharacters(in: .whitespaces)
            return customValue.isEmpty ? "Custom Layout" : customValue
        }
        return settings.storyLayout.englishValue
    }

    /// 雰囲気値を取得（カスタムの場合はテキストから）
    private func getMoodValue(settings: SceneBuilderSettingsViewModel) -> String {
        if settings.storyLightingMood == .custom {
            let customValue = settings.storyCustomMood.trimmingCharacters(in: .whitespaces)
            return customValue.isEmpty ? "Custom Mood" : customValue
        }
        return settings.storyLightingMood.englishValue
    }

    /// キャラクターセクション生成（動的、最大5人）
    private func generateCharactersSection(settings: SceneBuilderSettingsViewModel) -> String {
        let charCount = settings.storyCharacterCount.intValue
        var charactersYAML = ""

        for i in 0..<charCount {
            let char = settings.storyCharacters[i]
            let imagePath = char.imagePath.trimmingCharacters(in: .whitespaces)

            // 画像パスが空の場合はスキップ
            if imagePath.isEmpty {
                continue
            }

            let fileName = YAMLUtilities.getFileName(from: imagePath)
            let expression = char.expression.trimmingCharacters(in: .whitespaces)
            let expressionValue = expression.isEmpty ? "Smiling" : expression
            let traits = char.traits.trimmingCharacters(in: .whitespaces)
            let traitsLine = traits.isEmpty ? "" : "\n  physical_traits: \"\(traits)\""

            // 相対位置の生成
            let position: String
            if charCount == 1 {
                position = "Center"
            } else if i == 0 {
                position = "Leftmost"
            } else {
                position = "Right of Character \(i)"
            }

            charactersYAML += """

character_\(i + 1):
  source_image: "\(fileName)"
  position: "\(position)"
  scale: 1.0
  expression_override: "\(expressionValue)"\(traitsLine)
"""
        }

        return charactersYAML
    }

    /// ダイアログセクション生成
    private func generateDialogSection(settings: SceneBuilderSettingsViewModel) -> String {
        let charCount = settings.storyCharacterCount.intValue
        var dialoguesYAML = ""
        var hasDialogues = false

        for i in 0..<charCount {
            let speech = settings.storyDialogues[i].trimmingCharacters(in: .whitespaces)
            if !speech.isEmpty {
                hasDialogues = true

                // 位置ラベル
                let posLabel: String
                if charCount == 1 {
                    posLabel = ""
                } else if i == 0 {
                    posLabel = " (Leftmost)"
                } else {
                    posLabel = " (Right of \(i))"
                }

                dialoguesYAML += """

    - speaker: "Character \(i + 1)\(posLabel)"
      text: "\(YAMLUtilities.escapeYAMLString(speech))"
      shape: "Round (Normal)"
"""
            }
        }

        if hasDialogues {
            return "  dialogues:\(dialoguesYAML)"
        } else {
            return "  dialogues: []"
        }
    }

    /// 装飾テキストオーバーレイセクション生成
    private func generateTextOverlaySection(settings: SceneBuilderSettingsViewModel) -> String {
        if settings.textOverlayItems.isEmpty {
            return ""
        }

        var itemsYAML = ""
        for item in settings.textOverlayItems {
            let imagePath = YAMLUtilities.getFileName(from: item.imagePath)
            let position = item.position
            let size = item.size
            let layer = item.layer.englishValue

            itemsYAML += """

    - source_image: "\(imagePath)"
      position: "\(position)"
      scale: "\(size)"
      layer: "\(layer)"
      blend_mode: "Normal"
"""
        }

        return """

decorative_text_overlays:
  enabled: true
  items:\(itemsYAML)
"""
    }

    /// 出力スタイル値を取得（Python版OUTPUT_STYLES準拠）
    private func getOutputStyleValue(_ style: OutputStyle) -> String {
        switch style {
        case .anime:
            return "anime"
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
