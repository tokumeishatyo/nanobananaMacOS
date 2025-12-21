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
            return generatePlaceholderYAML(outputType: outputType, templateName: "05_scene_story.yaml")

        case .background:
            return generatePlaceholderYAML(outputType: outputType, templateName: "06_background.yaml")

        case .decorativeText:
            return generatePlaceholderYAML(outputType: outputType, templateName: "07_decorative_text.yaml")

        case .fourPanelManga:
            return generatePlaceholderYAML(outputType: outputType, templateName: "08_four_panel.yaml")

        case .styleTransform:
            return generatePlaceholderYAML(outputType: outputType, templateName: "09_style_transform.yaml")

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
