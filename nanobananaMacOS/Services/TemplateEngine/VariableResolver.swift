import Foundation

/// 変数リゾルバー
/// ViewModelから変数を解決してTemplateVariablesを生成
final class VariableResolver {

    // MARK: - Public Methods

    /// MainViewModelと設定ViewModelから変数を解決
    @MainActor
    func resolveVariables(
        outputType: OutputType,
        mainViewModel: MainViewModel
    ) -> TemplateVariables {
        var variables = TemplateVariables()

        // 共通変数を設定
        resolveCommonVariables(from: mainViewModel, into: &variables)

        // 出力タイプ固有の変数を設定
        switch outputType {
        case .faceSheet:
            resolveFaceSheetVariables(from: mainViewModel, into: &variables)
        case .bodySheet:
            resolveBodySheetVariables(from: mainViewModel, into: &variables)
        case .outfit:
            resolveOutfitSheetVariables(from: mainViewModel, into: &variables)
        case .pose:
            resolvePoseVariables(from: mainViewModel, into: &variables)
        case .sceneBuilder:
            resolveSceneBuilderVariables(from: mainViewModel, into: &variables)
        case .background:
            resolveBackgroundVariables(from: mainViewModel, into: &variables)
        case .decorativeText:
            resolveDecorativeTextVariables(from: mainViewModel, into: &variables)
        case .fourPanelManga:
            resolveFourPanelVariables(from: mainViewModel, into: &variables)
        case .styleTransform:
            resolveStyleTransformVariables(from: mainViewModel, into: &variables)
        case .infographic:
            resolveInfographicVariables(from: mainViewModel, into: &variables)
        }

        return variables
    }

    // MARK: - Common Variables

    @MainActor
    private func resolveCommonVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        // タイトル・作者
        variables.set("title", mainViewModel.title)

        let author = mainViewModel.authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !author.isEmpty {
            variables.set("author", author)
        }

        // カラーモード
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        variables.set("color_mode", colorModeValue)

        // 二色刷り
        let isDuotone = YAMLUtilities.isDuotone(mainViewModel.selectedColorMode)
        variables.set("is_duotone", isDuotone)
        if isDuotone {
            variables.set("duotone_style", YAMLUtilities.getDuotoneStyle())
        }

        // 出力スタイル
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)
        variables.set("output_style", outputStyleValue)

        // アスペクト比
        let aspectRatioValue = getAspectRatioValue(mainViewModel.selectedAspectRatio)
        variables.set("aspect_ratio", aspectRatioValue)

        // タイトルオーバーレイ
        variables.set("title_overlay_enabled", mainViewModel.includeTitleInImage)
    }

    // MARK: - Face Sheet Variables

    @MainActor
    private func resolveFaceSheetVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.faceSheetSettings else { return }

        // キャラクター情報
        let characterName = settings.characterName.isEmpty ? "Character" : settings.characterName
        variables.set("character_name", YAMLUtilities.escapeYAMLString(characterName))

        let description = YAMLUtilities.convertNewlinesToComma(settings.appearanceDescription)
        variables.set("character_description", description)

        variables.set("expression", "neutral expression")

        // スタイル情報
        let styleInfo = YAMLUtilities.getCharacterStyleInfo(mainViewModel.selectedOutputStyle)
        variables.set("style_info_style", styleInfo.style)
        variables.set("style_info_proportions", styleInfo.proportions)
        variables.set("style_info_description", styleInfo.description)

        // 参考画像
        let imageName = YAMLUtilities.getFileName(from: settings.referenceImagePath)
        if !imageName.isEmpty {
            variables.set("reference_image_path", YAMLUtilities.escapeYAMLString(imageName))
        }
    }

    // MARK: - Body Sheet Variables

    @MainActor
    private func resolveBodySheetVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.bodySheetSettings else { return }

        // 顔三面図参照
        let faceSheetName = YAMLUtilities.getFileName(from: settings.faceSheetImagePath)
        if !faceSheetName.isEmpty {
            variables.set("face_sheet_path", YAMLUtilities.escapeYAMLString(faceSheetName))
        }

        // 体型情報
        variables.set("body_type", settings.bodyTypePreset.rawValue)
        variables.set("bust_feature", settings.bustFeature.rawValue)
        variables.set("render_type", settings.bodyRenderType.rawValue)

        // 追加説明
        let additionalDesc = YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)
        if !additionalDesc.isEmpty {
            variables.set("additional_description", additionalDesc)
        }

        // スタイル情報
        let styleInfo = YAMLUtilities.getCharacterStyleInfo(mainViewModel.selectedOutputStyle)
        variables.set("style_info_style", styleInfo.style)
        variables.set("style_info_proportions", styleInfo.proportions)
        variables.set("style_info_description", styleInfo.description)
    }

    // MARK: - Outfit Sheet Variables

    @MainActor
    private func resolveOutfitSheetVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.outfitSettings else { return }

        // 素体三面図参照
        let bodySheetName = YAMLUtilities.getFileName(from: settings.bodySheetImagePath)
        if !bodySheetName.isEmpty {
            variables.set("body_sheet_path", YAMLUtilities.escapeYAMLString(bodySheetName))
        }

        // モード判定（useOutfitBuilder = true ならプリセットモード）
        let isReferenceMode = !settings.useOutfitBuilder
        variables.set("is_reference_mode", isReferenceMode)

        if isReferenceMode {
            // 参考画像モード
            let outfitImageName = YAMLUtilities.getFileName(from: settings.referenceOutfitImagePath)
            variables.set("outfit_image_path", YAMLUtilities.escapeYAMLString(outfitImageName))
            variables.set("fit_mode", settings.fitMode)
            variables.set("include_headwear", settings.includeHeadwear)
            let refDesc = YAMLUtilities.convertNewlinesToComma(settings.referenceDescription)
            if !refDesc.isEmpty {
                variables.set("reference_description", refDesc)
            }
        } else {
            // プリセットモード
            variables.set("outfit_category", settings.outfitCategory.rawValue)
            variables.set("outfit_shape", settings.outfitShape)
            variables.set("outfit_color", settings.outfitColor.rawValue)
            variables.set("outfit_pattern", settings.outfitPattern.rawValue)
            variables.set("outfit_style", settings.outfitStyle.rawValue)
        }

        // 追加説明
        let additionalDesc = YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)
        if !additionalDesc.isEmpty {
            variables.set("additional_description", additionalDesc)
        }
    }

    // MARK: - Pose Variables

    @MainActor
    private func resolvePoseVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.poseSettings else { return }

        // 衣装三面図参照
        let outfitSheetName = YAMLUtilities.getFileName(from: settings.outfitSheetImagePath)
        if !outfitSheetName.isEmpty {
            variables.set("outfit_sheet_path", YAMLUtilities.escapeYAMLString(outfitSheetName))
        }

        // モード判定（usePoseCapture = true が参考画像モード）
        let isReferenceMode = settings.usePoseCapture
        variables.set("is_reference_mode", isReferenceMode)

        if isReferenceMode {
            // 参考画像モード
            let poseImageName = YAMLUtilities.getFileName(from: settings.poseReferenceImagePath)
            variables.set("pose_image_path", YAMLUtilities.escapeYAMLString(poseImageName))
        } else {
            // プリセットモード
            variables.set("pose_preset", settings.selectedPreset.rawValue)
        }

        // 向き・表情
        variables.set("eye_line", settings.eyeLine.rawValue)
        variables.set("expression", settings.expression.rawValue)
        let expressionDetail = settings.expressionDetail.trimmingCharacters(in: .whitespaces)
        if !expressionDetail.isEmpty {
            variables.set("expression_detail", YAMLUtilities.escapeYAMLString(expressionDetail))
        }

        // 動作説明
        let actionDesc = settings.actionDescription.trimmingCharacters(in: .whitespaces)
        if !actionDesc.isEmpty {
            variables.set("action_description", YAMLUtilities.escapeYAMLString(actionDesc))
        }

        // ビジュアル効果
        variables.set("include_effects", settings.includeEffects)
        variables.set("transparent_background", settings.transparentBackground)
        variables.set("wind_effect", settings.windEffect.rawValue)
    }

    // MARK: - Scene Builder Variables

    @MainActor
    private func resolveSceneBuilderVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.sceneBuilderSettings else { return }

        // シーンタイプ
        variables.set("scene_type", settings.sceneType.rawValue)

        // シーンタイプに応じた変数を設定
        // 詳細は既存のStorySceneYAMLGenerator等を参照
    }

    // MARK: - Background Variables

    @MainActor
    private func resolveBackgroundVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.backgroundSettings else { return }

        // 参考画像
        let useReference = settings.useReferenceImage && !settings.referenceImagePath.isEmpty
        variables.set("use_reference", useReference)

        if useReference {
            let imageName = YAMLUtilities.getFileName(from: settings.referenceImagePath)
            variables.set("reference_image_path", YAMLUtilities.escapeYAMLString(imageName))
        }

        // 背景説明
        variables.set("background_description", YAMLUtilities.escapeYAMLString(settings.description))
    }

    // MARK: - Decorative Text Variables

    @MainActor
    private func resolveDecorativeTextVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.decorativeTextSettings else { return }

        // テキスト内容
        variables.set("text_content", YAMLUtilities.escapeYAMLString(settings.text))

        // テキストタイプ
        variables.set("text_type", settings.textType.rawValue)
        variables.set("transparent_background", settings.transparentBackground)
    }

    // MARK: - Four Panel Variables

    @MainActor
    private func resolveFourPanelVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.fourPanelSettings else { return }

        // キャラクター配列
        var characters: [[String: Any]] = []

        if !settings.character1Name.isEmpty || !settings.character1ImagePath.isEmpty {
            let name = settings.character1Name.isEmpty ? "キャラ1" : settings.character1Name
            let imageRef = settings.character1ImagePath.isEmpty
                ? "添付画像1を参照してください"
                : "添付画像1（\(YAMLUtilities.getFileName(from: settings.character1ImagePath))）を参照してください"
            let description = YAMLUtilities.convertNewlinesToComma(settings.character1Description)

            characters.append([
                "name": YAMLUtilities.escapeYAMLString(name),
                "reference": imageRef,
                "description": description
            ])
        }

        if !settings.character2Name.isEmpty || !settings.character2ImagePath.isEmpty {
            let name = settings.character2Name.isEmpty ? "キャラ2" : settings.character2Name
            let imageRef = settings.character2ImagePath.isEmpty
                ? "添付画像2を参照してください"
                : "添付画像2（\(YAMLUtilities.getFileName(from: settings.character2ImagePath))）を参照してください"
            let description = YAMLUtilities.convertNewlinesToComma(settings.character2Description)

            characters.append([
                "name": YAMLUtilities.escapeYAMLString(name),
                "reference": imageRef,
                "description": description
            ])
        }

        variables.set("characters", characters)

        // パネル配列
        let panelLabels = ["起", "承", "転", "結"]
        var panels: [[String: Any]] = []

        for (index, panel) in settings.panels.enumerated() {
            let label = index < panelLabels.count ? panelLabels[index] : String(index + 1)
            let prompt = YAMLUtilities.convertNewlinesToComma(panel.scene)

            // セリフ配列
            var speeches: [[String: Any]] = []

            if panel.speech1Char != .none && !panel.speech1Text.isEmpty {
                let characterName = getCharacterName(panel.speech1Char, settings: settings)
                speeches.append([
                    "character": YAMLUtilities.escapeYAMLString(characterName),
                    "content": YAMLUtilities.escapeYAMLString(panel.speech1Text),
                    "position": panel.speech1Position.rawValue
                ])
            }

            if panel.speech2Char != .none && !panel.speech2Text.isEmpty {
                let characterName = getCharacterName(panel.speech2Char, settings: settings)
                speeches.append([
                    "character": YAMLUtilities.escapeYAMLString(characterName),
                    "content": YAMLUtilities.escapeYAMLString(panel.speech2Text),
                    "position": panel.speech2Position.rawValue
                ])
            }

            var panelDict: [String: Any] = [
                "panel_number": index + 1,
                "label": label,
                "prompt": prompt,
                "speeches": speeches
            ]

            if !panel.narration.isEmpty {
                panelDict["narration"] = YAMLUtilities.escapeYAMLString(panel.narration)
            }

            panels.append(panelDict)
        }

        variables.set("panels", panels)
    }

    // MARK: - Style Transform Variables

    @MainActor
    private func resolveStyleTransformVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.styleTransformSettings else { return }

        // 変換元画像
        let sourceImageName = YAMLUtilities.getFileName(from: settings.sourceImagePath)
        if !sourceImageName.isEmpty {
            variables.set("source_image_path", YAMLUtilities.escapeYAMLString(sourceImageName))
        }

        // 変換タイプ
        variables.set("transform_type", settings.transformType.rawValue)

        // 背景設定
        variables.set("transparent_background", settings.transparentBackground)
        variables.set("output_background", settings.transparentBackground ? "transparent" : "white")
    }

    // MARK: - Infographic Variables

    @MainActor
    private func resolveInfographicVariables(from mainViewModel: MainViewModel, into variables: inout TemplateVariables) {
        guard let settings = mainViewModel.infographicSettings else { return }

        // スタイル
        variables.set("infographic_style", settings.infographicStyle.rawValue)

        // 言語
        variables.set("output_language", settings.outputLanguage.rawValue)

        // タイトル
        variables.set("main_title", YAMLUtilities.escapeYAMLString(settings.mainTitle))
        variables.set("subtitle", YAMLUtilities.escapeYAMLString(settings.subtitle))

        // メインキャラクター
        let mainCharImageName = YAMLUtilities.getFileName(from: settings.mainCharacterImagePath)
        if !mainCharImageName.isEmpty {
            variables.set("main_character_image_path", YAMLUtilities.escapeYAMLString(mainCharImageName))
        }

        // サブキャラクター
        let subCharImageName = YAMLUtilities.getFileName(from: settings.subCharacterImagePath)
        let hasSubCharacter = !subCharImageName.isEmpty
        variables.set("sub_character_enabled", hasSubCharacter)
        if hasSubCharacter {
            variables.set("sub_character_image_path", YAMLUtilities.escapeYAMLString(subCharImageName))
        }

        // セクション配列
        var sections: [[String: Any]] = []
        for section in settings.sections {
            if !section.title.isEmpty && !section.content.isEmpty {
                sections.append([
                    "title": YAMLUtilities.escapeYAMLString(section.title),
                    "content": YAMLUtilities.escapeYAMLString(section.content)
                ])
            }
        }
        variables.set("info_sections", sections)
    }

    // MARK: - Helper Methods

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

    private func getAspectRatioValue(_ ratio: AspectRatio) -> String {
        switch ratio {
        case .square:
            return "1:1"
        case .wide16_9:
            return "16:9"
        case .tall9_16:
            return "9:16"
        case .standard4_3:
            return "4:3"
        case .portrait3_4:
            return "3:4"
        case .ultraWide3_1:
            return "3:1"
        }
    }

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
}
