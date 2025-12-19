import Foundation

// MARK: - YAML Generator Service

/// YAML生成サービス実装
/// TemplateEngineを使用してYAMLを生成
final class YAMLGeneratorService {

    // MARK: - Properties

    /// テンプレートエンジン使用フラグ
    /// true: TemplateEngineを使用（新方式）
    /// false: 従来のハードコードジェネレーターを使用（レガシー）
    private let useTemplateEngine: Bool

    // MARK: - Legacy Generators (テンプレート移行完了後に削除予定)

    private lazy var faceSheetGenerator = FaceSheetYAMLGenerator()
    private lazy var bodySheetGenerator = BodySheetYAMLGenerator()
    private lazy var outfitSheetGenerator = OutfitSheetYAMLGenerator()
    private lazy var poseGenerator = PoseYAMLGenerator()
    private lazy var storySceneGenerator = StorySceneYAMLGenerator()
    private lazy var backgroundGenerator = BackgroundYAMLGenerator()
    private lazy var decorativeTextGenerator = DecorativeTextYAMLGenerator()
    private lazy var fourPanelGenerator = FourPanelYAMLGenerator()
    private lazy var styleTransformGenerator = StyleTransformYAMLGenerator()
    private lazy var infographicGenerator = InfographicYAMLGenerator()

    // MARK: - Initialization

    /// 初期化
    /// - Parameter useTemplateEngine: テンプレートエンジンを使用するか（デフォルト: false）
    init(useTemplateEngine: Bool = false) {
        self.useTemplateEngine = useTemplateEngine
    }

    // MARK: - Unified Generate Method

    /// 統合YAML生成メソッド
    /// OutputTypeに応じて適切なYAMLを生成
    @MainActor
    func generateYAML(outputType: OutputType, mainViewModel: MainViewModel) -> String {
        if useTemplateEngine {
            return generateWithTemplateEngine(outputType: outputType, mainViewModel: mainViewModel)
        } else {
            return generateWithLegacyGenerator(outputType: outputType, mainViewModel: mainViewModel)
        }
    }

    // MARK: - Template Engine Method

    /// TemplateEngineを使用してYAML生成
    @MainActor
    private func generateWithTemplateEngine(outputType: OutputType, mainViewModel: MainViewModel) -> String {
        do {
            return try TemplateEngine.shared.generateYAML(
                outputType: outputType,
                mainViewModel: mainViewModel
            )
        } catch {
            // エラー時はエラーメッセージをYAMLコメントとして返す
            return """
            # ====================================================
            # Template Engine Error
            # ====================================================
            # \(error.localizedDescription)
            #
            # テンプレートファイルが見つからないか、構文エラーがあります。
            # Resources/Templates/ フォルダを確認してください。
            # ====================================================
            """
        }
    }

    // MARK: - Legacy Generator Methods

    /// 従来のジェネレーターを使用してYAML生成
    @MainActor
    private func generateWithLegacyGenerator(outputType: OutputType, mainViewModel: MainViewModel) -> String {
        switch outputType {
        case .faceSheet:
            return faceSheetGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.faceSheetSettings)
        case .bodySheet:
            return bodySheetGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.bodySheetSettings)
        case .outfitSheet:
            return outfitSheetGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.outfitSettings)
        case .pose:
            return poseGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.poseSettings)
        case .sceneBuilder:
            return storySceneGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.sceneBuilderSettings)
        case .background:
            return backgroundGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.backgroundSettings)
        case .decorativeText:
            return decorativeTextGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.decorativeTextSettings)
        case .fourPanelManga:
            return fourPanelGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.fourPanelSettings)
        case .styleTransform:
            return styleTransformGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.styleTransformSettings)
        case .infographic:
            return infographicGenerator.generate(mainViewModel: mainViewModel, settings: mainViewModel.infographicSettings)
        }
    }
}

// MARK: - YAML Utilities

/// YAML生成共通ユーティリティ
enum YAMLUtilities {

    // MARK: - Character Style Info

    /// キャラクタースタイル情報（Python版CHARACTER_STYLESに準拠）
    struct CharacterStyleInfo {
        let style: String
        let proportions: String
        let description: String
    }

    /// OutputStyleからキャラクタースタイル情報を取得
    static func getCharacterStyleInfo(_ style: OutputStyle) -> CharacterStyleInfo {
        switch style {
        case .anime, .realistic, .watercolor, .oilPainting:
            return CharacterStyleInfo(
                style: "日本のアニメスタイル, 2Dセルシェーディング",
                proportions: "Normal head-to-body ratio (6-7 heads)",
                description: "High quality anime illustration"
            )
        case .pixelArt:
            return CharacterStyleInfo(
                style: "Pixel Art, Retro 8-bit game style, low resolution",
                proportions: "Pixel sprite proportions",
                description: "Visible pixels, simplified details, retro game sprite, no anti-aliasing"
            )
        case .chibi:
            return CharacterStyleInfo(
                style: "Chibi style, Super Deformed (SD) anime",
                proportions: "2 heads tall (2頭身), large head, small body, cute",
                description: "Cute mascot character, simplified features"
            )
        }
    }

    // MARK: - Color Mode

    /// カラーモード値を取得（Python版COLOR_MODESに準拠）
    static func getColorModeValue(_ colorMode: ColorMode) -> String {
        switch colorMode {
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

    /// 二色刷りスタイルを取得（現在は赤×黒固定、将来的に拡張可能）
    static func getDuotoneStyle(_ duotoneColor: DuotoneColor = .redBlack) -> String {
        // 現在は赤×黒固定で使用
        return "red and black duotone, two-color print, manga style"
        // 将来的な拡張: return duotoneColor.prompt
    }

    /// 二色刷りかどうかを判定
    static func isDuotone(_ colorMode: ColorMode) -> Bool {
        return colorMode == .duotone
    }

    // MARK: - String Escaping

    /// YAML文字列のエスケープ（シングルライン）
    static func escapeYAMLString(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    /// 改行をカンマ区切りに変換（AIが特徴を正確に認識しやすくするため）
    /// - 複数行の説明文をカンマ区切りの1行に変換
    /// - 空行は除去
    /// - 前後の空白もトリム
    static func convertNewlinesToComma(_ string: String) -> String {
        let lines = string
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let joined = lines.joined(separator: ", ")

        // YAMLエスケープも適用
        return escapeYAMLString(joined)
    }

    // MARK: - File Path

    /// ファイルパスからファイル名のみを取得
    static func getFileName(from path: String) -> String {
        guard !path.isEmpty else { return "" }
        return URL(fileURLWithPath: path).lastPathComponent
    }

    // MARK: - Author Line

    /// 作者名行を生成（空の場合は空文字列を返す）
    /// - Parameter author: 作者名
    /// - Returns: `author: "作者名"` または空文字列
    static func generateAuthorLine(_ author: String) -> String {
        let trimmed = author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return "\nauthor: \"\(escapeYAMLString(trimmed))\""
    }

    // MARK: - Title Overlay

    /// タイトルオーバーレイYAMLを生成
    /// - Parameters:
    ///   - title: タイトル
    ///   - author: 作者名（空の場合はタイトルのみ中央配置）
    ///   - includeTitleInImage: 画像にタイトルを含めるか
    /// - Returns: タイトルオーバーレイYAML
    static func generateTitleOverlay(title: String, author: String, includeTitleInImage: Bool) -> String {
        guard includeTitleInImage && !title.isEmpty else { return "" }

        // 作者名がない場合: タイトルのみ中央配置
        if author.isEmpty {
            return """

title_overlay:
  enabled: true
  text: "\(escapeYAMLString(title))"
  position: "top-center"
"""
        }

        // 作者名がある場合: タイトル左（大）、作者名右（小）
        return """

title_overlay:
  enabled: true
  title:
    text: "\(escapeYAMLString(title))"
    position: "top-left"
    size: "large"
  author:
    text: "\(escapeYAMLString(author))"
    position: "top-right"
    size: "small"
"""
    }
}
