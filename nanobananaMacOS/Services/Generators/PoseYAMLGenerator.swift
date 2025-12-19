import Foundation

/// ポーズYAML生成（Python版_generate_pose_yaml準拠）
final class PoseYAMLGenerator {

    // MARK: - Generate

    /// ポーズYAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: PoseSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Character Pose" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // 衣装着用三面図パス
        let characterSheetFileName = YAMLUtilities.getFileName(from: settings.outfitSheetImagePath)
        let characterSheetValue = characterSheetFileName.isEmpty ? "" : characterSheetFileName

        // 表情プロンプト生成
        let expressionPrompt = generateExpressionPrompt(settings: settings)

        // 風エフェクトセクション
        let windSection = generateWindSection(settings: settings)

        // プリセットコメント（キャプチャモードでは表示しない）
        let presetComment = generatePresetComment(settings: settings)

        // ポーズセクション（キャプチャモード or 通常モード）
        let poseSourceSection = generatePoseSourceSection(
            settings: settings,
            expressionPrompt: expressionPrompt,
            windSection: windSection
        )

        // 追加プロンプトセクション
        let additionalSection = generateAdditionalSection(settings: settings)

        // 背景設定
        let backgroundValue = settings.transparentBackground
            ? "transparent, fully clear alpha channel"
            : "pure white, clean background"

        // スタイル設定
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)
        let aspectRatioValue = mainViewModel.selectedAspectRatio.yamlValue
        let duotoneLine = YAMLUtilities.isDuotone(mainViewModel.selectedColorMode)
            ? "\n  duotone_style: \"\(YAMLUtilities.getDuotoneStyle())\""
            : ""

        // YAML生成
        var yaml = """
# Step 4: Pose Image (ポーズ画像)
# Purpose: Generate character in specified pose based on outfit sheet
# Output: Single character image
\(presetComment)type: pose_single
title: "\(YAMLUtilities.escapeYAMLString(title))"\(YAMLUtilities.generateAuthorLine(author))

# ====================================================
# Input Image
# ====================================================
input:
  character_sheet: "\(characterSheetValue)"
  identity_preservation: 1.0
  purpose: "Generate posed character from outfit sheet"

\(poseSourceSection)\(additionalSection)
# ====================================================
# Output Settings
# ====================================================
output:
  format: "single_image"
  background: "\(backgroundValue)"

# ====================================================
# CRITICAL CONSTRAINTS
# ====================================================
constraints:
  character_preservation:
    - "Preserve exact character design, face, and colors from input image"
    - "Maintain clothing details exactly as shown in input"
  output_format:
    - "Single character image, full body visible"

anti_hallucination:
  - "Do NOT alter character design from input"
  - "Do NOT add extra figures"

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
  - "The output must contain ONLY the single character on the specified background"

style:
  color_mode: "\(colorModeValue)"\(duotoneLine)
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return yaml
    }

    // MARK: - Private Methods

    /// 表情プロンプト生成
    private func generateExpressionPrompt(settings: PoseSettingsViewModel) -> String {
        let baseExpression = settings.expression.prompt
        let detail = settings.expressionDetail.trimmingCharacters(in: .whitespaces)

        if detail.isEmpty {
            return baseExpression
        } else {
            return "\(baseExpression), \(detail)"
        }
    }

    /// 風エフェクトセクション生成
    private func generateWindSection(settings: PoseSettingsViewModel) -> String {
        let windPrompt = settings.windEffect.prompt
        if windPrompt.isEmpty {
            return ""
        } else {
            return "\n  wind_effect: \"\(windPrompt)\""
        }
    }

    /// プリセットコメント生成
    private func generatePresetComment(settings: PoseSettingsViewModel) -> String {
        // キャプチャモードではプリセットコメントを表示しない
        if settings.usePoseCapture {
            return ""
        }

        // プリセットが選択されている場合のみコメント出力
        if settings.selectedPreset != .none {
            return "# Preset: \(settings.selectedPreset.rawValue)\n"
        }

        return ""
    }

    /// ポーズソースセクション生成（キャプチャモード or 通常モード）
    private func generatePoseSourceSection(
        settings: PoseSettingsViewModel,
        expressionPrompt: String,
        windSection: String
    ) -> String {
        if settings.usePoseCapture && !settings.poseReferenceImagePath.isEmpty {
            // ポーズキャプチャモード
            let poseRefFileName = YAMLUtilities.getFileName(from: settings.poseReferenceImagePath)
            return """
# ====================================================
# Pose Capture (ポーズキャプチャ)
# ====================================================
pose_capture:
  enabled: true
  reference_image: "\(poseRefFileName)"
  capture_target: "pose_only"
  instruction: |
    Capture ONLY the pose (body position, arm/leg positions, gestures) from the reference image.
    Apply this pose to the character while preserving:
    - Character's face and facial features from character_sheet
    - Character's outfit and clothing from character_sheet
    - Character's colors and design from character_sheet
    Do NOT transfer any appearance elements from the reference image.

pose:
  source: "captured from reference image"
  expression: "\(expressionPrompt)"
  eye_line: "\(settings.eyeLine.rawValue)"
  include_effects: \(settings.includeEffects ? "true" : "false")\(windSection)
"""
        } else {
            // 通常モード（プリセットまたは手動入力）
            let actionDesc = settings.actionDescription.trimmingCharacters(in: .whitespaces)
            return """
# ====================================================
# Pose Definition
# ====================================================
pose:
  description: "\(YAMLUtilities.escapeYAMLString(actionDesc))"
  expression: "\(expressionPrompt)"
  eye_line: "\(settings.eyeLine.rawValue)"
  include_effects: \(settings.includeEffects ? "true" : "false")\(windSection)
"""
        }
    }

    /// 追加プロンプトセクション生成
    private func generateAdditionalSection(settings: PoseSettingsViewModel) -> String {
        // キャプチャモードでは追加プロンプトなし
        if settings.usePoseCapture {
            return ""
        }

        // プリセットの追加プロンプトを取得
        let additionalPrompt = settings.selectedPreset.additionalPrompt
        if additionalPrompt.isEmpty {
            return ""
        }

        return """

additional_details:
  - "\(additionalPrompt)"
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
