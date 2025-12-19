import Foundation

/// 背景生成YAML生成（Python版_generate_background_yaml準拠）
final class BackgroundYAMLGenerator {

    // MARK: - Generate

    /// 背景生成YAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: BackgroundSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Background" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // スタイル設定
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)
        let aspectRatioValue = mainViewModel.selectedAspectRatio.rawValue

        // モードに応じてYAML生成
        let yaml: String
        if settings.useReferenceImage {
            yaml = generateCaptureMode(
                title: title,
                author: author,
                settings: settings,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        } else {
            yaml = generateDescriptionMode(
                title: title,
                author: author,
                settings: settings,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        }

        // タイトルオーバーレイ
        var result = yaml
        result += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return result
    }

    // MARK: - Private Methods

    /// 背景キャプチャモード（参考画像あり）
    private func generateCaptureMode(
        title: String,
        author: String,
        settings: BackgroundSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let referenceFileName = YAMLUtilities.getFileName(from: settings.referenceImagePath)

        // 変形指示（空の場合はアニメ調に変換）
        let transformInstruction: String
        if settings.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            transformInstruction = "Convert to anime/illustration style, clean lines, vibrant colors"
        } else {
            transformInstruction = YAMLUtilities.convertNewlinesToComma(settings.description)
        }

        // アスペクト比の指示
        let aspectRatioInstruction: String
        if aspectRatioValue == "元画像維持" {
            aspectRatioInstruction = "Preserve the original aspect ratio of the reference image"
        } else {
            aspectRatioInstruction = "Output aspect ratio: \(aspectRatioValue)"
        }

        // 人物除去セクション
        let removePeopleSection: String
        if settings.removeCharacters {
            removePeopleSection = """

  remove_people:
    enabled: true
    instruction: "Remove all people/humans from the image. Fill the removed areas naturally with background elements."

"""
        } else {
            removePeopleSection = ""
        }

        return """
# Background Capture (背景キャプチャ)
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

output_type: "background_capture"

# ====================================================
# Background Capture Settings
# ====================================================
background_capture:
  enabled: true
  reference_image: "\(referenceFileName)"
  transform_instruction: "\(transformInstruction)"
  aspect_ratio: "\(aspectRatioValue)"
  aspect_ratio_instruction: "\(aspectRatioInstruction)"
\(removePeopleSection)
# ====================================================
# CRITICAL CONSTRAINTS
# ====================================================
constraints:
  - "Use the reference image as the base for the background"
  - "Apply the transformation instruction to modify the style/atmosphere"
  - "Do NOT include any characters or people in the output"
  - "Maintain the general composition and layout from the reference"
  - "\(aspectRatioInstruction)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the background illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes or color samples"
  - "Do NOT add location markers, arrows, or explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the background scene"
"""
    }

    /// テキスト記述モード（参考画像なし）
    private func generateDescriptionMode(
        title: String,
        author: String,
        settings: BackgroundSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let description = YAMLUtilities.convertNewlinesToComma(settings.description)

        return """
# Background Generation
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

output_type: "background only"

background:
  description: "\(description)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the background illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes or color samples"
  - "Do NOT add location markers, arrows, or explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the background scene"
"""
    }

    /// 出力スタイル値を取得（Python版OUTPUT_STYLES準拠）
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
}
