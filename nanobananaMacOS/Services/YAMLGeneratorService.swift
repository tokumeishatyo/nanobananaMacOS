import Foundation

// MARK: - YAML Generator Protocol

/// YAML生成サービスプロトコル
protocol YAMLGeneratorServiceProtocol {
    func generateFaceSheetYAML(mainViewModel: MainViewModel, faceSheetSettings: FaceSheetSettingsViewModel) -> String
    func generateBodySheetYAML(mainViewModel: MainViewModel, bodySheetSettings: BodySheetSettingsViewModel) -> String
    func generateOutfitSheetYAML(mainViewModel: MainViewModel, outfitSettings: OutfitSettingsViewModel) -> String
    func generatePoseYAML(mainViewModel: MainViewModel, poseSettings: PoseSettingsViewModel) -> String
    func generateSceneBuilderYAML(mainViewModel: MainViewModel, sceneBuilderSettings: SceneBuilderSettingsViewModel) -> String
    func generateBackgroundYAML(mainViewModel: MainViewModel, backgroundSettings: BackgroundSettingsViewModel) -> String
}

// MARK: - YAML Generator Service

/// YAML生成サービス実装
/// 各出力タイプ別のジェネレータを呼び出すファサード
final class YAMLGeneratorService: YAMLGeneratorServiceProtocol {

    // MARK: - Generators

    private let faceSheetGenerator = FaceSheetYAMLGenerator()
    private let bodySheetGenerator = BodySheetYAMLGenerator()
    private let outfitSheetGenerator = OutfitSheetYAMLGenerator()
    private let poseGenerator = PoseYAMLGenerator()
    private let storySceneGenerator = StorySceneYAMLGenerator()
    private let backgroundGenerator = BackgroundYAMLGenerator()

    // MARK: - Public Methods

    @MainActor
    func generateFaceSheetYAML(mainViewModel: MainViewModel, faceSheetSettings: FaceSheetSettingsViewModel) -> String {
        return faceSheetGenerator.generate(mainViewModel: mainViewModel, settings: faceSheetSettings)
    }

    @MainActor
    func generateBodySheetYAML(mainViewModel: MainViewModel, bodySheetSettings: BodySheetSettingsViewModel) -> String {
        return bodySheetGenerator.generate(mainViewModel: mainViewModel, settings: bodySheetSettings)
    }

    @MainActor
    func generateOutfitSheetYAML(mainViewModel: MainViewModel, outfitSettings: OutfitSettingsViewModel) -> String {
        return outfitSheetGenerator.generate(mainViewModel: mainViewModel, settings: outfitSettings)
    }

    @MainActor
    func generatePoseYAML(mainViewModel: MainViewModel, poseSettings: PoseSettingsViewModel) -> String {
        return poseGenerator.generate(mainViewModel: mainViewModel, settings: poseSettings)
    }

    @MainActor
    func generateSceneBuilderYAML(mainViewModel: MainViewModel, sceneBuilderSettings: SceneBuilderSettingsViewModel) -> String {
        // 現在はストーリーシーンのみ対応（バトルシーン・ボスレイドは後日実装）
        return storySceneGenerator.generate(mainViewModel: mainViewModel, settings: sceneBuilderSettings)
    }

    @MainActor
    func generateBackgroundYAML(mainViewModel: MainViewModel, backgroundSettings: BackgroundSettingsViewModel) -> String {
        return backgroundGenerator.generate(mainViewModel: mainViewModel, settings: backgroundSettings)
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

    // MARK: - Title Overlay

    /// タイトルオーバーレイYAMLを生成
    static func generateTitleOverlay(title: String, includeTitleInImage: Bool) -> String {
        guard includeTitleInImage && !title.isEmpty else { return "" }
        return """

title_overlay:
  enabled: true
  text: "\(escapeYAMLString(title))"
  position: "top-left"
"""
    }
}
