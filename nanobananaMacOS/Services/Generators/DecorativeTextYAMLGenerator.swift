import Foundation

/// 装飾テキストYAML生成（Python版_generate_decorative_yaml準拠）
final class DecorativeTextYAMLGenerator {

    // MARK: - Generate

    /// 装飾テキストYAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: DecorativeTextSettingsViewModel) -> String {
        // スタイル設定
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)
        let outputStyleValue = getOutputStyleValue(mainViewModel.selectedOutputStyle)
        let aspectRatioValue = mainViewModel.selectedAspectRatio.yamlValue

        // テキストタイプに応じてYAML生成
        let yaml: String
        switch settings.textType {
        case .skillName:
            yaml = generateSkillNameYAML(
                settings: settings,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        case .catchphrase:
            yaml = generateCatchphraseYAML(
                settings: settings,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        case .namePlate:
            yaml = generateNamePlateYAML(
                settings: settings,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        case .messageWindow:
            yaml = generateMessageWindowYAML(
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
            author: mainViewModel.authorName,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return result
    }

    // MARK: - 技名テロップ

    private func generateSkillNameYAML(
        settings: DecorativeTextSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let bgValue = settings.transparentBackground ? "Transparent" : "None (Generate with scene)"
        let outlineEnabled = settings.titleOutline != .none

        return """
# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Anime Battle"
  font_language: "Japanese"

special_move_title:
  enabled: true
  text: "\(YAMLUtilities.escapeYAMLString(settings.text))"

  style:
    font_type: "\(getTitleFontValue(settings.titleFont))"
    size: "\(getTitleSizeValue(settings.titleSize))"
    fill_color: "\(getGradientColorValue(settings.titleColor))"
    outline:
      enabled: \(outlineEnabled ? "true" : "false")
      color: "\(getOutlineColorValue(settings.titleOutline))"
      thickness: "Thick"
    glow_effect: "\(getGlowEffectValue(settings.titleGlow))"
    drop_shadow: "\(settings.titleShadow ? "Hard Drop" : "None")"

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""
    }

    // MARK: - 決め台詞

    private func generateCatchphraseYAML(
        settings: DecorativeTextSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let bgValue = settings.transparentBackground ? "Transparent" : "None (Generate with scene)"

        return """
# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Anime Battle"
  font_language: "Japanese"

impact_callout:
  enabled: true
  text: "\(YAMLUtilities.escapeYAMLString(settings.text))"

  style:
    type: "\(getCalloutTypeValue(settings.calloutType))"
    color: "\(getCalloutColorValue(settings.calloutColor))"
    rotation: "\(getRotationValue(settings.calloutRotation))"
    distortion: "\(getDistortionValue(settings.calloutDistortion))"

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""
    }

    // MARK: - キャラ名プレート

    private func generateNamePlateYAML(
        settings: DecorativeTextSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let bgValue = settings.transparentBackground ? "Transparent" : "None (Generate with scene)"

        return """
# Decorative Text (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Character Name Plate"
  font_language: "Japanese"

name_tag:
  enabled: true
  text: "\(YAMLUtilities.escapeYAMLString(settings.text))"

  style:
    type: "\(getNameTagDesignValue(settings.nameTagDesign))"
    rotation: "\(getRotationValue(settings.nameTagRotation))"

constraints:
  - "Generate ONLY the name plate/tag element"
  - "Do NOT add any game UI elements (health bars, meters, VS logos)"
  - "Do NOT add any fighting game or battle interface elements"

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""
    }

    // MARK: - メッセージウィンドウ

    private func generateMessageWindowYAML(
        settings: DecorativeTextSettingsViewModel,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let bgValue = settings.transparentBackground ? "Transparent" : "None (Generate with scene)"

        switch settings.messageMode {
        case .full:
            return generateMessageWindowFullYAML(
                settings: settings,
                bgValue: bgValue,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        case .faceOnly:
            return generateMessageWindowFaceOnlyYAML(
                settings: settings,
                bgValue: bgValue,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue
            )
        case .textOnly:
            return generateMessageWindowTextOnlyYAML(
                settings: settings,
                bgValue: bgValue,
                colorModeValue: colorModeValue,
                outputStyleValue: outputStyleValue,
                aspectRatioValue: aspectRatioValue
            )
        }
    }

    // MARK: - メッセージウィンドウ（フルスペック）

    private func generateMessageWindowFullYAML(
        settings: DecorativeTextSettingsViewModel,
        bgValue: String,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        let faceSource = getFaceSourceValue(settings.faceIconImagePath)

        return """
# Message Window - Full (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Message Window"
  font_language: "Japanese"

message_window:
  enabled: true
  mode: "full"
  speaker_name: "\(YAMLUtilities.escapeYAMLString(settings.speakerName))"
  text: "\(YAMLUtilities.escapeYAMLString(settings.text))"
  style_preset: "\(getMessageWindowStyleValue(settings.messageStyle))"

  design:
    position: "Bottom Center"
    width: "90%"
    frame_type: "\(getMessageFrameTypeValue(settings.messageFrameType))"
    background_opacity: \(settings.messageOpacity)

    face_icon:
      enabled: true
      source_image: "\(faceSource)"
      position: "\(getFaceIconPositionValue(settings.faceIconPosition))"
      crop_area: "Head and neck only (from top of head to base of neck)"

constraints:
  - "Generate ONLY the message window UI element"
  - "Do NOT draw any full-body character in the scene"
  - "Do NOT include any character outside the message window"
  - "The reference image is ONLY for the face icon, not for adding a character to the scene"

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""
    }

    // MARK: - メッセージウィンドウ（顔アイコンのみ）

    private func generateMessageWindowFaceOnlyYAML(
        settings: DecorativeTextSettingsViewModel,
        bgValue: String,
        colorModeValue: String,
        outputStyleValue: String
    ) -> String {
        let faceSource = getFaceSourceValue(settings.faceIconImagePath)

        return """
# Message Window - Face Only (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Face Icon"
  font_language: "Japanese"

message_window:
  enabled: true
  mode: "face_only"

  design:
    face_icon:
      enabled: true
      source_image: "\(faceSource)"
      position: "\(getFaceIconPositionValue(settings.faceIconPosition))"
      style: "Standalone"
      crop_area: "Head and neck only (from top of head to base of neck)"

constraints:
  - "Generate ONLY the face icon element"
  - "Do NOT draw any full-body character"
  - "The reference image is ONLY for extracting the face, not for adding a character"

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "1:1"
"""
    }

    // MARK: - メッセージウィンドウ（セリフのみ）

    private func generateMessageWindowTextOnlyYAML(
        settings: DecorativeTextSettingsViewModel,
        bgValue: String,
        colorModeValue: String,
        outputStyleValue: String,
        aspectRatioValue: String
    ) -> String {
        return """
# Message Window - Text Only (ui_text_overlay.yaml準拠)
type: text_ui_layer_definition

ui_global_style:
  preset: "Message Window"
  font_language: "Japanese"

message_window:
  enabled: true
  mode: "text_only"
  text: "\(YAMLUtilities.escapeYAMLString(settings.text))"

  design:
    position: "Bottom Center"
    width: "90%"
    frame_type: "\(getMessageFrameTypeValue(settings.messageFrameType))"
    background_opacity: \(settings.messageOpacity)

    face_icon:
      enabled: false

output:
  background: "\(bgValue)"

style:
  color_mode: "\(colorModeValue)"
  output_style: "\(outputStyleValue)"
  aspect_ratio: "\(aspectRatioValue)"
"""
    }

    // MARK: - Value Converters

    /// 出力スタイル値を取得（Python版OUTPUT_STYLES準拠）
    private func getOutputStyleValue(_ style: OutputStyle) -> String {
        switch style {
        case .anime: return "anime"
        case .pixelArt: return "pixel_art"
        case .chibi: return "chibi"
        case .realistic: return "realistic"
        case .watercolor: return "watercolor"
        case .oilPainting: return "oil_painting"
        }
    }

    /// 技名フォント値を取得（Python版TITLE_FONTS準拠）
    private func getTitleFontValue(_ font: TitleFont) -> String {
        switch font {
        case .heavyMincho: return "Heavy Mincho"
        case .brush: return "Brush Script"
        case .gothic: return "Gothic"
        }
    }

    /// 技名サイズ値を取得（Python版TITLE_SIZES準拠）
    private func getTitleSizeValue(_ size: TitleSize) -> String {
        switch size {
        case .veryLarge: return "Very Large"
        case .large: return "Large"
        case .medium: return "Medium"
        }
    }

    /// グラデーション色値を取得（Python版GRADIENT_COLORS準拠）
    private func getGradientColorValue(_ color: GradientColor) -> String {
        switch color {
        case .whiteToBlue: return "White to Blue Gradient"
        case .whiteToRed: return "White to Red Gradient"
        case .goldToOrange: return "Gold to Orange Gradient"
        case .whiteToPurple: return "White to Purple Gradient"
        case .solidWhite: return "Solid White"
        case .solidGold: return "Solid Gold"
        }
    }

    /// 縁取り色値を取得（Python版OUTLINE_COLORS準拠）
    private func getOutlineColorValue(_ color: OutlineColor) -> String {
        switch color {
        case .gold: return "Gold"
        case .black: return "Black"
        case .red: return "Red"
        case .blue: return "Blue"
        case .none: return "None"
        }
    }

    /// 発光エフェクト値を取得（Python版GLOW_EFFECTS準拠）
    private func getGlowEffectValue(_ effect: GlowEffect) -> String {
        switch effect {
        case .none: return "None"
        case .blueLightning: return "Blue Lightning"
        case .fire: return "Fire"
        case .electric: return "Electric"
        case .aura: return "Aura"
        }
    }

    /// 決め台詞タイプ値を取得（Python版CALLOUT_TYPES準拠）
    private func getCalloutTypeValue(_ type: CalloutType) -> String {
        switch type {
        case .comic: return "Comic Sound Effect"
        case .verticalShout: return "Vertical Shout"
        case .pop: return "Pop Style"
        }
    }

    /// 決め台詞配色値を取得（Python版CALLOUT_COLORS準拠）
    private func getCalloutColorValue(_ color: CalloutColor) -> String {
        switch color {
        case .redYellow: return "Red with Yellow Border"
        case .whiteBlack: return "White with Black Border"
        case .blueWhite: return "Blue with White Border"
        case .yellowRed: return "Yellow with Red Border"
        }
    }

    /// 回転角度値を取得（Python版ROTATIONS準拠）
    private func getRotationValue(_ rotation: TextRotation) -> String {
        switch rotation {
        case .none: return "0 degrees"
        case .slightLeft: return "-5 degrees"
        case .left: return "-15 degrees"
        case .slightRight: return "5 degrees"
        case .right: return "15 degrees"
        }
    }

    /// 変形効果値を取得（Python版DISTORTIONS準拠）
    private func getDistortionValue(_ distortion: TextDistortion) -> String {
        switch distortion {
        case .none: return "None"
        case .zoomIn: return "Zoom In"
        case .zoomOut: return "Zoom Out"
        case .wave: return "Wave"
        }
    }

    /// キャラ名プレートデザイン値を取得（Python版NAMETAG_TYPES準拠）
    private func getNameTagDesignValue(_ design: NameTagDesign) -> String {
        switch design {
        case .jagged: return "Jagged Sticker"
        case .simple: return "Simple Frame"
        case .ribbon: return "Ribbon"
        }
    }

    /// メッセージウィンドウスタイル値を取得（Python版MSGWIN_STYLES準拠）
    private func getMessageWindowStyleValue(_ style: MessageWindowStyle) -> String {
        switch style {
        case .sciFi: return "Sci-Fi Tech"
        case .retroRPG: return "Retro RPG"
        case .visualNovel: return "Visual Novel"
        }
    }

    /// メッセージウィンドウ枠タイプ値を取得（Python版MSGWIN_FRAME_TYPES準拠）
    private func getMessageFrameTypeValue(_ frameType: MessageFrameType) -> String {
        switch frameType {
        case .cyberneticBlue: return "Cybernetic Blue"
        case .classicBlack: return "Classic Black"
        case .translucentWhite: return "Translucent White"
        case .goldOrnate: return "Gold Ornate"
        }
    }

    /// 顔アイコン位置値を取得（Python版FACE_ICON_POSITIONS準拠）
    private func getFaceIconPositionValue(_ position: FaceIconPosition) -> String {
        switch position {
        case .leftInside: return "Left Inside"
        case .rightInside: return "Right Inside"
        case .leftOutside: return "Left Outside"
        case .none: return "None"
        }
    }

    /// 顔アイコンソース値を取得
    private func getFaceSourceValue(_ imagePath: String) -> String {
        if imagePath.isEmpty {
            return "Auto (generate based on speaker name)"
        } else {
            let fileName = YAMLUtilities.getFileName(from: imagePath)
            return "Reference: \(fileName) (use head/neck portion as face icon)"
        }
    }
}
