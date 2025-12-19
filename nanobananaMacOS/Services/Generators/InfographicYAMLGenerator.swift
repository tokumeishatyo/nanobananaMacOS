import Foundation

/// インフォグラフィックYAML生成（Python版_generate_infographic_yaml準拠）
final class InfographicYAMLGenerator {

    // MARK: - Generate

    /// インフォグラフィックYAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: InfographicSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Infographic" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        let style = settings.infographicStyle
        let mainTitle = settings.mainTitle.isEmpty ? title : settings.mainTitle
        let subtitle = settings.subtitle

        // 言語値の取得（「その他」の場合はカスタム入力を使用）
        let languageValue: String
        if settings.outputLanguage == .other {
            languageValue = settings.customLanguage.isEmpty ? "Custom" : settings.customLanguage
        } else {
            languageValue = settings.outputLanguage.languageValue
        }

        // メイン画像
        let mainImageName = YAMLUtilities.getFileName(from: settings.mainCharacterImagePath)

        // おまけ画像セクション
        let bonusSection = generateBonusSection(settings: settings)

        // セクション生成
        let sectionsText = generateSectionsText(settings: settings)
        let sectionsList = generateSectionsList(settings: settings)

        var yaml = """
# Infographic Generation (インフォグラフィック)
# Style: \(style.rawValue)
type: infographic
title: "\(YAMLUtilities.escapeYAMLString(mainTitle))"\(YAMLUtilities.generateAuthorLine(author))

# ====================================================
# Style Settings
# ====================================================
style:
  type: "\(style.key)"
  style_prompt: "\(style.prompt)"
  aspect_ratio: "16:9"
  output_language: "\(languageValue)"

# ====================================================
# Title Configuration
# ====================================================
titles:
  main_title: "\(YAMLUtilities.escapeYAMLString(mainTitle))"
  subtitle: "\(YAMLUtilities.escapeYAMLString(subtitle))"

# ====================================================
# Main Character Image
# ====================================================
main_character:
  image: "\(mainImageName.isEmpty ? "REQUIRED" : mainImageName)"
  position: "center"
  instruction: "Place this character image at the center of the infographic"
\(bonusSection)
# ====================================================
# Information Sections
# ====================================================
# Layout reference:
#   [1] [2] [3]
#   [4] CHAR [5]
#   [6] [7] [8]
sections:\(sectionsText)

# ====================================================
# Generation Instructions
# ====================================================
prompt: |
  Create a detailed infographic about this person/character in \(style.key) style.
  Use the attached character image as the central figure.
  Include extremely detailed information - small text is acceptable if it adds more detail.

  Style: \(style.prompt)

  Main title: "\(YAMLUtilities.escapeYAMLString(mainTitle))"
  \(subtitle.isEmpty ? "" : "Subtitle: \(YAMLUtilities.escapeYAMLString(subtitle))")

  Include these sections around the character:
\(sectionsList)

  Output language: \(languageValue)

  IMPORTANT:
  - Create related icons and decorations automatically based on the content
  - Use the \(style.key) visual style consistently
  - Make it visually engaging with colors, icons, and artistic elements
  - Include as much detail as possible in small organized sections

# ====================================================
# Constraints
# ====================================================
constraints:
  - "Use the provided character image as the main central figure"
  - "Arrange information sections around the character"
  - "Create appropriate icons and decorations based on content (AI decides)"
  - "Output all text in \(languageValue)"
  - "Maintain \(style.key) style throughout"
  - "Aspect ratio: 16:9"

anti_hallucination:
  - "Do NOT change the character's appearance from the provided image"
  - "Do NOT omit any of the specified sections"
  - "Do NOT add unrelated information not in the sections"
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

    /// おまけ画像セクションを生成
    private func generateBonusSection(settings: InfographicSettingsViewModel) -> String {
        let bonusImageName = YAMLUtilities.getFileName(from: settings.subCharacterImagePath)
        guard !bonusImageName.isEmpty else { return "" }

        return """

# ====================================================
# Bonus Character Image
# ====================================================
bonus_character:
  enabled: true
  image: "\(bonusImageName)"
  placement: "AI decides optimal placement"
  instruction: "Place this bonus character (e.g., chibi version) somewhere in the infographic as a decorative element"

"""
    }

    /// セクションテキスト（YAML形式）を生成
    private func generateSectionsText(settings: InfographicSettingsViewModel) -> String {
        var text = ""

        for (index, section) in settings.sections.enumerated() {
            guard !section.title.isEmpty else { continue }

            let sectionNumber = index + 1
            let content = YAMLUtilities.convertNewlinesToComma(section.content)

            text += """

  - section_\(sectionNumber):
      title: "\(YAMLUtilities.escapeYAMLString(section.title))"
      content: "\(content)"
"""
        }

        return text
    }

    /// セクションリスト（プロンプト用）を生成
    private func generateSectionsList(settings: InfographicSettingsViewModel) -> String {
        var lines: [String] = []

        for section in settings.sections where !section.title.isEmpty {
            let content = YAMLUtilities.convertNewlinesToComma(section.content)
            lines.append("  - \(section.title): \(content)")
        }

        return lines.joined(separator: "\n")
    }
}
