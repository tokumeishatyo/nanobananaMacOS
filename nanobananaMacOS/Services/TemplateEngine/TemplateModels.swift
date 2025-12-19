import Foundation

// MARK: - Master Template Models

/// マスターテンプレート全体
struct MasterTemplate: Codable {
    let version: String
    let commonSections: [String: SectionDefinition]
    let outputTypes: [String: OutputTypeDefinition]

    enum CodingKeys: String, CodingKey {
        case version
        case commonSections = "common_sections"
        case outputTypes = "output_types"
    }
}

/// セクション定義
struct SectionDefinition: Codable {
    let description: String?
    let template: String
}

/// 出力タイプ定義
struct OutputTypeDefinition: Codable {
    let headerValues: [String: String]
    let typeValue: String?
    let outputValues: [String: String]?
    let hasGenerationInstructions: Bool?
    let sections: [String: SectionDefinition]

    enum CodingKeys: String, CodingKey {
        case headerValues = "header_values"
        case typeValue = "type_value"
        case outputValues = "output_values"
        case hasGenerationInstructions = "has_generation_instructions"
        case sections
    }
}

// MARK: - Selection Map Models

/// セクション選択マップ全体
struct SelectionMap: Codable {
    let version: String
    let selectionMap: [String: OutputTypeSelection]
    let variableMappings: [String: [String: String]]?

    enum CodingKeys: String, CodingKey {
        case version
        case selectionMap = "selection_map"
        case variableMappings = "variable_mappings"
    }
}

/// 出力タイプ別選択定義
struct OutputTypeSelection: Codable {
    let outputTypeKey: String
    let mode: String?
    let sceneType: String?
    let hasGenerationInstructions: Bool?
    let sections: [String]

    enum CodingKeys: String, CodingKey {
        case outputTypeKey = "output_type_key"
        case mode
        case sceneType = "scene_type"
        case hasGenerationInstructions = "has_generation_instructions"
        case sections
    }
}

// MARK: - Template AST (Abstract Syntax Tree)

/// テンプレートノード
indirect enum TemplateNode {
    case text(String)
    case variable(String)
    case rawVariable(String)
    case condition(ConditionNode)
    case loop(LoopNode)
    case comment(String)
}

/// 条件分岐ノード
struct ConditionNode {
    let condition: String
    let isNegated: Bool
    let thenBranch: [TemplateNode]
    let elseBranch: [TemplateNode]?
}

/// ループノード
struct LoopNode {
    let arrayName: String
    let body: [TemplateNode]
}

// MARK: - Template Variables

/// テンプレート変数コンテナ
struct TemplateVariables {
    var values: [String: Any]

    init() {
        self.values = [:]
    }

    init(values: [String: Any]) {
        self.values = values
    }

    /// 文字列値を設定
    mutating func set(_ key: String, _ value: String) {
        values[key] = value
    }

    /// Bool値を設定
    mutating func set(_ key: String, _ value: Bool) {
        values[key] = value
    }

    /// 配列値を設定
    mutating func set(_ key: String, _ value: [[String: Any]]) {
        values[key] = value
    }

    /// 値を取得
    func get(_ key: String) -> Any? {
        // ネストされたキー（例: "character.name"）に対応
        let components = key.split(separator: ".").map(String.init)

        if components.count == 1 {
            return values[key]
        }

        // ネストされた値を取得
        var current: Any? = values[components[0]]
        for i in 1..<components.count {
            if let dict = current as? [String: Any] {
                current = dict[components[i]]
            } else {
                return nil
            }
        }
        return current
    }

    /// 文字列として取得
    func getString(_ key: String) -> String? {
        return get(key) as? String
    }

    /// Boolとして取得
    func getBool(_ key: String) -> Bool {
        if let value = get(key) as? Bool {
            return value
        }
        if let value = get(key) as? String {
            return !value.isEmpty
        }
        return false
    }

    /// 配列として取得
    func getArray(_ key: String) -> [[String: Any]]? {
        return get(key) as? [[String: Any]]
    }

    /// 変数が存在するか（空でないか）をチェック
    func exists(_ key: String) -> Bool {
        guard let value = get(key) else { return false }

        if let stringValue = value as? String {
            return !stringValue.isEmpty
        }
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let arrayValue = value as? [Any] {
            return !arrayValue.isEmpty
        }
        return true
    }
}

// MARK: - Template Engine Errors

/// テンプレートエンジンエラー
enum TemplateEngineError: Error, LocalizedError {
    case fileNotFound(String)
    case parseError(String, line: Int?)
    case unknownVariable(String)
    case unknownSection(String)
    case unknownOutputType(String)
    case renderError(String)
    case yamlParseError(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Template file not found: \(path)"
        case .parseError(let message, let line):
            if let line = line {
                return "Parse error at line \(line): \(message)"
            }
            return "Parse error: \(message)"
        case .unknownVariable(let name):
            return "Unknown variable: \(name)"
        case .unknownSection(let name):
            return "Unknown section: \(name)"
        case .unknownOutputType(let name):
            return "Unknown output type: \(name)"
        case .renderError(let message):
            return "Render error: \(message)"
        case .yamlParseError(let message):
            return "YAML parse error: \(message)"
        }
    }
}

// MARK: - Output Type Mapping

/// Swift OutputType と テンプレートキーのマッピング
extension OutputType {
    var templateKey: String {
        switch self {
        case .faceSheet:
            return "face_sheet"
        case .bodySheet:
            return "body_sheet"
        case .outfitSheet:
            return "outfit_sheet"
        case .pose:
            return "pose"
        case .sceneBuilder:
            return "scene_builder"
        case .background:
            return "background"
        case .decorativeText:
            return "decorative_text"
        case .fourPanelManga:
            return "four_panel"
        case .styleTransform:
            return "style_transform"
        case .infographic:
            return "infographic"
        }
    }
}
