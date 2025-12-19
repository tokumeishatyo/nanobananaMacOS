import Foundation

/// セクションレンダラー
/// テンプレートASTと変数から文字列を生成
final class SectionRenderer {

    private let parser: TemplateParser

    init(parser: TemplateParser = TemplateParser()) {
        self.parser = parser
    }

    // MARK: - Public Methods

    /// テンプレート文字列を変数で置換してレンダリング
    func render(template: String, variables: TemplateVariables) throws -> String {
        let nodes = try parser.parseTemplate(template)
        return try renderNodes(nodes, variables: variables)
    }

    // MARK: - Private Methods

    /// ノード配列をレンダリング
    private func renderNodes(_ nodes: [TemplateNode], variables: TemplateVariables) throws -> String {
        var result = ""

        for node in nodes {
            switch node {
            case .text(let text):
                result += text

            case .variable(let name):
                result += resolveVariable(name, variables: variables)

            case .rawVariable(let name):
                result += resolveVariable(name, variables: variables)

            case .condition(let conditionNode):
                result += try renderCondition(conditionNode, variables: variables)

            case .loop(let loopNode):
                result += try renderLoop(loopNode, variables: variables)

            case .comment:
                // コメントは出力しない
                break
            }
        }

        return result
    }

    /// 変数を解決
    private func resolveVariable(_ name: String, variables: TemplateVariables) -> String {
        // 特殊変数のチェック
        if name == "@index" || name == "@index_1" {
            // ループ内でのみ使用可能（ループコンテキストで処理）
            return ""
        }

        // 通常の変数
        if let value = variables.getString(name) {
            return value
        }

        // Bool値の場合
        if let value = variables.get(name) as? Bool {
            return value ? "true" : "false"
        }

        // 数値の場合
        if let value = variables.get(name) as? Int {
            return String(value)
        }

        // 見つからない場合は空文字列
        return ""
    }

    /// 条件分岐をレンダリング
    private func renderCondition(_ node: ConditionNode, variables: TemplateVariables) throws -> String {
        let conditionResult = evaluateCondition(node.condition, variables: variables)

        // isNegated の場合は結果を反転
        let finalResult = node.isNegated ? !conditionResult : conditionResult

        if finalResult {
            return try renderNodes(node.thenBranch, variables: variables)
        } else if let elseBranch = node.elseBranch {
            return try renderNodes(elseBranch, variables: variables)
        }

        return ""
    }

    /// 条件を評価
    private func evaluateCondition(_ condition: String, variables: TemplateVariables) -> Bool {
        // 単純な変数名の場合
        return variables.exists(condition)
    }

    /// ループをレンダリング
    private func renderLoop(_ node: LoopNode, variables: TemplateVariables) throws -> String {
        guard let array = variables.getArray(node.arrayName) else {
            return ""
        }

        var result = ""

        for (index, item) in array.enumerated() {
            // ループ用の変数コンテキストを作成
            var loopVariables = variables

            // 配列要素の各フィールドを直接アクセス可能にする
            for (key, value) in item {
                if let stringValue = value as? String {
                    loopVariables.set(key, stringValue)
                } else if let boolValue = value as? Bool {
                    loopVariables.set(key, boolValue)
                } else if let intValue = value as? Int {
                    loopVariables.set(key, String(intValue))
                }
            }

            // インデックス変数を設定
            loopVariables.set("@index", String(index))
            loopVariables.set("@index_1", String(index + 1))

            // ループ本体をレンダリング
            result += try renderNodes(node.body, variables: loopVariables)
        }

        return result
    }
}

// MARK: - Convenience Extensions

extension SectionRenderer {

    /// 簡易レンダリング（パース済みテンプレートなし）
    func renderSimple(template: String, substitutions: [String: String]) -> String {
        var result = template

        for (key, value) in substitutions {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }

        return result
    }

    /// 条件付き行を処理（簡易版）
    /// {{#if variable}}...{{/if}} パターンを処理
    func processConditionalLines(in template: String, variables: TemplateVariables) -> String {
        var result = template

        // {{#if variable}}...{{/if}} パターンを処理
        let ifPattern = #"\{\{#if\s+(\w+)\}\}([\s\S]*?)\{\{/if\}\}"#

        if let regex = try? NSRegularExpression(pattern: ifPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, options: [], range: range)

            // 逆順で処理（置換による位置ずれを防ぐ）
            for match in matches.reversed() {
                guard let variableRange = Range(match.range(at: 1), in: result),
                      let contentRange = Range(match.range(at: 0), in: result),
                      let innerRange = Range(match.range(at: 2), in: result) else {
                    continue
                }

                let variableName = String(result[variableRange])
                let innerContent = String(result[innerRange])

                if variables.exists(variableName) {
                    // 条件が真の場合は内部コンテンツで置換
                    result.replaceSubrange(contentRange, with: innerContent)
                } else {
                    // 条件が偽の場合は空で置換
                    result.replaceSubrange(contentRange, with: "")
                }
            }
        }

        return result
    }
}
