import Foundation

/// スタイル変換YAML生成（Python版_generate_style_transform_yaml準拠）
final class StyleTransformYAMLGenerator {

    // MARK: - Generate

    /// スタイル変換YAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: StyleTransformSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Style Transform" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName
        let aspectRatioValue = mainViewModel.selectedAspectRatio.yamlValue

        // 変換タイプに応じて分岐
        let yaml: String
        switch settings.transformType {
        case .chibi:
            yaml = generateChibiYAML(
                title: title,
                author: author,
                aspectRatioValue: aspectRatioValue,
                settings: settings
            )
        case .pixel:
            yaml = generatePixelYAML(
                title: title,
                author: author,
                settings: settings
            )
        }

        // タイトルオーバーレイ
        var result = yaml
        result += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return result
    }

    // MARK: - Chibi YAML

    /// ちびキャラ化YAML生成
    private func generateChibiYAML(
        title: String,
        author: String,
        aspectRatioValue: String,
        settings: StyleTransformSettingsViewModel
    ) -> String {
        let sourceImageName = YAMLUtilities.getFileName(from: settings.sourceImagePath)
        let chibiStyle = settings.chibiStyle
        let backgroundValue = settings.transparentBackground ? "transparent" : "simple solid color"

        // 保持する要素のリスト作成
        var preserveList: [String] = []
        if settings.keepOutfit {
            preserveList.append("outfit and clothing")
        }
        if settings.keepPose {
            preserveList.append("pose and action")
        }
        let preserveStr = preserveList.isEmpty ? "basic appearance" : preserveList.joined(separator: ", ")

        return """
# Style Transform: Chibi Conversion (スタイル変換: ちびキャラ化)
# Transform realistic/normal character to chibi (super-deformed) style
# The source image can be from any stage (base/outfit/pose)
type: style_transform_chibi
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

# ====================================================
# Input Image (Source Character)
# ====================================================
input:
  source_image: "\(sourceImageName.isEmpty ? "REQUIRED" : sourceImageName)"
  source_stage: "any (base body / with outfit / with pose)"

# ====================================================
# Transform Settings
# ====================================================
transform:
  type: "chibi"
  style: "\(chibiStyle.rawValue)"
  style_prompt: "\(chibiStyle.prompt)"
  head_ratio: "\(chibiStyle.headRatio)"

# ====================================================
# Preservation Settings
# ====================================================
preserve:
  elements: "\(preserveStr)"
  face_features: "Maintain character's face identity (eyes, hair color, expression)"
  outfit_details: \(settings.keepOutfit ? "true" : "false")
  pose_action: \(settings.keepPose ? "true" : "false")

# ====================================================
# Output Settings
# ====================================================
output:
  style: "chibi / super-deformed"
  aspect_ratio: "\(aspectRatioValue)"
  background: "\(backgroundValue)"
  quality: "clean linework, cute proportions"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  chibi_rules:
    - "Transform to chibi style with \(chibiStyle.headRatio) head-to-body ratio"
    - "Large head, small body, simplified features"
    - "Maintain character identity (face, hair, colors)"
    - "Keep the cuteness and appeal of chibi style"
  preservation_rules:
    - "Preserve: \(preserveStr)"
    - "Maintain the same outfit design (simplified for chibi proportions)"
    - "Keep the same pose action (adapted for chibi body)"
  style_consistency:
    - "Use consistent chibi proportions throughout"
    - "Clean, cute linework suitable for chibi style"
    - "\(settings.transparentBackground ? "Transparent background for easy compositing" : "Simple background")"

anti_hallucination:
  - "Do NOT change character's identity (face, hair color)"
  - "Do NOT add new accessories not in source"
  - "Do NOT change outfit design significantly"
  - "MAINTAIN chibi proportions consistently"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the chibi character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add size comparison charts or reference guides"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the chibi character on the specified background"
"""
    }

    // MARK: - Pixel YAML

    /// ドットキャラ化YAML生成
    private func generatePixelYAML(
        title: String,
        author: String,
        settings: StyleTransformSettingsViewModel
    ) -> String {
        let sourceImageName = YAMLUtilities.getFileName(from: settings.sourceImagePath)
        let pixelStyle = settings.pixelStyle
        let spriteSize = settings.spriteSize
        let backgroundValue = settings.transparentBackground ? "transparent" : "simple solid color"

        return """
# Style Transform: Pixel Art Conversion (スタイル変換: ドットキャラ化)
# Transform character to pixel art / sprite style
# The source image can be from any stage (base/outfit/pose)
type: style_transform_pixel
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

# ====================================================
# Input Image (Source Character)
# ====================================================
input:
  source_image: "\(sourceImageName.isEmpty ? "REQUIRED" : sourceImageName)"
  source_stage: "any (base body / with outfit / with pose)"

# ====================================================
# Transform Settings
# ====================================================
transform:
  type: "pixel_art"
  style: "\(pixelStyle.rawValue)"
  style_prompt: "\(pixelStyle.prompt)"
  resolution: "\(pixelStyle.resolution)"
  color_depth: "\(pixelStyle.colors)"

# ====================================================
# Sprite Settings
# ====================================================
sprite:
  size: "\(spriteSize.rawValue)"
  size_prompt: "\(spriteSize.prompt)"
  preserve_colors: \(settings.keepColors ? "true" : "false")
  transparent_background: \(settings.transparentBackground ? "true" : "false")

# ====================================================
# Output Settings
# ====================================================
output:
  style: "pixel art sprite"
  aspect_ratio: "1:1"
  background: "\(backgroundValue)"
  quality: "clean pixels, game sprite aesthetic"

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  pixel_art_rules:
    - "Convert to \(pixelStyle.rawValue) pixel art style"
    - "Use \(spriteSize.rawValue) sprite size"
    - "Clean, sharp pixels with no anti-aliasing blur"
    - "Limited color palette appropriate for \(pixelStyle.rawValue)"
  preservation_rules:
    - "Maintain character identity (recognizable silhouette)"
    - "Keep the same outfit and pose from source"
    - "\(settings.keepColors ? "Reference original colors from source image" : "Use appropriate pixel art palette")"
  style_consistency:
    - "Consistent pixel size throughout the sprite"
    - "Game sprite aesthetic, suitable for game use"
    - "\(settings.transparentBackground ? "Transparent background for easy compositing" : "Simple background")"

anti_hallucination:
  - "Do NOT add pixel art artifacts or noise"
  - "Do NOT blur or anti-alias the pixels"
  - "MAINTAIN consistent pixel grid"
  - "Do NOT change character's recognizable features"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the pixel art character sprite - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add size comparison charts or pixel grid guides"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the pixel art sprite on the specified background"
"""
    }
}
