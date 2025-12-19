import Foundation

/// 素体三面図YAML生成（Python版_generate_body_sheet_yaml準拠）
final class BodySheetYAMLGenerator {

    // MARK: - Body Type Presets (Python版BODY_TYPE_PRESETSに準拠)

    private struct BodyTypeInfo {
        let description: String
        let height: String
        let build: String
        let gender: String
    }

    private func getBodyTypeInfo(_ preset: BodyTypePreset) -> BodyTypeInfo {
        switch preset {
        case .femalStandard:
            return BodyTypeInfo(
                description: "average female body, slim build, normal proportions",
                height: "average height",
                build: "slim",
                gender: "female"
            )
        case .maleStandard:
            return BodyTypeInfo(
                description: "average male body, normal build, normal proportions",
                height: "average height",
                build: "normal",
                gender: "male"
            )
        case .slim:
            return BodyTypeInfo(
                description: "slender body, thin build, long limbs",
                height: "tall",
                build: "slender",
                gender: "neutral"
            )
        case .muscular:
            return BodyTypeInfo(
                description: "muscular body, athletic build, well-defined muscles",
                height: "average to tall",
                build: "muscular",
                gender: "neutral"
            )
        case .chubby:
            return BodyTypeInfo(
                description: "chubby body, soft round build, plump",
                height: "average",
                build: "chubby",
                gender: "neutral"
            )
        case .petite:
            return BodyTypeInfo(
                description: "petite build, very short stature, small compact frame, tiny body",
                height: "very short",
                build: "petite compact",
                gender: "neutral"
            )
        case .tall:
            return BodyTypeInfo(
                description: "tall body, long legs, model-like proportions",
                height: "tall",
                build: "slim",
                gender: "neutral"
            )
        case .short:
            return BodyTypeInfo(
                description: "short body, compact build, petite",
                height: "short",
                build: "petite",
                gender: "neutral"
            )
        }
    }

    // MARK: - Bust Features (Python版BUST_FEATURESに準拠)

    private func getBustFeaturePrompt(_ feature: BustFeature) -> String {
        switch feature {
        case .auto:
            return ""  // おまかせ
        case .small:
            return "slender athletic figure, sports bra style, flat chest area"
        case .normal:
            return "normal proportions"
        case .large:
            return "feminine silhouette, hourglass figure, curvy body shape"
        }
    }

    // MARK: - Render Types (Python版BODY_RENDER_TYPESに準拠)

    private func getRenderTypePrompt(_ renderType: BodyRenderType) -> String {
        switch renderType {
        case .silhouette:
            return "solid black silhouette, shape only, no details, clean outline"
        case .whiteLeotard:
            return "wearing plain white leotard, simple white bodysuit, minimal details, reference mannequin"
        case .whiteUnderwear:
            return "wearing simple white underwear, white bra and white panties, minimal clothing, body shape clearly visible, reference mannequin"
        case .anatomical:
            return "anatomical reference, muscle groups visible, artistic anatomy study"
        }
    }

    // MARK: - Generate

    /// 素体三面図YAMLを生成
    /// - Parameters:
    ///   - mainViewModel: メインビューモデル
    ///   - settings: 素体三面図設定
    /// - Returns: 生成されたYAML文字列
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: BodySheetSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Body Reference Sheet" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // 顔三面図パス
        let faceSheetFileName = YAMLUtilities.getFileName(from: settings.faceSheetImagePath)
        let faceSheetValue = faceSheetFileName.isEmpty ? "REQUIRED" : faceSheetFileName

        // 体型情報
        let bodyTypeInfo = getBodyTypeInfo(settings.bodyTypePreset)

        // バスト特徴
        let bustPrompt = getBustFeaturePrompt(settings.bustFeature)

        // 表現タイプ
        let renderPrompt = getRenderTypePrompt(settings.bodyRenderType)

        // 追加説明（改行をカンマ区切りに変換）
        let additionalDesc = YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)

        // スタイル情報
        let styleInfo = YAMLUtilities.getCharacterStyleInfo(mainViewModel.selectedOutputStyle)
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)

        // figure_style と additional_notes の条件付き出力
        let figureStyleLine = bustPrompt.isEmpty ? "" : "  figure_style: \"\(bustPrompt)\"\n"
        let additionalNotesLine = additionalDesc.isEmpty ? "" : "  additional_notes: \"\(additionalDesc)\"\n"

        // YAML構築
        var yaml = """
# Step 2: Body Reference Sheet (素体三面図)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
type: body_reference_sheet
title: "\(YAMLUtilities.escapeYAMLString(title))"\(YAMLUtilities.generateAuthorLine(author))

# ====================================================
# Input: Face Sheet from Step 1
# ====================================================
input:
  face_sheet: "\(faceSheetValue)"
  preserve_face: true
  preserve_face_details: "exact match required - do not alter facial features"

# ====================================================
# Body Configuration
# ====================================================
body:
  type: "\(settings.bodyTypePreset.rawValue)"
  description: "\(bodyTypeInfo.description)"
  height: "\(bodyTypeInfo.height)"
  build: "\(bodyTypeInfo.build)"
  gender: "\(bodyTypeInfo.gender)"
\(figureStyleLine)\(additionalNotesLine)
# ====================================================
# Render Type
# ====================================================
render:
  type: "\(settings.bodyRenderType.rawValue)"
  style: "\(renderPrompt)"
  clothing: "NONE - this is a base body reference"

# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), standing straight, arms at sides, heels together"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "\(styleInfo.style)"
  proportions: "\(styleInfo.proportions)"
  color_mode: "\(colorModeValue)"
  aspect_ratio: "16:9"  # 素体三面図は16:9固定

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
  face_preservation:
    - "MUST use exact face from input face_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from reference"
  body_generation:
    - "Generate body matching the specified body type"
    - "Do NOT add any clothing or accessories beyond specified render type"
    - "Maintain anatomically correct proportions"
  pose:
    - "Attention pose (kiwotsuke): standing straight with arms at sides"
    - "Heels together, toes slightly apart"
    - "Arms relaxed at sides, palms facing inward"
    - "Do NOT use T-pose or A-pose"
  consistency:
    - "All three views must show the same character in same pose"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
  - "Do NOT add clothing that was not specified"
  - "Do NOT change the face from the reference"
  - "Do NOT add accessories or decorations"
  - "Do NOT change body proportions from specified type"
  - "Do NOT add any text or labels to the image"
  - "Do NOT use T-pose or A-pose - use attention pose only"
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

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
  - "The output must contain ONLY the three-view character illustration on white background"
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return yaml
    }
}
