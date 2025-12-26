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
            return generateInfographicYAML(mainViewModel: mainViewModel)
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
            "narration": settings.storyNarration,
            "narration_position": settings.storyNarrationPosition.yamlValue
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

        let variables: [String: String] = [
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

    // MARK: - Infographic YAML Generation

    /// インフォグラフィックYAML生成
    @MainActor
    private func generateInfographicYAML(mainViewModel: MainViewModel) -> String {
        guard let settings = mainViewModel.infographicSettings else {
            return "# Error: インフォグラフィックの設定がありません"
        }

        let variables = buildInfographicVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "10_infographic.yaml", variables: variables)
    }

    /// インフォグラフィック用の変数辞書を構築
    @MainActor
    private func buildInfographicVariables(
        mainViewModel: MainViewModel,
        settings: InfographicSettingsViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 出力言語の決定（「その他」の場合はカスタム言語を使用）
        let outputLanguage: String
        if settings.outputLanguage == .other {
            outputLanguage = settings.customLanguage.isEmpty ? "Custom" : settings.customLanguage
        } else {
            outputLanguage = settings.outputLanguage.languageValue
        }

        // ボーナスキャラクター有効判定
        let bonusCharacterEnabled = !settings.subCharacterImagePath.isEmpty

        var variables: [String: String] = [
            // ヘッダーパーシャル用
            "header_comment": "Infographic (インフォグラフィック)",
            "type": "infographic",
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

            // インフォグラフィック固有
            "infographic_style": settings.infographicStyle.key,
            "infographic_style_prompt": settings.infographicStyle.prompt,
            "output_language": outputLanguage,
            "main_title": settings.mainTitle,
            "subtitle": settings.subtitle,
            "main_character_image": YAMLUtilities.getFileName(from: settings.mainCharacterImagePath),
            "bonus_character_image": YAMLUtilities.getFileName(from: settings.subCharacterImagePath),
            "bonus_character_enabled": bonusCharacterEnabled ? "true" : "false"
        ]

        // セクション変数を追加（1〜8）
        for (index, section) in settings.sections.enumerated() {
            let sectionNum = index + 1
            variables["section_\(sectionNum)_title"] = section.title
            variables["section_\(sectionNum)_content"] = YAMLUtilities.convertNewlinesToComma(section.content)
        }

        return variables
    }

    // MARK: - Character Card YAML Generation (漫画コンポーザー)

    /// キャラクターカードYAML生成
    @MainActor
    func generateCharacterCardYAML(
        mainViewModel: MainViewModel,
        character: CharacterEntry
    ) -> String {
        let variables = buildCharacterCardVariables(mainViewModel: mainViewModel, character: character)
        return templateEngine.render(templateName: "11_character_card.yaml", variables: variables)
    }

    /// キャラクターカード用の変数辞書を構築
    @MainActor
    private func buildCharacterCardVariables(
        mainViewModel: MainViewModel,
        character: CharacterEntry
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        return [
            // ヘッダーパーシャル用
            "header_comment": "Character Card (キャラクターカード)",
            "type": "character_card",
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

            // キャラクターカード固有
            "character_name": character.name,
            "character_image": YAMLUtilities.getFileName(from: character.imagePath),
            "character_info": YAMLUtilities.convertNewlinesToEscaped(character.info)
        ]
    }

    // MARK: - Character Sheet YAML Generation (漫画コンポーザー)

    /// 登場人物シートYAML生成
    @MainActor
    func generateCharacterSheetYAML(
        mainViewModel: MainViewModel,
        settings: CharacterSheetViewModel
    ) -> String {
        let variables = buildCharacterSheetVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "11_character_sheet.yaml", variables: variables)
    }

    /// 登場人物シート用の変数辞書を構築（カード画像ベース）
    @MainActor
    private func buildCharacterSheetVariables(
        mainViewModel: MainViewModel,
        settings: CharacterSheetViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // 有効なカード画像パスのみを抽出
        let validCardPaths = settings.cardImagePaths.filter { !$0.isEmpty }
        let cardCount = validCardPaths.count

        // カード数に応じたレイアウト設定を生成
        let (layoutType, compositionRules, cardIsolation, positionOrderRule) =
            generateCardLayoutSettings(cardCount: cardCount)

        var variables: [String: String] = [
            // ヘッダーパーシャル用
            "header_comment": "Character Introduction Sheet (登場人物紹介シート)",
            "type": "character_sheet",
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

            // 登場人物シート固有
            "sheet_title": settings.sheetTitle,
            "background_source_type": settings.backgroundSourceType == .file ? "file" : "generate",
            "background_image": YAMLUtilities.getFileName(from: settings.backgroundImagePath),
            "background_description": settings.backgroundDescription,
            "card_count": String(cardCount),

            // 動的レイアウト設定
            "layout_type": layoutType,
            "composition_rules": compositionRules,
            "card_isolation": cardIsolation,
            "position_order_rule": positionOrderRule
        ]

        // 各カード画像（1〜3）
        for i in 1...CharacterSheetViewModel.maxCardCount {
            let index = i - 1
            if index < validCardPaths.count {
                variables["card_\(i)_image"] = YAMLUtilities.getFileName(from: validCardPaths[index])
            } else {
                variables["card_\(i)_image"] = ""
            }
        }

        return variables
    }

    /// キャラクター数に応じたレイアウト設定を生成
    private func generateCharacterLayoutSettings(
        characters: [CharacterEntry]
    ) -> (layoutType: String, compositionRules: String, characterIsolation: String, positionOrderRule: String) {
        let count = characters.count

        switch count {
        case 1:
            // 1人用
            let layoutType = "single_character_centered"
            let compositionRules = """
    - "Place the single character at the center of the image."
    - "The character should be prominently displayed."
"""
            let characterIsolation = """
    - "Display only one character as specified in the input."
"""
            let positionOrderRule = """
  - "Display only character_1 (\(characters[0].name)) at the center."
"""
            return (layoutType, compositionRules, characterIsolation, positionOrderRule)

        case 2:
            // 2人用
            let layoutType = "invisible_diptych"
            let compositionRules = """
    - "Imagine the image is divided into 2 equal vertical columns."
    - "Column 1 (Left): Place character_1."
    - "Column 2 (Right): Place character_2."
    - "Do NOT draw visible vertical lines or borders between columns."
"""
            let characterIsolation = """
    - "Ensure strictly NO overlapping between characters."
    - "Keep equal spacing between the two characters."
"""
            let positionOrderRule = """
  - "Strictly maintain the order: \(characters[0].name) (Left) -> \(characters[1].name) (Right)."
"""
            return (layoutType, compositionRules, characterIsolation, positionOrderRule)

        case 3:
            // 3人用
            let layoutType = "invisible_triptych"
            let compositionRules = """
    - "Imagine the image is divided into 3 equal vertical columns."
    - "Column 1 (Left): Place character_1."
    - "Column 2 (Center): Place character_2."
    - "Column 3 (Right): Place character_3."
    - "Do NOT draw visible vertical lines or borders between columns."
"""
            let characterIsolation = """
    - "Ensure strictly NO overlapping between characters."
    - "Keep equal spacing between the three characters."
"""
            let positionOrderRule = """
  - "Strictly maintain the order: \(characters[0].name) (Left) -> \(characters[1].name) (Center) -> \(characters[2].name) (Right)."
"""
            return (layoutType, compositionRules, characterIsolation, positionOrderRule)

        default:
            // デフォルト（1人扱い）
            let layoutType = "single_character_centered"
            let compositionRules = """
    - "Place the character at the center of the image."
"""
            let characterIsolation = """
    - "Display only the specified character."
"""
            let positionOrderRule = ""
            return (layoutType, compositionRules, characterIsolation, positionOrderRule)
        }
    }

    /// カード数に応じたレイアウト設定を生成（カード画像ベース）
    private func generateCardLayoutSettings(
        cardCount: Int
    ) -> (layoutType: String, compositionRules: String, cardIsolation: String, positionOrderRule: String) {

        switch cardCount {
        case 1:
            // 1枚用
            let layoutType = "single_card_centered"
            let compositionRules = """
    - "Place the single card image at the center of the image."
    - "The card should be prominently displayed."
"""
            let cardIsolation = """
    - "Display only one card as specified in the input."
"""
            let positionOrderRule = """
  - "Display only card_1 at the center."
"""
            return (layoutType, compositionRules, cardIsolation, positionOrderRule)

        case 2:
            // 2枚用
            let layoutType = "invisible_diptych"
            let compositionRules = """
    - "Imagine the image is divided into 2 equal vertical columns."
    - "Column 1 (Left): Place card_1."
    - "Column 2 (Right): Place card_2."
    - "Do NOT draw visible vertical lines or borders between columns."
"""
            let cardIsolation = """
    - "Ensure strictly NO overlapping between cards."
    - "Keep equal spacing between the two cards."
"""
            let positionOrderRule = """
  - "Strictly maintain the order: card_1 (Left) -> card_2 (Right)."
"""
            return (layoutType, compositionRules, cardIsolation, positionOrderRule)

        case 3:
            // 3枚用
            let layoutType = "invisible_triptych"
            let compositionRules = """
    - "Imagine the image is divided into 3 equal vertical columns."
    - "Column 1 (Left): Place card_1."
    - "Column 2 (Center): Place card_2."
    - "Column 3 (Right): Place card_3."
    - "Do NOT draw visible vertical lines or borders between columns."
"""
            let cardIsolation = """
    - "Ensure strictly NO overlapping between cards."
    - "Keep equal spacing between the three cards."
"""
            let positionOrderRule = """
  - "Strictly maintain the order: card_1 (Left) -> card_2 (Center) -> card_3 (Right)."
"""
            return (layoutType, compositionRules, cardIsolation, positionOrderRule)

        default:
            // デフォルト（1枚扱い）
            let layoutType = "single_card_centered"
            let compositionRules = """
    - "Place the card at the center of the image."
"""
            let cardIsolation = """
    - "Display only the specified card."
"""
            let positionOrderRule = ""
            return (layoutType, compositionRules, cardIsolation, positionOrderRule)
        }
    }

    // MARK: - Manga Creation YAML Generation (漫画コンポーザー - 漫画作成)

    /// 漫画作成YAML生成
    @MainActor
    func generateMangaCreationYAML(
        mainViewModel: MainViewModel,
        settings: MangaCreationViewModel
    ) -> String {
        let variables = buildMangaCreationVariables(mainViewModel: mainViewModel, settings: settings)
        return templateEngine.render(templateName: "11_multi_panel.yaml", variables: variables)
    }

    /// 漫画作成用の変数辞書を構築
    @MainActor
    private func buildMangaCreationVariables(
        mainViewModel: MainViewModel,
        settings: MangaCreationViewModel
    ) -> [String: String] {
        let authorName = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleOverlayEnabled = mainViewModel.includeTitleInImage
        let (titlePosition, titleSize, authorPosition, authorSize) = getTitleOverlayPositions(
            includeTitleInImage: titleOverlayEnabled,
            hasAuthor: !authorName.isEmpty
        )

        // panels_contentを動的生成
        let panelsContent = generatePanelsContent(panels: settings.panels)

        return [
            // ヘッダーパーシャル用
            "header_comment": "Multi Panel Manga (漫画作成)",
            "type": "multi_panel_manga",
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

            // 漫画作成固有
            "panel_count": String(settings.panels.count),
            "panels_content": panelsContent
        ]
    }

    /// panelsセクションを動的生成
    private func generatePanelsContent(panels: [MangaPanel]) -> String {
        var content = "panels:\n"

        for (panelIndex, panel) in panels.enumerated() {
            let panelNum = panelIndex + 1

            content += "  - panel_number: \(panelNum)\n"
            content += "    scene: \"\(YAMLUtilities.escapeYAMLString(panel.scene))\"\n"

            // ナレーションは任意
            let trimmedNarration = panel.narration.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedNarration.isEmpty {
                content += "    narration: \"\(YAMLUtilities.escapeYAMLString(trimmedNarration))\"\n"
            }

            // キャラクター（有効なもののみ）
            let validCharacters = panel.characters.filter { $0.isValid }
            if !validCharacters.isEmpty {
                content += "    characters:\n"

                for (charIndex, character) in validCharacters.enumerated() {
                    let order = charIndex + 1
                    let imageName = YAMLUtilities.getFileName(from: character.imagePath)
                    let dialogue = character.dialogue.trimmingCharacters(in: .whitespacesAndNewlines)
                    let features = character.features.trimmingCharacters(in: .whitespacesAndNewlines)

                    content += "      - order: \(order)\n"
                    content += "        reference_image: \"\(imageName)\"\n"

                    // セリフは任意
                    if !dialogue.isEmpty {
                        content += "        dialogue: \"\(YAMLUtilities.escapeYAMLString(dialogue))\"\n"
                    }

                    // 特徴（表情・ポーズ）は任意
                    if !features.isEmpty {
                        content += "        features: \"\(YAMLUtilities.escapeYAMLString(features))\"\n"
                    }
                }
            }
        }

        return content
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

    /// 改行を\nリテラル文字列に変換（YAML内で改行として表示）
    static func convertNewlinesToEscaped(_ string: String) -> String {
        let lines = string
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let joined = lines.joined(separator: "\\n")
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
