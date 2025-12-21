// rule.mdを読むこと
import Foundation

// MARK: - YAML Generator Service

/// YAML生成サービス
/// テンプレートファイルを読み込み、変数を置換してYAMLを生成
final class YAMLGeneratorService {

    // MARK: - Properties

    /// テンプレートエンジン
    private let templateEngine = TemplateEngine()

    // MARK: - Generate Method

    /// YAML生成メソッド
    /// - Parameters:
    ///   - outputType: 出力タイプ
    ///   - mainViewModel: メインビューモデル
    /// - Returns: 生成されたYAML文字列
    @MainActor
    func generateYAML(
        outputType: OutputType,
        mainViewModel: MainViewModel
    ) -> String {
        switch outputType {
        case .faceSheet:
            return generateFaceSheetYAML(mainViewModel: mainViewModel)

        case .bodySheet:
            return generateBodySheetYAML(mainViewModel: mainViewModel)

        case .outfit:
            return generateOutfitYAML(mainViewModel: mainViewModel)

        case .pose:
            return generatePoseYAML(mainViewModel: mainViewModel)

        case .sceneBuilder:
            return generateSceneBuilderYAML(mainViewModel: mainViewModel)

        case .background:
            return generateBackgroundYAML(mainViewModel: mainViewModel)

        case .decorativeText:
            return generateDecorativeTextYAML(mainViewModel: mainViewModel)

        case .fourPanelManga:
            return generateFourPanelYAML(mainViewModel: mainViewModel)

        case .styleTransform:
            return generateStyleTransformYAML(mainViewModel: mainViewModel)

        case .infographic:
            return generatePlaceholderYAML(outputType: outputType, templateName: "10_infographic.yaml")
        }
    }

    // MARK: - Face Sheet YAML Generation

    /// 顔三面図YAML生成
    @MainActor
    private func generateFaceSheetYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.faceSheetSettings else {
            return "# Error: 顔三面図の設定がありません"
        }

        // 変数辞書を構築
        let variables = buildFaceSheetVariables(mainViewModel: mainViewModel, settings: settings)

        // テンプレートをレンダリング
        return templateEngine.render(templateName: "01_face_sheet.yaml", variables: variables)
    }

    /// 顔三面図用の変数辞書を構築
    @MainActor
    private func buildFaceSheetVariables(
        mainViewModel: MainViewModel,
        settings: FaceSheetSettingsViewModel
    ) -> [String: String] {
        // 作者名の処理（空欄の場合はそのまま空欄）
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)

        // title_overlay設定
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        return [
            // ヘッダーパーシャル用
            "header_comment": "Face Character Reference Sheet",
            "type": "character_design",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 顔三面図固有
            "name": settings.characterName,
            "reference_sheet": YAMLUtilities.getFileName(from: settings.referenceImagePath),
            "description": YAMLUtilities.convertNewlinesToComma(settings.appearanceDescription)
        ]
    }

    /// title_overlayの位置設定を取得
    private func getTitleOverlayPositions(
        includeTitleInImage: Bool,
        hasAuthor: Bool
    ) -> (titlePosition: String, titleSize: String, authorPosition: String, authorSize: String) {
        if !includeTitleInImage {
            return ("", "", "", "")
        }

        if hasAuthor {
            // 作者名あり: タイトル左(large)、作者名右(small)
            return ("top-left", "large", "top-right", "small")
        } else {
            // 作者名なし: タイトルのみtop-center
            return ("top-center", "medium", "", "")
        }
    }

    // MARK: - Body Sheet YAML Generation

    /// 素体三面図YAML生成
    @MainActor
    private func generateBodySheetYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.bodySheetSettings else {
            return "# Error: 素体三面図の設定がありません"
        }

        // 変数辞書を構築
        let variables = buildBodySheetVariables(mainViewModel: mainViewModel, settings: settings)

        // テンプレートをレンダリング
        return templateEngine.render(templateName: "02_body_sheet.yaml", variables: variables)
    }

    /// 素体三面図用の変数辞書を構築
    @MainActor
    private func buildBodySheetVariables(
        mainViewModel: MainViewModel,
        settings: BodySheetSettingsViewModel
    ) -> [String: String] {
        // 作者名の処理（空欄の場合はそのまま空欄）
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)

        // title_overlay設定
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        return [
            // ヘッダーパーシャル用
            "header_comment": "Body Reference Sheet (素体三面図)",
            "type": "character_design",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 素体三面図固有
            "face_sheet": YAMLUtilities.getFileName(from: settings.faceSheetImagePath),
            "body_type": settings.bodyTypePreset.yamlValue,
            "bust": settings.bustFeature.yamlValue,
            "render_type": settings.bodyRenderType.yamlValue,
            "additional_notes": YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)
        ]
    }

    // MARK: - Outfit YAML Generation

    /// 衣装着用YAML生成（モード分岐）
    @MainActor
    private func generateOutfitYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.outfitSettings else {
            return "# Error: 衣装着用の設定がありません"
        }

        if settings.useOutfitBuilder {
            return generateOutfitPresetYAML(mainViewModel: mainViewModel, settings: settings)
        } else {
            return generateOutfitReferenceYAML(mainViewModel: mainViewModel, settings: settings)
        }
    }

    /// 衣装着用YAML生成（プリセットモード）
    @MainActor
    private func generateOutfitPresetYAML(
        mainViewModel: MainViewModel,
        settings: OutfitSettingsViewModel
    ) -> String {
        let variables = buildOutfitPresetVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "03_outfit_preset.yaml", variables: variables)
    }

    /// 衣装着用YAML生成（参考画像モード）
    @MainActor
    private func generateOutfitReferenceYAML(
        mainViewModel: MainViewModel,
        settings: OutfitSettingsViewModel
    ) -> String {
        let variables = buildOutfitReferenceVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "03_outfit_reference.yaml", variables: variables)
    }

    /// プリセットモード用の変数辞書を構築
    @MainActor
    private func buildOutfitPresetVariables(
        mainViewModel: MainViewModel,
        settings: OutfitSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // プロンプトを構築（カテゴリ+形状+色+柄+スタイルを結合）
        let promptParts = [
            settings.outfitCategory.yamlValue,
            settings.outfitShape,
            settings.outfitColor.yamlValue,
            settings.outfitPattern.yamlValue,
            settings.outfitStyle.yamlValue
        ].filter { $0 != "auto" && $0 != "おまかせ" && !$0.isEmpty }
        let prompt = promptParts.joined(separator: ", ")

        return [
            // ヘッダーパーシャル用
            "header_comment": "Outfit Reference Sheet (衣装着用 - プリセット)",
            "type": "character_design",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 衣装着用固有（プリセット）
            "body_sheet": YAMLUtilities.getFileName(from: settings.bodySheetImagePath),
            "category": settings.outfitCategory.yamlValue,
            "shape": settings.outfitShape,
            "color": settings.outfitColor.yamlValue,
            "pattern": settings.outfitPattern.yamlValue,
            "style_impression": settings.outfitStyle.yamlValue,
            "prompt": prompt,
            "additional_notes": YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)
        ]
    }

    /// 参考画像モード用の変数辞書を構築
    @MainActor
    private func buildOutfitReferenceVariables(
        mainViewModel: MainViewModel,
        settings: OutfitSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        return [
            // ヘッダーパーシャル用
            "header_comment": "Outfit Reference Sheet (衣装着用 - 参考画像)",
            "type": "character_design",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 衣装着用固有（参考画像）
            "body_sheet": YAMLUtilities.getFileName(from: settings.bodySheetImagePath),
            "outfit_reference": YAMLUtilities.getFileName(from: settings.referenceOutfitImagePath),
            "description": YAMLUtilities.convertNewlinesToComma(settings.referenceDescription),
            "fit_mode": settings.fitMode,
            "include_headwear": settings.includeHeadwear ? "true" : "false",
            "additional_notes": YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)
        ]
    }

    // MARK: - Pose YAML Generation

    /// ポーズYAML生成（モード分岐）
    @MainActor
    private func generatePoseYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.poseSettings else {
            return "# Error: ポーズの設定がありません"
        }

        if settings.usePoseCapture {
            return generatePoseCaptureYAML(mainViewModel: mainViewModel, settings: settings)
        } else {
            return generatePosePresetYAML(mainViewModel: mainViewModel, settings: settings)
        }
    }

    /// ポーズYAML生成（プリセットモード）
    @MainActor
    private func generatePosePresetYAML(
        mainViewModel: MainViewModel,
        settings: PoseSettingsViewModel
    ) -> String {
        let variables = buildPosePresetVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "04_pose_preset.yaml", variables: variables)
    }

    /// ポーズYAML生成（キャプチャモード）
    @MainActor
    private func generatePoseCaptureYAML(
        mainViewModel: MainViewModel,
        settings: PoseSettingsViewModel
    ) -> String {
        let variables = buildPoseCaptureVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "04_pose_capture.yaml", variables: variables)
    }

    /// プリセットモード用の変数辞書を構築
    @MainActor
    private func buildPosePresetVariables(
        mainViewModel: MainViewModel,
        settings: PoseSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 表情プロンプト生成（補足があれば追加）
        var expressionPrompt = settings.expression.prompt
        let expressionDetail = settings.expressionDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !expressionDetail.isEmpty {
            expressionPrompt = "\(expressionPrompt), \(expressionDetail)"
        }

        return [
            // ヘッダーパーシャル用
            "header_comment": "Pose Image (ポーズ画像 - プリセット)",
            "type": "pose_single",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // ポーズ固有（プリセット）
            "character_sheet": YAMLUtilities.getFileName(from: settings.outfitSheetImagePath),
            "eye_line": settings.eyeLine.yamlValue,
            "expression": expressionPrompt,
            "expression_detail": expressionDetail,
            "action_description": settings.actionDescription,
            "include_effects": settings.includeEffects ? "true" : "false",
            "wind_effect": settings.windEffect.prompt,
            "transparent_background": settings.transparentBackground ? "true" : "false"
        ]
    }

    /// キャプチャモード用の変数辞書を構築
    @MainActor
    private func buildPoseCaptureVariables(
        mainViewModel: MainViewModel,
        settings: PoseSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 表情プロンプト生成（補足があれば追加）
        var expressionPrompt = settings.expression.prompt
        let expressionDetail = settings.expressionDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !expressionDetail.isEmpty {
            expressionPrompt = "\(expressionPrompt), \(expressionDetail)"
        }

        return [
            // ヘッダーパーシャル用
            "header_comment": "Pose Image (ポーズ画像 - キャプチャ)",
            "type": "pose_single",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // ポーズ固有（キャプチャ）
            "pose_reference": YAMLUtilities.getFileName(from: settings.poseReferenceImagePath),
            "character_sheet": YAMLUtilities.getFileName(from: settings.outfitSheetImagePath),
            "eye_line": settings.eyeLine.yamlValue,
            "expression": expressionPrompt,
            "expression_detail": expressionDetail,
            "include_effects": settings.includeEffects ? "true" : "false",
            "wind_effect": settings.windEffect.prompt,
            "transparent_background": settings.transparentBackground ? "true" : "false"
        ]
    }

    // MARK: - Scene Builder YAML Generation

    /// シーンビルダーYAML生成（シーンタイプ分岐）
    @MainActor
    private func generateSceneBuilderYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.sceneBuilderSettings else {
            return "# Error: シーンビルダーの設定がありません"
        }

        switch settings.sceneType {
        case .story:
            return generateStorySceneYAML(mainViewModel: mainViewModel, settings: settings)
        case .battle:
            // バトルシーンは将来実装予定（UIで無効化中）
            return generatePlaceholderYAML(outputType: .sceneBuilder, templateName: "05_scene_battle.yaml")
        case .bossRaid:
            // ボスレイドは将来実装予定（UIで無効化中）
            return generatePlaceholderYAML(outputType: .sceneBuilder, templateName: "05_scene_bossraid.yaml")
        }
    }

    /// ストーリーシーンYAML生成
    @MainActor
    private func generateStorySceneYAML(
        mainViewModel: MainViewModel,
        settings: SceneBuilderSettingsViewModel
    ) -> String {
        let variables = buildStorySceneVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "05_scene_story.yaml", variables: variables)
    }

    /// ストーリーシーン用の変数辞書を構築
    @MainActor
    private func buildStorySceneVariables(
        mainViewModel: MainViewModel,
        settings: SceneBuilderSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 雰囲気の値を取得（カスタムの場合は入力値を使用）
        let lightingMood: String
        if settings.storyLightingMood == .custom {
            lightingMood = settings.storyCustomMood
        } else {
            lightingMood = settings.storyLightingMood.englishValue
        }

        // レイアウトの値を取得（カスタムの場合は入力値を使用）
        let layoutType: String
        if settings.storyLayout == .custom {
            layoutType = settings.storyCustomLayout
        } else {
            layoutType = settings.storyLayout.englishValue
        }

        var variables: [String: String] = [
            // ヘッダーパーシャル用
            "header_comment": "Story Scene Composition (シーンビルダー - ストーリー)",
            "type": "scene_composition",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 背景設定
            "background_source_type": settings.backgroundSourceType.rawValue,
            "background_image": YAMLUtilities.getFileName(from: settings.backgroundImagePath),
            "background_description": settings.backgroundDescription,
            "blur_amount": String(Int(settings.storyBlurAmount)),
            "lighting_mood": lightingMood,

            // 配置設定
            "layout_type": layoutType,
            "distance": settings.storyDistance.englishValue,

            // キャラクター数
            "character_count": String(settings.storyCharacterCount.intValue),

            // ナレーション
            "narration": settings.storyNarration
        ]

        // キャラクター別の変数を追加（1〜5人分）
        let characterCount = settings.storyCharacterCount.intValue
        for i in 0..<5 {
            let charIndex = i + 1
            if i < characterCount && i < settings.storyCharacters.count {
                let character = settings.storyCharacters[i]
                variables["character_\(charIndex)_image"] = YAMLUtilities.getFileName(from: character.imagePath)
                variables["character_\(charIndex)_expression"] = character.expression
                variables["character_\(charIndex)_traits"] = character.traits
                // セリフ
                if i < settings.storyDialogues.count {
                    variables["character_\(charIndex)_dialogue"] = settings.storyDialogues[i]
                } else {
                    variables["character_\(charIndex)_dialogue"] = ""
                }
            } else {
                // 使用しないキャラクターは空文字列
                variables["character_\(charIndex)_image"] = ""
                variables["character_\(charIndex)_expression"] = ""
                variables["character_\(charIndex)_traits"] = ""
                variables["character_\(charIndex)_dialogue"] = ""
            }
        }

        // 装飾テキストオーバーレイセクションを動的生成
        variables["text_overlay_section"] = generateTextOverlaySection(items: settings.textOverlayItems)

        return variables
    }

    /// 装飾テキストオーバーレイセクションを動的生成
    private func generateTextOverlaySection(items: [TextOverlayItem]) -> String {
        guard !items.isEmpty else {
            return ""  // アイテムがない場合はセクション自体を出力しない
        }

        var itemsYaml = ""
        for item in items {
            let imageName = YAMLUtilities.getFileName(from: item.imagePath)
            itemsYaml += """

    - source_image: "\(imageName)"
      position: "\(item.position)"
      scale: "\(item.size)"
      layer: "\(item.layer.englishValue)"
"""
        }

        return """
# ====================================================
# Decorative Text Overlays
# ====================================================
decorative_text_overlays:
  enabled: true
  items:\(itemsYaml)

"""
    }

    // MARK: - Background YAML Generation

    /// 背景生成YAML生成
    @MainActor
    private func generateBackgroundYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.backgroundSettings else {
            return "# Error: 背景生成の設定がありません"
        }

        let variables = buildBackgroundVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "06_background.yaml", variables: variables)
    }

    /// 背景生成用の変数辞書を構築
    @MainActor
    private func buildBackgroundVariables(
        mainViewModel: MainViewModel,
        settings: BackgroundSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 説明文の処理（参考画像モードで空の場合はデフォルト値）
        var description = settings.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if settings.useReferenceImage && description.isEmpty {
            description = "Convert to anime/illustration style, clean lines, vibrant colors"
        }

        return [
            // ヘッダーパーシャル用
            "header_comment": "Background Generation (背景生成)",
            "type": "background",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 背景生成固有
            "use_reference_image": settings.useReferenceImage ? "true" : "false",
            "reference_image": YAMLUtilities.getFileName(from: settings.referenceImagePath),
            "remove_people": settings.removeCharacters ? "true" : "false",
            "description": description
        ]
    }

    // MARK: - Decorative Text YAML Generation

    /// 装飾テキストYAML生成
    @MainActor
    private func generateDecorativeTextYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.decorativeTextSettings else {
            return "# Error: 装飾テキストの設定がありません"
        }

        let variables = buildDecorativeTextVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "07_decorative_text.yaml", variables: variables)
    }

    /// 装飾テキスト用の変数辞書を構築
    @MainActor
    private func buildDecorativeTextVariables(
        mainViewModel: MainViewModel,
        settings: DecorativeTextSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 背景設定
        let background = settings.transparentBackground ? "transparent" : "white"

        // 縁取り有効判定
        let outlineEnabled = settings.titleOutline != .none

        // 顔アイコン有効判定
        let faceIconEnabled = settings.faceIconPosition != .none

        var variables: [String: String] = [
            // ヘッダーパーシャル用
            "header_comment": "Decorative Text (装飾テキスト)",
            "type": "decorative_text",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 共通
            "decorative_type": settings.textType.yamlValue,
            "transparent_background": settings.transparentBackground ? "true" : "false",
            "text": settings.text,
            "background": background,
            "ui_preset": settings.textType.uiPreset,

            // 技名テロップ用
            "skill_font_type": settings.titleFont.rawValue,
            "skill_size": settings.titleSize.rawValue,
            "skill_fill_color": settings.titleColor.rawValue,
            "skill_outline_enabled": outlineEnabled ? "true" : "false",
            "skill_outline_color": settings.titleOutline.rawValue,
            "skill_outline_thickness": "thick",
            "skill_glow_effect": settings.titleGlow.rawValue,

            // 決め台詞用
            "catchphrase_type": settings.calloutType.rawValue,
            "catchphrase_color": settings.calloutColor.rawValue,
            "catchphrase_rotation": settings.calloutRotation.rawValue,
            "catchphrase_distortion": settings.calloutDistortion.rawValue,

            // キャラ名プレート用
            "nameplate_design_type": settings.nameTagDesign.rawValue,
            "nameplate_rotation": settings.nameTagRotation.rawValue,

            // メッセージウィンドウ用
            "message_mode": settings.messageMode.rawValue,
            "message_speaker_name": settings.speakerName,
            "message_style_preset": settings.messageStyle.rawValue,
            "message_position": "bottom",
            "message_width": "full",
            "message_frame_type": settings.messageFrameType.rawValue,
            "message_background_opacity": String(settings.messageOpacity),
            "message_face_icon_enabled": faceIconEnabled ? "true" : "false",
            "message_face_icon_source": YAMLUtilities.getFileName(from: settings.faceIconImagePath),
            "message_face_icon_position": settings.faceIconPosition.rawValue
        ]

        return variables
    }

    // MARK: - Four Panel Manga YAML Generation

    /// 4コマ漫画YAML生成
    @MainActor
    private func generateFourPanelYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.fourPanelSettings else {
            return "# Error: 4コマ漫画の設定がありません"
        }

        let variables = buildFourPanelVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "08_four_panel.yaml", variables: variables)
    }

    /// 4コマ漫画用の変数辞書を構築
    @MainActor
    private func buildFourPanelVariables(
        mainViewModel: MainViewModel,
        settings: FourPanelSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        var variables: [String: String] = [
            // ヘッダーパーシャル用
            "header_comment": "Four Panel Manga (4コマ漫画)",
            "type": "four_panel_manga",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // キャラクター1
            "character_1_name": settings.character1Name,
            "character_1_reference": YAMLUtilities.getFileName(from: settings.character1ImagePath),
            "character_1_description": YAMLUtilities.convertNewlinesToComma(settings.character1Description),

            // キャラクター2
            "character_2_name": settings.character2Name,
            "character_2_reference": YAMLUtilities.getFileName(from: settings.character2ImagePath),
            "character_2_description": YAMLUtilities.convertNewlinesToComma(settings.character2Description)
        ]

        // 各パネルの変数を追加（1〜4）
        for (index, panel) in settings.panels.enumerated() {
            let panelNum = index + 1
            variables["panel_\(panelNum)_prompt"] = panel.scene
            variables["panel_\(panelNum)_speech1_character"] = panel.speech1Char.yamlValue(settings: settings)
            variables["panel_\(panelNum)_speech1_content"] = panel.speech1Text
            variables["panel_\(panelNum)_speech1_position"] = panel.speech1Position.rawValue
            variables["panel_\(panelNum)_speech2_character"] = panel.speech2Char.yamlValue(settings: settings)
            variables["panel_\(panelNum)_speech2_content"] = panel.speech2Text
            variables["panel_\(panelNum)_speech2_position"] = panel.speech2Position.rawValue
            variables["panel_\(panelNum)_narration"] = panel.narration
        }

        return variables
    }

    // MARK: - Style Transform YAML Generation

    /// スタイル変換YAML生成
    @MainActor
    private func generateStyleTransformYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.styleTransformSettings else {
            return "# Error: スタイル変換の設定がありません"
        }

        let variables = buildStyleTransformVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "09_style_transform.yaml", variables: variables)
    }

    /// スタイル変換用の変数辞書を構築
    @MainActor
    private func buildStyleTransformVariables(
        mainViewModel: MainViewModel,
        settings: StyleTransformSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 背景設定
        let background = settings.transparentBackground ? "transparent" : "white"

        return [
            // ヘッダーパーシャル用
            "header_comment": "Style Transform (スタイル変換)",
            "type": "style_transform",
            "title": mainViewModel.title,
            "author": authorName,
            "color_mode": mainViewModel.selectedColorMode.yamlValue,
            "output_style": mainViewModel.selectedOutputStyle.yamlValue,
            "aspect_ratio": mainViewModel.selectedAspectRatio.yamlValue,
            "title_overlay_enabled": titleOverlayEnabled ? "true" : "false",
            "title_position": titlePosition,
            "title_size": titleSize,
            "author_position": authorPosition,
            "author_size": authorSize,

            // 共通
            "source_image": YAMLUtilities.getFileName(from: settings.sourceImagePath),
            "style_type": settings.transformType.yamlValue,
            "transparent_background": settings.transparentBackground ? "true" : "false",
            "background": background,

            // ちびキャラ化用
            "chibi_style": settings.chibiStyle.prompt,

            // ドットキャラ化用
            "pixel_style": settings.pixelStyle.prompt,
            "pixel_sprite_size": settings.spriteSize.prompt
        ]
    }

    // MARK: - Placeholder

    /// 未実装の出力タイプ用プレースホルダー
    private func generatePlaceholderYAML(outputType: OutputType, templateName: String) -> String {
        return """
        # ====================================================
        # \(outputType.rawValue) - 実装予定
        # ====================================================
        # テンプレート: \(templateName)
        #
        # この出力タイプは実装予定です。
        # yaml_templates/\(templateName) を使用します。
        # ====================================================
        """
    }
}

// MARK: - YAML Utilities

/// YAML生成共通ユーティリティ
enum YAMLUtilities {

    /// YAML文字列のエスケープ
    static func escapeYAMLString(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    /// 改行をカンマ区切りに変換
    static func convertNewlinesToComma(_ string: String) -> String {
        let lines = string
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let joined = lines.joined(separator: ", ")
        return escapeYAMLString(joined)
    }

    /// ファイルパスからファイル名のみを取得
    static func getFileName(from path: String) -> String {
        guard !path.isEmpty else { return "" }
        return URL(fileURLWithPath: path).lastPathComponent
    }

    /// title_overlayセクションを生成
    static func generateTitleOverlay(
        title: String,
        author: String,
        includeTitleInImage: Bool
    ) -> String {
        guard includeTitleInImage else { return "" }

        let escapedTitle = escapeYAMLString(title)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedAuthor.isEmpty {
            // 作者名なし: タイトルのみtop-center
            return """

            title_overlay:
              enabled: true
              title:
                text: "\(escapedTitle)"
                position: "top-center"
                size: "medium"
            """
        } else {
            // 作者名あり: タイトル左(large)、作者名右(small)
            let escapedAuthor = escapeYAMLString(trimmedAuthor)
            return """

            title_overlay:
              enabled: true
              title:
                text: "\(escapedTitle)"
                position: "top-left"
                size: "large"
              author:
                text: "\(escapedAuthor)"
                position: "top-right"
                size: "small"
            """
        }
    }
}

// MARK: - Enum Extensions for YAML Values

extension ColorMode {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .fullColor:
            return "fullcolor"
        case .monochrome:
            return "monochrome"
        case .sepia:
            return "sepia"
        case .duotone:
            return "duotone"
        }
    }
}

extension OutputStyle {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
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

// Note: AspectRatio.yamlValue is defined in DropdownOptions.swift

// MARK: - Body Sheet Enum Extensions

extension BodyTypePreset {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .femalStandard:
            return "female_standard"
        case .maleStandard:
            return "male_standard"
        case .slim:
            return "slim"
        case .muscular:
            return "muscular"
        case .chubby:
            return "chubby"
        case .petite:
            return "petite"
        case .tall:
            return "tall"
        case .short:
            return "short"
        }
    }
}

extension BustFeature {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .auto:
            return "auto"
        case .small:
            return "small"
        case .normal:
            return "normal"
        case .large:
            return "large"
        }
    }
}

extension BodyRenderType {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .silhouette:
            return "silhouette"
        case .whiteLeotard:
            return "white_leotard"
        case .whiteUnderwear:
            return "white_underwear"
        case .anatomical:
            return "anatomical"
        }
    }
}

// MARK: - Outfit Enum Extensions

extension OutfitCategory {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .auto:
            return "auto"
        case .model:
            return "model"
        case .suit:
            return "suit"
        case .swimsuit:
            return "swimsuit"
        case .casual:
            return "casual"
        case .uniform:
            return "uniform"
        case .formal:
            return "formal"
        case .sports:
            return "sports"
        case .japanese:
            return "japanese"
        case .workwear:
            return "workwear"
        }
    }
}

extension OutfitColor {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .auto:
            return "auto"
        case .black:
            return "black"
        case .white:
            return "white"
        case .navy:
            return "navy"
        case .red:
            return "red"
        case .pink:
            return "pink"
        case .blue:
            return "blue"
        case .lightBlue:
            return "light_blue"
        case .green:
            return "green"
        case .yellow:
            return "yellow"
        case .orange:
            return "orange"
        case .purple:
            return "purple"
        case .beige:
            return "beige"
        case .gray:
            return "gray"
        case .gold:
            return "gold"
        case .silver:
            return "silver"
        }
    }
}

extension OutfitPattern {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .auto:
            return "auto"
        case .solid:
            return "solid"
        case .stripe:
            return "stripe"
        case .check:
            return "check"
        case .floral:
            return "floral"
        case .dot:
            return "dot"
        case .border:
            return "border"
        case .tropical:
            return "tropical"
        case .lace:
            return "lace"
        case .camouflage:
            return "camouflage"
        case .animal:
            return "animal"
        }
    }
}

extension OutfitFashionStyle {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .auto:
            return "auto"
        case .mature:
            return "mature"
        case .cute:
            return "cute"
        case .sexy:
            return "sexy"
        case .cool:
            return "cool"
        case .modest:
            return "modest"
        case .sporty:
            return "sporty"
        case .gorgeous:
            return "gorgeous"
        case .wild:
            return "wild"
        case .intellectual:
            return "intellectual"
        case .dandy:
            return "dandy"
        case .casual:
            return "casual"
        }
    }
}

// MARK: - Pose Enum Extensions

extension EyeLine {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .front:
            return "looking straight ahead"
        case .up:
            return "looking up"
        case .down:
            return "looking down"
        }
    }
}

// MARK: - Decorative Text Enum Extensions

extension DecorativeTextType {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .skillName:
            return "skill"
        case .catchphrase:
            return "catchphrase"
        case .namePlate:
            return "nameplate"
        case .messageWindow:
            return "message"
        }
    }

    /// UIプリセット値
    var uiPreset: String {
        switch self {
        case .skillName:
            return "Anime Battle"
        case .catchphrase:
            return "Anime Battle"
        case .namePlate:
            return "Character Name Plate"
        case .messageWindow:
            return "Message Window"
        }
    }
}

// MARK: - Four Panel Manga Enum Extensions

extension SpeechCharacter {
    /// YAML出力用の値（キャラクター名を返す）
    func yamlValue(settings: FourPanelSettingsViewModel) -> String {
        switch self {
        case .character1:
            return settings.character1Name.isEmpty ? "キャラ1" : settings.character1Name
        case .character2:
            return settings.character2Name.isEmpty ? "キャラ2" : settings.character2Name
        case .none:
            return ""
        }
    }
}

// MARK: - Style Transform Enum Extensions

extension StyleTransformType {
    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .chibi:
            return "chibi"
        case .pixel:
            return "pixel"
        }
    }
}
