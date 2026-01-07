import Foundation
import Combine

// MARK: - CharacterExportData
/// エクスポート用データモデル（シグネチャ付き）
struct CharacterExportData: Codable, Sendable {
    let signature: String
    let exportedAt: String
    let version: String
    let characters: [SavedCharacter]

    static let currentSignature = "nanobananaMacOS-character-db-v1"
    static let currentVersion = "1.0"

    init(characters: [SavedCharacter]) {
        self.signature = Self.currentSignature
        self.exportedAt = ISO8601DateFormatter().string(from: Date())
        self.version = Self.currentVersion
        self.characters = characters
    }
}

// MARK: - CharacterImportError
/// インポート時のエラー
enum CharacterImportError: LocalizedError {
    case invalidSignature
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return "このファイルは本アプリで作成されたものではありません"
        case .invalidFormat(let detail):
            return "ファイル形式が不正です: \(detail)"
        }
    }
}

// MARK: - CharacterDatabaseService
/// キャラクターデータベースの永続化サービス
/// JSONファイルでローカル保存
class CharacterDatabaseService: ObservableObject {
    @Published private(set) var characters: [SavedCharacter] = []

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent(AppConstants.appSupportFolderName)
        self.fileURL = appFolder.appendingPathComponent(AppConstants.characterDatabaseFileName)

        // フォルダがなければ作成
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        load()
    }

    // MARK: - CRUD Operations

    /// キャラクターを追加
    /// - Returns: 成功した場合true
    func add(_ character: SavedCharacter) -> Bool {
        guard isNameUnique(character.name) else {
            return false
        }
        characters.append(character)
        save()
        return true
    }

    /// キャラクターを更新
    /// - Returns: 成功した場合true
    func update(_ character: SavedCharacter) -> Bool {
        guard let index = characters.firstIndex(where: { $0.id == character.id }) else {
            return false
        }
        // 名前変更時の重複チェック
        if characters[index].name != character.name {
            guard isNameUnique(character.name, excludingId: character.id) else {
                return false
            }
        }
        characters[index] = character
        save()
        return true
    }

    /// キャラクターを削除
    /// - Returns: 成功した場合true
    func delete(id: UUID) -> Bool {
        guard let index = characters.firstIndex(where: { $0.id == id }) else {
            return false
        }
        characters.remove(at: index)
        save()
        return true
    }

    /// 名前でキャラクターを検索
    func find(byName name: String) -> SavedCharacter? {
        characters.first { $0.name == name }
    }

    /// IDでキャラクターを検索
    func find(byId id: UUID) -> SavedCharacter? {
        characters.first { $0.id == id }
    }

    // MARK: - Validation

    /// 名前が一意かチェック
    func isNameUnique(_ name: String, excludingId: UUID? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return false
        }
        return !characters.contains { character in
            if let excludingId = excludingId, character.id == excludingId {
                return false
            }
            return character.name == trimmedName
        }
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            characters = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            characters = try decoder.decode([SavedCharacter].self, from: data)
        } catch {
            print("CharacterDatabaseService: Failed to load - \(error)")
            characters = []
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(characters)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("CharacterDatabaseService: Failed to save - \(error)")
        }
    }

    // MARK: - Export / Import

    /// 外部ファイルにエクスポート
    /// - Parameter url: 保存先URL
    func exportToFile(url: URL) throws {
        let exportData = CharacterExportData(characters: characters)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportData)
        try data.write(to: url, options: .atomic)
    }

    /// 外部ファイルからインポート（シグネチャ検証付き）
    /// - Parameter url: 読み込み元URL
    func importFromFile(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        let importData: CharacterExportData
        do {
            importData = try decoder.decode(CharacterExportData.self, from: data)
        } catch {
            throw CharacterImportError.invalidFormat(error.localizedDescription)
        }

        // シグネチャ検証
        guard importData.signature == CharacterExportData.currentSignature else {
            throw CharacterImportError.invalidSignature
        }

        // インポート実行（既存データを上書き）
        characters = importData.characters
        save()
    }
}
