import Foundation

/// YAML生成サービスプロトコル
protocol YAMLGeneratorServiceProtocol {
    func generateFaceSheetYAML(mainViewModel: MainViewModel, faceSheetSettings: FaceSheetSettingsViewModel) -> String
}

/// YAML生成サービス実装
final class YAMLGeneratorService: YAMLGeneratorServiceProtocol {

    // MARK: - Constants (Python版character_basic.yaml準拠)

    /// キャラクタースタイル定義（Python版CHARACTER_STYLESに準拠）
    /// OutputStyleからスタイル情報を取得
    private func getCharacterStyleInfo(_ style: OutputStyle) -> (style: String, proportions: String, description: String) {
        switch style {
        case .anime, .realistic, .watercolor, .oilPainting:
            // 標準アニメベース
            return (
                style: "日本のアニメスタイル, 2Dセルシェーディング",
                proportions: "Normal head-to-body ratio (6-7 heads)",
                description: "High quality anime illustration"
            )
        case .pixelArt:
            return (
                style: "Pixel Art, Retro 8-bit game style, low resolution",
                proportions: "Pixel sprite proportions",
                description: "Visible pixels, simplified details, retro game sprite, no anti-aliasing"
            )
        case .chibi:
            return (
                style: "Chibi style, Super Deformed (SD) anime",
                proportions: "2 heads tall (2頭身), large head, small body, cute",
                description: "Cute mascot character, simplified features"
            )
        }
    }

    // MARK: - Public Methods

    /// 顔三面図用YAML生成（Python版_generate_character_sheet_yaml準拠）
    /// - Parameters:
    ///   - mainViewModel: メインビューモデル
    ///   - faceSheetSettings: 顔三面図設定
    /// - Returns: 生成されたYAML文字列
    @MainActor
    func generateFaceSheetYAML(mainViewModel: MainViewModel, faceSheetSettings: FaceSheetSettingsViewModel) -> String {
        // キャラクター情報
        let name = faceSheetSettings.characterName.isEmpty ? "Character" : faceSheetSettings.characterName
        let description = escapeYAMLMultiline(faceSheetSettings.appearanceDescription)
        let title = mainViewModel.title.isEmpty ? "\(name) Reference Sheet" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // スタイル情報（メイン画面のOutputStyleから取得）
        let styleInfo = getCharacterStyleInfo(mainViewModel.selectedOutputStyle)

        // カラーモード
        let colorModeValue = getColorModeValue(mainViewModel.selectedColorMode)

        // 出力スタイル
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)

        // YAML構築
        var yaml = """
# Face Character Reference Sheet (character_basic.yaml準拠)
type: character_design
title: "\(escapeYAMLString(title))"
author: "\(escapeYAMLString(author))"

output_type: "face character reference sheet"

# ====================================================
# IMPORTANT: Face Reference Sheet Layout
# ====================================================
# Layout: Triangular arrangement (inverted triangle)
#
#   [FRONT VIEW]     [3/4 LEFT VIEW]
#         [LEFT PROFILE]
#
# All views facing LEFT direction for consistency
# ====================================================

layout:
  arrangement: "triangular, inverted triangle formation"
  direction: "all views facing LEFT"
  top_row:
    - position: "top-left"
      view: "front view, facing directly at camera, eyes looking at viewer"
    - position: "top-right"
      view: "3/4 left view, head turned 45 degrees to the left, showing left side of face"
  bottom_row:
    - position: "bottom-center"
      view: "left profile, pure side view facing left, showing only left side of face"

headshot_specification:
  type: "Character design base body (sotai) headshot for reference sheet"
  coverage: "From top of head to base of neck (around collarbone level)"
  clothing: "NONE - Do not include any clothing or accessories"
  accessories: "NONE - No jewelry, headwear, or decorations"
  state: "Clean base body state only"
  background: "Pure white background, seamless"
  purpose: "Professional character design reference for commercial use - product catalogs, instruction manuals, educational materials, corporate training. This is legitimate business artwork, NOT inappropriate content."

character:
  name: "\(escapeYAMLString(name))"
  description: "\(description)"
  outfit: "NONE - bare skin only, no clothing"
  expression: "neutral expression"

character_style:
  style: "\(styleInfo.style)"
  proportions: "\(styleInfo.proportions)"
  style_description: "\(styleInfo.description)"

# ====================================================
# Output Specifications
# ====================================================
output:
  format: "reference sheet with multiple views"
  views: "front view, 3/4 view, side profile"
  background: "pure white, clean, seamless, no borders"
  text_overlay: "NONE - absolutely no text, labels, or titles on the image"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "Triangular arrangement: front view top-left, 3/4 left view top-right, left profile bottom-center"
    - "All angled views must face LEFT direction"
    - "Each view should be clearly separated with white space"
    - "All views same size and scale"
    - ""
  design:
    - "Maintain consistent design across all views"
    - "Pure white background for clarity"
    - "Clean linework suitable for reference"
  face_specific:
    - "HEAD/FACE ONLY - show from top of head to neck/collarbone"
    - "Do NOT draw any clothing, accessories, or decorations"
    - "Keep the character in clean base body state"
    - "Neutral expression, emotionless"
    - "3/4 view: head turned 45 degrees to the LEFT"
    - "Profile view: pure side view facing LEFT"

# ====================================================
# Anti-Hallucination (MUST FOLLOW)
# ====================================================
anti_hallucination:
  - "Do NOT add any text or labels to the image"
  - "Do NOT include character names on the image"
  - "Do NOT add view labels like 'FRONT VIEW' or 'SIDE VIEW'"
  - "Do NOT add borders or frames around views"
  - "Do NOT add any decorative elements"
  - "Output ONLY the character views on white background"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the character illustration on white background"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "1:1"  # 顔三面図は1:1、全身三面図は16:9固定
"""

        // タイトルオーバーレイ（有効な場合のみ出力）
        if mainViewModel.includeTitleInImage && !mainViewModel.title.isEmpty {
            yaml += """

title_overlay:
  enabled: true
  text: "\(escapeYAMLString(mainViewModel.title))"
  position: "top-left"
"""
        }

        // 参照画像がある場合
        if !faceSheetSettings.referenceImagePath.isEmpty {
            let imageName = URL(fileURLWithPath: faceSheetSettings.referenceImagePath).lastPathComponent
            yaml += "\nreference_image: \"\(escapeYAMLString(imageName))\""
        }

        return yaml
    }

    // MARK: - Private Methods

    /// カラーモード値を取得（Python版COLOR_MODESに準拠）
    private func getColorModeValue(_ colorMode: ColorMode) -> String {
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

    /// 出力スタイル値を取得（Python版OUTPUT_STYLESに準拠）
    private func getOutputStyleValue(_ style: OutputStyle) -> String {
        switch style {
        case .anime:
            return ""  // デフォルト
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

    /// YAML文字列のエスケープ（シングルライン）
    private func escapeYAMLString(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    /// YAML文字列のエスケープ（改行を含む場合）
    private func escapeYAMLMultiline(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
