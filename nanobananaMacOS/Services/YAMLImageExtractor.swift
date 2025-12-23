// rule.mdを読むこと
import Foundation

/// YAMLから画像ファイル名を抽出するサービス
struct YAMLImageExtractor {

    // MARK: - Constants

    /// 対応する画像拡張子
    private static let imageExtensions = ["png", "jpg", "jpeg"]

    // MARK: - Public Methods

    /// YAMLテキストから画像ファイル名を抽出
    /// - Parameter yaml: YAMLテキスト
    /// - Returns: 画像ファイル名の配列（重複なし、順序保持）
    static func extractImageFilenames(from yaml: String) -> [String] {
        var filenames: [String] = []
        var seenFilenames = Set<String>()

        let lines = yaml.components(separatedBy: .newlines)

        for line in lines {
            // 画像ファイル名パターンを検索
            // 例: reference_sheet: "顔三面図.png"
            // 例: image: character_01.jpg
            // 例: source_image: "test.jpeg"

            for filename in extractFilenamesFromLine(line) {
                if !seenFilenames.contains(filename) {
                    seenFilenames.insert(filename)
                    filenames.append(filename)
                }
            }
        }

        return filenames
    }

    // MARK: - Private Methods

    /// 1行から画像ファイル名を抽出
    private static func extractFilenamesFromLine(_ line: String) -> [String] {
        var result: [String] = []

        // パターン1: クォートで囲まれたファイル名
        // 例: "filename.png" または 'filename.jpg'
        let quotedPattern = #"[\"']([^\"']+\.(?:png|jpg|jpeg))[\"']"#
        if let regex = try? NSRegularExpression(pattern: quotedPattern, options: .caseInsensitive) {
            let range = NSRange(line.startIndex..., in: line)
            let matches = regex.matches(in: line, options: [], range: range)
            for match in matches {
                if let filenameRange = Range(match.range(at: 1), in: line) {
                    result.append(String(line[filenameRange]))
                }
            }
        }

        // パターン2: クォートなしのファイル名（YAML値として）
        // 例: image: filename.png
        let unquotedPattern = #":\s*([^\s\"']+\.(?:png|jpg|jpeg))\s*$"#
        if let regex = try? NSRegularExpression(pattern: unquotedPattern, options: .caseInsensitive) {
            let range = NSRange(line.startIndex..., in: line)
            let matches = regex.matches(in: line, options: [], range: range)
            for match in matches {
                if let filenameRange = Range(match.range(at: 1), in: line) {
                    let filename = String(line[filenameRange])
                    // 既にクォート付きで抽出されていない場合のみ追加
                    if !result.contains(filename) {
                        result.append(filename)
                    }
                }
            }
        }

        return result
    }

    /// 特定のセクション内から画像ファイル名を抽出
    /// - Parameters:
    ///   - yaml: YAMLテキスト
    ///   - sectionName: セクション名（例: "Input", "Characters"）
    /// - Returns: 画像ファイル名の配列
    static func extractImageFilenames(from yaml: String, inSection sectionName: String) -> [String] {
        var filenames: [String] = []
        var seenFilenames = Set<String>()
        var inTargetSection = false

        let lines = yaml.components(separatedBy: .newlines)

        for line in lines {
            // セクションヘッダーを検出
            // 例: # Input または # Characters
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") {
                let sectionHeader = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
                inTargetSection = sectionHeader.lowercased().hasPrefix(sectionName.lowercased())
                continue
            }

            // 対象セクション内の場合のみファイル名を抽出
            if inTargetSection {
                for filename in extractFilenamesFromLine(line) {
                    if !seenFilenames.contains(filename) {
                        seenFilenames.insert(filename)
                        filenames.append(filename)
                    }
                }
            }
        }

        return filenames
    }

    /// 複数のセクションから画像ファイル名を抽出
    /// - Parameters:
    ///   - yaml: YAMLテキスト
    ///   - sectionNames: セクション名の配列
    /// - Returns: 画像ファイル名の配列（重複なし）
    static func extractImageFilenames(from yaml: String, inSections sectionNames: [String]) -> [String] {
        var filenames: [String] = []
        var seenFilenames = Set<String>()

        for sectionName in sectionNames {
            for filename in extractImageFilenames(from: yaml, inSection: sectionName) {
                if !seenFilenames.contains(filename) {
                    seenFilenames.insert(filename)
                    filenames.append(filename)
                }
            }
        }

        return filenames
    }
}
