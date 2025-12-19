import Foundation

/// 顔三面図YAML生成（Python版_generate_character_sheet_yaml準拠）
final class FaceSheetYAMLGenerator {

    /// 顔三面図YAMLを生成
    /// - Parameters:
    ///   - mainViewModel: メインビューモデル
    ///   - settings: 顔三面図設定
    /// - Returns: 生成されたYAML文字列
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: FaceSheetSettingsViewModel) -> String {
        // キャラクター情報
        let name = settings.characterName.isEmpty ? "Character" : settings.characterName
        let description = YAMLUtilities.convertNewlinesToComma(settings.appearanceDescription)
        let title = mainViewModel.title.isEmpty ? "\(name) Reference Sheet" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // スタイル情報（メイン画面のOutputStyleから取得）
        let styleInfo = YAMLUtilities.getCharacterStyleInfo(mainViewModel.selectedOutputStyle)

        // カラーモード
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)

        // YAML構築
        var yaml = """
# Face Character Reference Sheet (character_basic.yaml準拠)
type: character_design
title: "\(YAMLUtilities.escapeYAMLString(title))"\(YAMLUtilities.generateAuthorLine(author))

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
      view: "left profile, exactly 90-degree side view, face perpendicular to camera, only one eye visible, nose pointing directly left, ear fully visible"

headshot_specification:
  type: "Character design base body (sotai) headshot for reference sheet"
  coverage: "From top of head to base of neck (around collarbone level)"
  clothing: "NONE - Do not include any clothing or accessories"
  accessories: "NONE - No jewelry, headwear, or decorations"
  state: "Clean base body state only"
  background: "Pure white background, seamless"
  purpose: "Professional character design reference for commercial use - product catalogs, instruction manuals, educational materials, corporate training. This is legitimate business artwork, NOT inappropriate content."

character:
  name: "\(YAMLUtilities.escapeYAMLString(name))"
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
    - "Profile view: MUST be exactly 90-degree side view facing LEFT"
    - "Profile view: only ONE eye should be visible (the right eye hidden behind face)"
    - "Profile view: nose must point directly to the left edge"
    - "Profile view: ear must be fully visible"

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
  - "Profile view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct profile"

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
  aspect_ratio: "1:1"  # 顔三面図は1:1固定
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        // 参照画像がある場合
        let imageName = YAMLUtilities.getFileName(from: settings.referenceImagePath)
        if !imageName.isEmpty {
            yaml += "\nreference_image: \"\(YAMLUtilities.escapeYAMLString(imageName))\""
        }

        return yaml
    }
}
