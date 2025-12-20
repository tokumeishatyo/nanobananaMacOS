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
        if templatesDirectory == nil {
            print("[TemplateEngine] Warning: Templates directory not found")
        }
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
        let result = replaceVariables(expanded, variables: variables)

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
            print("[TemplateEngine] Error listing templates: \(error)")
            return []
        }
    }

    // MARK: - Private Methods

    /// テンプレートファイルを読み込む
    private func loadTemplate(_ name: String) -> String? {
        guard let directory = templatesDirectory else { return nil }
        let url = directory.appendingPathComponent(name)
        return try? String(contentsOf: url, encoding: .utf8)
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
