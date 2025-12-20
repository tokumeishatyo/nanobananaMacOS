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
            return generatePlaceholderYAML(outputType: outputType, templateName: "02_body_sheet.yaml")

        case .outfit:
            // 衣装着用は2種類のテンプレートがある
            let usePreset = mainViewModel.outfitSettings?.useOutfitBuilder ?? true
            let templateName = usePreset ? "03_outfit_preset.yaml" : "03_outfit_reference.yaml"
            return generatePlaceholderYAML(outputType: outputType, templateName: templateName)

        case .pose:
            // ポーズは2種類のテンプレートがある
            let useCapture = mainViewModel.poseSettings?.usePoseCapture ?? false
            let templateName = useCapture ? "04_pose_capture.yaml" : "04_pose_preset.yaml"
            return generatePlaceholderYAML(outputType: outputType, templateName: templateName)

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
