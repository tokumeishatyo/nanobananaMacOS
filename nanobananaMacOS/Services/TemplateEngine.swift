// rule.mdを読むこと
import Foundation

// MARK: - Template Engine

/// テンプレートエンジン
/// yaml_templatesフォルダからテンプレートを読み込み、変数を置換してYAMLを生成
final class TemplateEngine {

    // MARK: - Properties

    /// テンプレートディレクトリのURL
    private let templatesDirectory: URL?

    /// パーシャル参照のパターン: {{> partial_name key="value" key2="value2"}}
    private let partialPattern = try! NSRegularExpression(
        pattern: #"\{\{>\s*(\w+)([^}]*)\}\}"#,
        options: []
    )

    /// パーシャルパラメータのパターン: key="value"
    private let paramPattern = try! NSRegularExpression(
        pattern: #"(\w+)=\"([^\"]*)\""#,
        options: []
    )

    /// 変数参照のパターン: {{variable_name}}
    private let variablePattern = try! NSRegularExpression(
        pattern: #"\{\{(\w+)\}\}"#,
        options: []
    )

    // MARK: - Initialization

    init() {
        self.templatesDirectory = Self.findTemplatesDirectory()
        #if DEBUG
        if templatesDirectory == nil {
            print("[TemplateEngine] Warning: Templates directory not found")
        }
        #endif
    }

    // MARK: - Public Methods

    /// テンプレートを読み込んで変数を置換
    /// - Parameters:
    ///   - templateName: テンプレートファイル名（例: "01_face_sheet.yaml"）
    ///   - variables: 置換する変数の辞書
    /// - Returns: 生成されたYAML文字列
    func render(templateName: String, variables: [String: String]) -> String {
        // 1. テンプレートファイルを読み込む
        guard let template = loadTemplate(templateName) else {
            return generateErrorYAML(message: "Template not found: \(templateName)")
        }

        // 2. パーシャルを展開（再帰的に処理）
        let expanded = expandPartials(template, variables: variables)

        // 3. 変数を置換
        let replaced = replaceVariables(expanded, variables: variables)

        // 4. 空白値フィールドを削除
        let result = cleanupEmptyFields(replaced)

        return result
    }

    /// 利用可能なテンプレート一覧を取得
    func listTemplates() -> [String] {
        guard let directory = templatesDirectory else { return [] }
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )
            return files
                .filter { $0.pathExtension == "yaml" }
                .map { $0.lastPathComponent }
                .sorted()
        } catch {
            #if DEBUG
            print("[TemplateEngine] Error listing templates: \(error)")
            #endif
            return []
        }
    }

    // MARK: - Private Methods

    /// テンプレートファイルを読み込む
    private func loadTemplate(_ name: String) -> String? {
        // 1. バンドルから直接検索（リリース時・ファイルがフラットにコピーされる場合）
        let baseName = (name as NSString).deletingPathExtension
        if let bundleURL = Bundle.main.url(forResource: baseName, withExtension: "yaml") {
            return try? String(contentsOf: bundleURL, encoding: .utf8)
        }

        // 2. テンプレートディレクトリから検索（開発時）
        if let directory = templatesDirectory {
            let url = directory.appendingPathComponent(name)
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                return content
            }
        }

        return nil
    }

    /// パーシャルを展開（{{> partial_name key="value"}}）
    private func expandPartials(_ template: String, variables: [String: String]) -> String {
        var result = template
        var iterations = 0
        let maxIterations = 10 // ネスト深度の上限

        // パーシャルがなくなるまで繰り返し展開
        while iterations < maxIterations {
            let range = NSRange(result.startIndex..., in: result)
            let matches = partialPattern.matches(in: result, options: [], range: range)

            if matches.isEmpty { break }

            // 後ろから置換（インデックスずれ防止）
            for match in matches.reversed() {
                guard let partialNameRange = Range(match.range(at: 1), in: result),
                      let paramsRange = Range(match.range(at: 2), in: result),
                      let fullRange = Range(match.range, in: result) else {
                    continue
                }

                let partialName = String(result[partialNameRange])
                let paramsString = String(result[paramsRange])

                // パラメータをパース
                let params = parsePartialParams(paramsString)

                // パーシャルファイルを読み込み
                if let partialContent = loadTemplate("\(partialName).yaml") {
                    // パラメータと既存変数をマージ（パラメータ優先）
                    var mergedVariables = variables
                    for (key, value) in params {
                        mergedVariables[key] = value
                    }

                    // パーシャル内の変数を置換
                    let expandedPartial = replaceVariables(partialContent, variables: mergedVariables)
                    result.replaceSubrange(fullRange, with: expandedPartial)
                } else {
                    // パーシャルが見つからない場合はコメントに置換
                    result.replaceSubrange(fullRange, with: "# Partial not found: \(partialName)")
                }
            }

            iterations += 1
        }

        return result
    }

    /// パーシャルのパラメータをパース（key="value" key2="value2"）
    private func parsePartialParams(_ paramsString: String) -> [String: String] {
        var params: [String: String] = [:]
        let range = NSRange(paramsString.startIndex..., in: paramsString)
        let matches = paramPattern.matches(in: paramsString, options: [], range: range)

        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: paramsString),
                  let valueRange = Range(match.range(at: 2), in: paramsString) else {
                continue
            }
            let key = String(paramsString[keyRange])
            let value = String(paramsString[valueRange])
            params[key] = value
        }

        return params
    }

    /// 変数を置換（{{variable_name}}）
    private func replaceVariables(_ template: String, variables: [String: String]) -> String {
        var result = template
        let range = NSRange(result.startIndex..., in: result)
        let matches = variablePattern.matches(in: result, options: [], range: range)

        // 後ろから置換（インデックスずれ防止）
        for match in matches.reversed() {
            guard let variableNameRange = Range(match.range(at: 1), in: result),
                  let fullRange = Range(match.range, in: result) else {
                continue
            }

            let variableName = String(result[variableNameRange])

            // 変数が定義されていれば置換、なければそのまま残す
            if let value = variables[variableName] {
                result.replaceSubrange(fullRange, with: value)
            }
            // 未定義変数はそのまま残す（デバッグ用）
        }

        return result
    }

    /// 空白値フィールドを削除
    /// - `key: ""` のような行を削除
    /// - 子要素がすべて削除されたセクションも削除
    private func cleanupEmptyFields(_ yaml: String) -> String {
        let lines = yaml.components(separatedBy: "\n")
        var result: [String] = []
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // 空の値を持つ行をスキップ（key: "" または key: ''）
            if isEmptyValueLine(line) {
                i += 1
                continue
            }

            // セクションヘッダー（子要素を持つ可能性がある行）をチェック
            if isSectionHeader(line, nextLine: i + 1 < lines.count ? lines[i + 1] : nil) {
                // このセクションに有効な子要素があるかチェック
                let sectionIndent = getIndent(line)
                var hasValidChildren = false
                var j = i + 1

                while j < lines.count {
                    let childLine = lines[j]
                    let childIndent = getIndent(childLine)

                    // 空行やコメント行はスキップ
                    if childLine.trimmingCharacters(in: .whitespaces).isEmpty ||
                       childLine.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                        j += 1
                        continue
                    }

                    // インデントが戻ったらセクション終了
                    if childIndent <= sectionIndent {
                        break
                    }

                    // 空でない値を持つ子要素があるかチェック
                    if !isEmptyValueLine(childLine) {
                        hasValidChildren = true
                        break
                    }
                    j += 1
                }

                // 有効な子要素がない場合、このセクションヘッダーをスキップ
                if !hasValidChildren {
                    i += 1
                    continue
                }
            }

            result.append(line)
            i += 1
        }

        // 連続する空行を1つにまとめる
        return consolidateEmptyLines(result.joined(separator: "\n"))
    }

    /// 空の値を持つ行かどうかをチェック
    private func isEmptyValueLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        // key: "" または key: '' のパターン
        return trimmed.hasSuffix(": \"\"") || trimmed.hasSuffix(": ''")
    }

    /// セクションヘッダー（子要素を持つ行）かどうかをチェック
    private func isSectionHeader(_ line: String, nextLine: String?) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // コメント行や空行はセクションヘッダーではない
        if trimmed.isEmpty || trimmed.hasPrefix("#") {
            return false
        }

        // "key:" で終わる行（値なし）はセクションヘッダー
        if trimmed.hasSuffix(":") && !trimmed.contains(": ") {
            return true
        }

        // 次の行がより深いインデントを持つ場合もセクションヘッダー
        if let next = nextLine {
            let currentIndent = getIndent(line)
            let nextIndent = getIndent(next)
            let nextTrimmed = next.trimmingCharacters(in: .whitespaces)
            if nextIndent > currentIndent && !nextTrimmed.isEmpty && !nextTrimmed.hasPrefix("#") {
                return true
            }
        }

        return false
    }

    /// 行のインデントレベルを取得
    private func getIndent(_ line: String) -> Int {
        var count = 0
        for char in line {
            if char == " " {
                count += 1
            } else if char == "\t" {
                count += 2  // タブは2スペースとして扱う
            } else {
                break
            }
        }
        return count
    }

    /// 連続する空行を1つにまとめる
    private func consolidateEmptyLines(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var previousWasEmpty = false

        for line in lines {
            let isEmpty = line.trimmingCharacters(in: .whitespaces).isEmpty
            if isEmpty {
                if !previousWasEmpty {
                    result.append(line)
                }
                previousWasEmpty = true
            } else {
                result.append(line)
                previousWasEmpty = false
            }
        }

        return result.joined(separator: "\n")
    }

    /// エラー用YAMLを生成
    private func generateErrorYAML(message: String) -> String {
        var debugInfo = ""
        if let dir = templatesDirectory {
            // ディレクトリ内容を直接確認
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
                debugInfo = "ディレクトリ内容: \(contents.joined(separator: ", "))"
            } else {
                debugInfo = "ディレクトリ内容の取得に失敗"
            }
            // ディレクトリの存在確認
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir)
            debugInfo += "\n# ディレクトリ存在: \(exists), isDirectory: \(isDir.boolValue)"
        }

        return """
        # ====================================================
        # Error
        # ====================================================
        # \(message)
        #
        # テンプレートディレクトリ: \(templatesDirectory?.path ?? "not found")
        # 利用可能なテンプレート: \(listTemplates().joined(separator: ", "))
        # \(debugInfo)
        # ====================================================
        """
    }

    // MARK: - Template Directory Discovery

    /// テンプレートディレクトリを検索
    private static func findTemplatesDirectory() -> URL? {
        // 1. アプリバンドル内を検索（リリース時）
        if let bundleURL = Bundle.main.url(forResource: "yaml_templates", withExtension: nil) {
            return bundleURL
        }

        // 2. バンドルのResourcesフォルダを検索
        if let resourceURL = Bundle.main.resourceURL {
            let templatesURL = resourceURL.appendingPathComponent("yaml_templates")
            if FileManager.default.fileExists(atPath: templatesURL.path) {
                return templatesURL
            }
        }

        // 3. 開発時: ソースファイルからの相対パス（#fileマクロ使用）
        //    TemplateEngine.swift → Services/ → nanobananaMacOS/ → yaml_templates
        let sourceFileURL = URL(fileURLWithPath: #file)
        let nanobananaMacOSDir = sourceFileURL
            .deletingLastPathComponent()  // Services/
            .deletingLastPathComponent()  // nanobananaMacOS/
        let devTemplatesURL = nanobananaMacOSDir.appendingPathComponent("yaml_templates")
        if FileManager.default.fileExists(atPath: devTemplatesURL.path) {
            return devTemplatesURL
        }

        // 4. 開発時: 実行ファイルの場所から上位ディレクトリを探索
        let executableURL = Bundle.main.executableURL
        var searchURL = executableURL?.deletingLastPathComponent()

        for _ in 0..<10 {
            guard let currentURL = searchURL else { break }
            let templatesURL = currentURL.appendingPathComponent("yaml_templates")
            if FileManager.default.fileExists(atPath: templatesURL.path) {
                return templatesURL
            }
            searchURL = currentURL.deletingLastPathComponent()
        }

        // 5. カレントディレクトリからの検索（CLIテスト用）
        let currentDir = FileManager.default.currentDirectoryPath
        let currentTemplatesURL = URL(fileURLWithPath: currentDir).appendingPathComponent("yaml_templates")
        if FileManager.default.fileExists(atPath: currentTemplatesURL.path) {
            return currentTemplatesURL
        }

        return nil
    }
}
