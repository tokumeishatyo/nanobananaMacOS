#!/usr/bin/env swift

import Foundation

// ============================================================
// Simple Template Engine Test Script
// ============================================================
// This script tests the MasterTemplate.yaml by generating YAML output
// Usage: swift test_template_engine.swift
// ============================================================

// MARK: - Template Variables

struct TemplateVariables {
    private var values: [String: Any] = [:]

    mutating func set(_ key: String, _ value: String) {
        values[key] = value
    }

    mutating func set(_ key: String, _ value: Bool) {
        values[key] = value
    }

    func getString(_ key: String) -> String? {
        return values[key] as? String
    }

    func exists(_ key: String) -> Bool {
        if let str = values[key] as? String, !str.isEmpty {
            return true
        }
        if let bool = values[key] as? Bool {
            return bool
        }
        return false
    }
}

// MARK: - Simple Template Parser

class SimpleTemplateParser {

    /// Extract section template from master template
    func extractSectionTemplate(from yaml: String, outputType: String, sectionName: String) -> String? {
        let lines = yaml.components(separatedBy: "\n")
        var inOutputType = false
        var inSection = false
        var inTemplate = false
        var templateLines: [String] = []
        var templateIndent = 0
        var outputTypeIndent = 0

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let currentIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            // Find the output type
            if trimmedLine == "\(outputType):" {
                inOutputType = true
                outputTypeIndent = currentIndent
                continue
            }

            if inOutputType {
                // Check for next output type (same indent level, different name)
                if currentIndent == outputTypeIndent && !trimmedLine.isEmpty &&
                   trimmedLine.hasSuffix(":") && !trimmedLine.hasPrefix("#") &&
                   trimmedLine != "\(outputType):" {
                    break
                }

                // Check for top-level key
                if currentIndent == 0 && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                    break
                }

                // Find section name (not while in template)
                if !inTemplate && trimmedLine == "\(sectionName):" {
                    inSection = true
                    continue
                }

                if inSection {
                    // Find template: field
                    if trimmedLine.hasPrefix("template:") {
                        inTemplate = true
                        if trimmedLine.contains("|") {
                            continue
                        }
                        continue
                    }

                    if inTemplate {
                        if templateIndent == 0 && !trimmedLine.isEmpty {
                            templateIndent = currentIndent
                        }

                        // End of template (indent decreased)
                        if currentIndent < templateIndent && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                            break
                        }

                        if currentIndent >= templateIndent {
                            let content = String(line.dropFirst(templateIndent))
                            templateLines.append(content)
                        } else if trimmedLine.isEmpty {
                            templateLines.append("")
                        }
                    }

                    // Next section
                    if !inTemplate && !trimmedLine.isEmpty && trimmedLine.hasSuffix(":") && !trimmedLine.hasPrefix("#") {
                        break
                    }
                }
            }
        }

        return templateLines.isEmpty ? nil : templateLines.joined(separator: "\n")
    }

    /// Extract common section template
    func extractCommonSectionTemplate(from yaml: String, sectionName: String) -> String? {
        let lines = yaml.components(separatedBy: "\n")
        var inCommonSections = false
        var inSection = false
        var inTemplate = false
        var templateLines: [String] = []
        var templateIndent = 0

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine == "common_sections:" {
                inCommonSections = true
                continue
            }

            if trimmedLine == "output_types:" {
                break
            }

            if inCommonSections {
                if !inTemplate && trimmedLine == "\(sectionName):" {
                    inSection = true
                    continue
                }

                if inSection {
                    if trimmedLine.hasPrefix("template:") {
                        inTemplate = true
                        if trimmedLine.contains("|") {
                            continue
                        }
                        continue
                    }

                    if inTemplate {
                        let currentIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

                        if templateIndent == 0 && !trimmedLine.isEmpty {
                            templateIndent = currentIndent
                        }

                        if currentIndent < templateIndent && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                            break
                        }

                        if currentIndent >= templateIndent {
                            let content = String(line.dropFirst(templateIndent))
                            templateLines.append(content)
                        } else if trimmedLine.isEmpty {
                            templateLines.append("")
                        }
                    }

                    if trimmedLine.hasPrefix("description:") {
                        continue
                    }

                    if !inTemplate && !trimmedLine.isEmpty && trimmedLine.hasSuffix(":") &&
                       !trimmedLine.hasPrefix("#") && !trimmedLine.hasPrefix("description") {
                        break
                    }
                }
            }
        }

        return templateLines.isEmpty ? nil : templateLines.joined(separator: "\n")
    }

    /// Extract header values
    func extractHeaderValues(from yaml: String, outputType: String) -> [String: String] {
        var values: [String: String] = [:]
        let lines = yaml.components(separatedBy: "\n")
        var inOutputType = false
        var inHeaderValues = false
        var outputTypeIndent = 0

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            let currentIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

            if trimmedLine == "\(outputType):" {
                inOutputType = true
                outputTypeIndent = currentIndent
                continue
            }

            if inOutputType {
                // Check for next output type
                if currentIndent == outputTypeIndent && !trimmedLine.isEmpty &&
                   trimmedLine.hasSuffix(":") && !trimmedLine.hasPrefix("#") &&
                   trimmedLine != "\(outputType):" {
                    break
                }

                if trimmedLine == "header_values:" {
                    inHeaderValues = true
                    continue
                }

                if inHeaderValues {
                    if let colonIndex = trimmedLine.firstIndex(of: ":") {
                        let key = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        var value = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)

                        // Remove quotes
                        if value.hasPrefix("\"") && value.hasSuffix("\"") {
                            value = String(value.dropFirst().dropLast())
                        }

                        if !key.isEmpty && !key.hasPrefix("#") {
                            values[key] = value
                        }
                    }

                    // End of header_values
                    if trimmedLine.hasSuffix(":") && !trimmedLine.contains(" ") && trimmedLine != "header_values:" {
                        break
                    }
                }
            }
        }

        return values
    }

    /// Extract section list from selection map
    func extractSectionList(from yaml: String, selectionKey: String) -> [String] {
        var sections: [String] = []
        let lines = yaml.components(separatedBy: "\n")
        var inSelectionMap = false
        var inSelection = false
        var inSections = false

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine == "selection_map:" {
                inSelectionMap = true
                continue
            }

            if inSelectionMap {
                if trimmedLine == "\(selectionKey):" {
                    inSelection = true
                    continue
                }

                if inSelection {
                    if trimmedLine == "sections:" {
                        inSections = true
                        continue
                    }

                    if inSections {
                        if trimmedLine.hasPrefix("- ") {
                            var sectionName = String(trimmedLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                            // Remove comments
                            if let commentIndex = sectionName.firstIndex(of: "#") {
                                sectionName = String(sectionName[..<commentIndex]).trimmingCharacters(in: .whitespaces)
                            }
                            if !sectionName.isEmpty {
                                sections.append(sectionName)
                            }
                        } else if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                            break
                        }
                    }

                    // Next selection
                    if !line.hasPrefix(" ") && !line.hasPrefix("\t") && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                        break
                    }
                }
            }
        }

        return sections
    }
}

// MARK: - Simple Renderer

class SimpleRenderer {

    func render(template: String, variables: TemplateVariables) -> String {
        var result = template

        // Process {{#if condition}}...{{/if}} blocks
        result = processConditionals(result, variables: variables)

        // Process {{! comment }} - remove them
        let commentPattern = #"\{\{!.*?\}\}"#
        if let regex = try? NSRegularExpression(pattern: commentPattern, options: [.dotMatchesLineSeparators]) {
            result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(result.startIndex..., in: result), withTemplate: "")
        }

        // Process {{variable}} substitutions
        let varPattern = #"\{\{(\w+)\}\}"#
        if let regex = try? NSRegularExpression(pattern: varPattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))

            for match in matches.reversed() {
                guard let varRange = Range(match.range(at: 1), in: result),
                      let fullRange = Range(match.range, in: result) else { continue }

                let varName = String(result[varRange])
                let value = variables.getString(varName) ?? ""
                result.replaceSubrange(fullRange, with: value)
            }
        }

        return result
    }

    private func processConditionals(_ template: String, variables: TemplateVariables) -> String {
        var result = template

        // Simple {{#if var}}...{{/if}} pattern (non-nested)
        let ifPattern = #"\{\{#if\s+(\w+)\}\}([\s\S]*?)\{\{/if\}\}"#

        while let regex = try? NSRegularExpression(pattern: ifPattern, options: []),
              let match = regex.firstMatch(in: result, options: [], range: NSRange(result.startIndex..., in: result)) {

            guard let varRange = Range(match.range(at: 1), in: result),
                  let contentRange = Range(match.range(at: 2), in: result),
                  let fullRange = Range(match.range, in: result) else { break }

            let varName = String(result[varRange])
            let content = String(result[contentRange])

            if variables.exists(varName) {
                result.replaceSubrange(fullRange, with: content)
            } else {
                result.replaceSubrange(fullRange, with: "")
            }
        }

        return result
    }
}

// MARK: - Test Data

func createTestVariables() -> TemplateVariables {
    var vars = TemplateVariables()

    // Common variables
    vars.set("title", "テスト顔三面図")
    vars.set("author", "テスト作者")
    vars.set("type", "character_design")
    vars.set("color_mode", "fullcolor")
    vars.set("output_style", "anime")
    vars.set("aspect_ratio", "1:1")
    vars.set("is_duotone", false)
    vars.set("title_overlay_enabled", false)

    // Header values (will be added from template)
    vars.set("header_title_ja", "顔三面図")
    vars.set("header_title_en", "Face Character Reference Sheet")

    // Face sheet specific
    vars.set("character_name", "テストキャラ")
    vars.set("character_description", "テスト用キャラクターの説明文")
    vars.set("expression", "neutral expression")
    vars.set("reference_image_path", "test_reference.png")

    // Style info
    vars.set("style_info_style", "日本のアニメスタイル, 2Dセルシェーディング")
    vars.set("style_info_proportions", "Normal head-to-body ratio (6-7 heads)")
    vars.set("style_info_description", "High quality anime illustration")

    return vars
}

// MARK: - Main

func main() {
    let masterTemplatePath = "nanobananaMacOS/Resources/Templates/MasterTemplate.yaml"
    let selectionMapPath = "nanobananaMacOS/Resources/Templates/SelectionMap.yaml"

    // Read templates
    guard let masterTemplate = try? String(contentsOfFile: masterTemplatePath, encoding: .utf8) else {
        print("Error: Cannot read MasterTemplate.yaml")
        return
    }

    guard let selectionMap = try? String(contentsOfFile: selectionMapPath, encoding: .utf8) else {
        print("Error: Cannot read SelectionMap.yaml")
        return
    }

    let parser = SimpleTemplateParser()
    let renderer = SimpleRenderer()

    // Get section list for face_sheet
    let sections = parser.extractSectionList(from: selectionMap, selectionKey: "face_sheet")
    print("=== Sections for face_sheet ===")
    for (i, section) in sections.enumerated() {
        print("\(i + 1). \(section)")
    }
    print("")

    // Get header values
    let headerValues = parser.extractHeaderValues(from: masterTemplate, outputType: "face_sheet")
    print("=== Header values ===")
    for (key, value) in headerValues {
        print("\(key): \(value)")
    }
    print("")

    // Create variables
    var variables = createTestVariables()

    // Add header values to variables
    for (key, value) in headerValues {
        variables.set(key, value)
    }

    // Generate YAML
    var yamlParts: [String] = []

    for sectionName in sections {
        // Try output type specific section first
        if let template = parser.extractSectionTemplate(from: masterTemplate, outputType: "face_sheet", sectionName: sectionName) {
            let rendered = renderer.render(template: template, variables: variables)
            if !rendered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                yamlParts.append(rendered)
            }
        }
        // Try common section
        else if let template = parser.extractCommonSectionTemplate(from: masterTemplate, sectionName: sectionName) {
            let rendered = renderer.render(template: template, variables: variables)
            if !rendered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                yamlParts.append(rendered)
            }
        }
        else {
            // Optional sections are OK to be missing
            let optionalSections = ["title_overlay", "reference_image", "bonus_character"]
            if !optionalSections.contains(sectionName) {
                print("Warning: Section '\(sectionName)' not found")
            }
        }
    }

    let finalYAML = yamlParts.joined(separator: "\n")

    // Output
    print("=== Generated YAML ===")
    print(finalYAML)

    // Save to file
    let outputDir = "templatetest"
    let outputPath = "\(outputDir)/01_face_sheet_template.yaml"

    // Create directory if needed
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: outputDir) {
        try? fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
    }

    do {
        try finalYAML.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print("\n=== Saved to \(outputPath) ===")
    } catch {
        print("Error saving file: \(error)")
    }
}

main()
