import Foundation

/// テンプレートパーサー
/// YAMLファイルの読み込みとテンプレート構文の解析を担当
final class TemplateParser {

    // MARK: - Simple YAML Parsing

    /// セクションテンプレートを抽出
    /// YAMLファイルから指定されたセクションのtemplateフィールドを抽出
    func extractSectionTemplate(from yamlString: String, outputType: String, sectionName: String) -> String? {
        // セクションを探す
        let lines = yamlString.components(separatedBy: "\n")
        var inOutputType = false
        var inSection = false
        var inTemplate = false
        var templateLines: [String] = []
        var templateIndent = 0

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // output_types セクション内の特定タイプを探す
            if trimmedLine == "\(outputType):" {
                inOutputType = true
                continue
            }

            if inOutputType {
                // 次の出力タイプに到達したら終了
                if !line.hasPrefix(" ") && !line.hasPrefix("\t") && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                    if !trimmedLine.hasPrefix(outputType) {
                        inOutputType = false
                        continue
                    }
                }

                // セクション名を探す
                if trimmedLine == "\(sectionName):" {
                    inSection = true
                    continue
                }

                if inSection {
                    // template: フィールドを探す
                    if trimmedLine.hasPrefix("template:") {
                        inTemplate = true
                        // template: | の場合
                        if trimmedLine.contains("|") {
                            continue
                        }
                        // インラインテンプレートの場合
                        if let range = trimmedLine.range(of: "template:") {
                            let value = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                            if !value.isEmpty && value != "|" {
                                return value
                            }
                        }
                        continue
                    }

                    if inTemplate {
                        // インデントを計算
                        let currentIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

                        if templateIndent == 0 && !trimmedLine.isEmpty {
                            templateIndent = currentIndent
                        }

                        // インデントが減ったらテンプレート終了
                        if currentIndent < templateIndent && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                            break
                        }

                        // テンプレート行を追加（先頭のインデントを除去）
                        if currentIndent >= templateIndent {
                            let content = String(line.dropFirst(templateIndent))
                            templateLines.append(content)
                        } else if trimmedLine.isEmpty {
                            templateLines.append("")
                        }
                    }

                    // 次のセクションに到達したら終了
                    if !inTemplate && !trimmedLine.isEmpty && trimmedLine.hasSuffix(":") && !trimmedLine.hasPrefix("#") {
                        break
                    }
                }
            }
        }

        return templateLines.isEmpty ? nil : templateLines.joined(separator: "\n")
    }

    /// 共通セクションテンプレートを抽出
    func extractCommonSectionTemplate(from yamlString: String, sectionName: String) -> String? {
        let lines = yamlString.components(separatedBy: "\n")
        var inCommonSections = false
        var inSection = false
        var inTemplate = false
        var templateLines: [String] = []
        var templateIndent = 0

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // common_sections を探す
            if trimmedLine == "common_sections:" {
                inCommonSections = true
                continue
            }

            // output_types に到達したら終了
            if trimmedLine == "output_types:" {
                break
            }

            if inCommonSections {
                // セクション名を探す
                if trimmedLine == "\(sectionName):" {
                    inSection = true
                    continue
                }

                if inSection {
                    // template: フィールドを探す
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

                    // descriptionフィールドは無視
                    if trimmedLine.hasPrefix("description:") {
                        continue
                    }

                    // 次のセクションに到達したら終了
                    if !inTemplate && !trimmedLine.isEmpty && trimmedLine.hasSuffix(":") &&
                       !trimmedLine.hasPrefix("#") && !trimmedLine.hasPrefix("description") {
                        break
                    }
                }
            }
        }

        return templateLines.isEmpty ? nil : templateLines.joined(separator: "\n")
    }

    /// header_values を抽出
    func extractHeaderValues(from yamlString: String, outputType: String) -> [String: String] {
        var values: [String: String] = [:]
        let lines = yamlString.components(separatedBy: "\n")
        var inOutputType = false
        var inHeaderValues = false

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine == "\(outputType):" {
                inOutputType = true
                continue
            }

            if inOutputType {
                if trimmedLine == "header_values:" {
                    inHeaderValues = true
                    continue
                }

                if inHeaderValues {
                    // キー: 値 の形式を解析
                    if let colonIndex = trimmedLine.firstIndex(of: ":") {
                        let key = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        var value = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)

                        // クォートを除去
                        if value.hasPrefix("\"") && value.hasSuffix("\"") {
                            value = String(value.dropFirst().dropLast())
                        }

                        if !key.isEmpty && !key.hasPrefix("#") {
                            values[key] = value
                        }
                    }

                    // 次のフィールドに到達したら終了
                    if trimmedLine.hasSuffix(":") && !trimmedLine.contains(" ") {
                        break
                    }
                }

                // 次の出力タイプに到達したら終了
                if !line.hasPrefix(" ") && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                    break
                }
            }
        }

        return values
    }

    /// selection_map からセクションリストを抽出
    func extractSectionList(from yamlString: String, selectionKey: String) -> [String] {
        var sections: [String] = []
        let lines = yamlString.components(separatedBy: "\n")
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
                        // - section_name 形式を解析
                        if trimmedLine.hasPrefix("- ") {
                            var sectionName = String(trimmedLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                            // コメントを除去
                            if let commentIndex = sectionName.firstIndex(of: "#") {
                                sectionName = String(sectionName[..<commentIndex]).trimmingCharacters(in: .whitespaces)
                            }
                            if !sectionName.isEmpty {
                                sections.append(sectionName)
                            }
                        } else if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                            // 次のフィールドに到達したら終了
                            break
                        }
                    }

                    // 次の選択に到達したら終了
                    if !line.hasPrefix(" ") && !line.hasPrefix("\t") && !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                        break
                    }
                }
            }
        }

        return sections
    }

    // MARK: - Template Syntax Parsing

    /// テンプレート文字列をASTに変換
    func parseTemplate(_ template: String) throws -> [TemplateNode] {
        var nodes: [TemplateNode] = []
        var currentIndex = template.startIndex
        let endIndex = template.endIndex

        while currentIndex < endIndex {
            // 次の {{ を探す
            if let openRange = template.range(of: "{{", range: currentIndex..<endIndex) {
                // {{ の前のテキストを追加
                if currentIndex < openRange.lowerBound {
                    let text = String(template[currentIndex..<openRange.lowerBound])
                    if !text.isEmpty {
                        nodes.append(.text(text))
                    }
                }

                // }} を探す
                guard let closeRange = template.range(of: "}}", range: openRange.upperBound..<endIndex) else {
                    throw TemplateEngineError.parseError("Unclosed {{ tag", line: nil)
                }

                let tagContent = String(template[openRange.upperBound..<closeRange.lowerBound]).trimmingCharacters(in: .whitespaces)

                // タグの種類を判定
                if tagContent.hasPrefix("#if ") {
                    // 条件分岐開始
                    let condition = String(tagContent.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                    let (conditionNode, newIndex) = try parseCondition(
                        template: template,
                        startIndex: closeRange.upperBound,
                        condition: condition,
                        isNegated: false
                    )
                    nodes.append(.condition(conditionNode))
                    currentIndex = newIndex
                } else if tagContent.hasPrefix("#unless ") {
                    // 否定条件分岐開始
                    let condition = String(tagContent.dropFirst(8)).trimmingCharacters(in: .whitespaces)
                    let (conditionNode, newIndex) = try parseCondition(
                        template: template,
                        startIndex: closeRange.upperBound,
                        condition: condition,
                        isNegated: true
                    )
                    nodes.append(.condition(conditionNode))
                    currentIndex = newIndex
                } else if tagContent.hasPrefix("#each ") {
                    // ループ開始
                    let arrayName = String(tagContent.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    let (loopNode, newIndex) = try parseLoop(
                        template: template,
                        startIndex: closeRange.upperBound,
                        arrayName: arrayName
                    )
                    nodes.append(.loop(loopNode))
                    currentIndex = newIndex
                } else if tagContent.hasPrefix("!") {
                    // コメント
                    let comment = String(tagContent.dropFirst(1)).trimmingCharacters(in: .whitespaces)
                    nodes.append(.comment(comment))
                    currentIndex = closeRange.upperBound
                } else if tagContent.hasPrefix("{") && tagContent.hasSuffix("}") {
                    // 生テキスト変数 {{{variable}}}
                    let variable = String(tagContent.dropFirst(1).dropLast(1)).trimmingCharacters(in: .whitespaces)
                    nodes.append(.rawVariable(variable))
                    currentIndex = closeRange.upperBound
                } else if !tagContent.hasPrefix("/") && !tagContent.hasPrefix("else") {
                    // 通常の変数
                    nodes.append(.variable(tagContent))
                    currentIndex = closeRange.upperBound
                } else {
                    // 終了タグなど（ここには来ないはず）
                    currentIndex = closeRange.upperBound
                }
            } else {
                // {{ がない場合、残りのテキストを追加
                let text = String(template[currentIndex..<endIndex])
                if !text.isEmpty {
                    nodes.append(.text(text))
                }
                break
            }
        }

        return nodes
    }

    // MARK: - Private Methods

    /// 条件分岐を解析
    private func parseCondition(
        template: String,
        startIndex: String.Index,
        condition: String,
        isNegated: Bool
    ) throws -> (ConditionNode, String.Index) {
        var thenContent = ""
        var elseContent: String? = nil
        var currentIndex = startIndex
        let endIndex = template.endIndex
        var depth = 1

        // {{/if}} または {{else}} を探す
        while currentIndex < endIndex && depth > 0 {
            if let openRange = template.range(of: "{{", range: currentIndex..<endIndex) {
                guard let closeRange = template.range(of: "}}", range: openRange.upperBound..<endIndex) else {
                    throw TemplateEngineError.parseError("Unclosed {{ tag in condition", line: nil)
                }

                let tagContent = String(template[openRange.upperBound..<closeRange.lowerBound]).trimmingCharacters(in: .whitespaces)

                if tagContent.hasPrefix("#if ") || tagContent.hasPrefix("#unless ") {
                    // ネストされた条件
                    depth += 1
                    if elseContent == nil {
                        thenContent += String(template[currentIndex..<closeRange.upperBound])
                    } else {
                        elseContent! += String(template[currentIndex..<closeRange.upperBound])
                    }
                    currentIndex = closeRange.upperBound
                } else if tagContent == "/if" {
                    depth -= 1
                    if depth == 0 {
                        // 条件分岐終了
                        if elseContent == nil {
                            thenContent += String(template[currentIndex..<openRange.lowerBound])
                        } else {
                            elseContent! += String(template[currentIndex..<openRange.lowerBound])
                        }
                        currentIndex = closeRange.upperBound
                    } else {
                        if elseContent == nil {
                            thenContent += String(template[currentIndex..<closeRange.upperBound])
                        } else {
                            elseContent! += String(template[currentIndex..<closeRange.upperBound])
                        }
                        currentIndex = closeRange.upperBound
                    }
                } else if tagContent == "else" && depth == 1 {
                    // else節
                    thenContent += String(template[currentIndex..<openRange.lowerBound])
                    elseContent = ""
                    currentIndex = closeRange.upperBound
                } else {
                    // その他のタグ
                    if elseContent == nil {
                        thenContent += String(template[currentIndex..<closeRange.upperBound])
                    } else {
                        elseContent! += String(template[currentIndex..<closeRange.upperBound])
                    }
                    currentIndex = closeRange.upperBound
                }
            } else {
                // {{ がない場合
                if elseContent == nil {
                    thenContent += String(template[currentIndex..<endIndex])
                } else {
                    elseContent! += String(template[currentIndex..<endIndex])
                }
                break
            }
        }

        if depth > 0 {
            throw TemplateEngineError.parseError("Unclosed #if block", line: nil)
        }

        // 再帰的に内部をパース
        let thenNodes = try parseTemplate(thenContent)
        let elseNodes = elseContent != nil ? try parseTemplate(elseContent!) : nil

        let node = ConditionNode(
            condition: condition,
            isNegated: isNegated,
            thenBranch: thenNodes,
            elseBranch: elseNodes
        )

        return (node, currentIndex)
    }

    /// ループを解析
    private func parseLoop(
        template: String,
        startIndex: String.Index,
        arrayName: String
    ) throws -> (LoopNode, String.Index) {
        var loopContent = ""
        var currentIndex = startIndex
        let endIndex = template.endIndex
        var depth = 1

        // {{/each}} を探す
        while currentIndex < endIndex && depth > 0 {
            if let openRange = template.range(of: "{{", range: currentIndex..<endIndex) {
                guard let closeRange = template.range(of: "}}", range: openRange.upperBound..<endIndex) else {
                    throw TemplateEngineError.parseError("Unclosed {{ tag in loop", line: nil)
                }

                let tagContent = String(template[openRange.upperBound..<closeRange.lowerBound]).trimmingCharacters(in: .whitespaces)

                if tagContent.hasPrefix("#each ") {
                    // ネストされたループ
                    depth += 1
                    loopContent += String(template[currentIndex..<closeRange.upperBound])
                    currentIndex = closeRange.upperBound
                } else if tagContent == "/each" {
                    depth -= 1
                    if depth == 0 {
                        // ループ終了
                        loopContent += String(template[currentIndex..<openRange.lowerBound])
                        currentIndex = closeRange.upperBound
                    } else {
                        loopContent += String(template[currentIndex..<closeRange.upperBound])
                        currentIndex = closeRange.upperBound
                    }
                } else {
                    loopContent += String(template[currentIndex..<closeRange.upperBound])
                    currentIndex = closeRange.upperBound
                }
            } else {
                loopContent += String(template[currentIndex..<endIndex])
                break
            }
        }

        if depth > 0 {
            throw TemplateEngineError.parseError("Unclosed #each block", line: nil)
        }

        // 再帰的に内部をパース
        let bodyNodes = try parseTemplate(loopContent)

        let node = LoopNode(
            arrayName: arrayName,
            body: bodyNodes
        )

        return (node, currentIndex)
    }
}
