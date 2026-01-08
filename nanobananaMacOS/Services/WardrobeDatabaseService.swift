// rule.mdを読むこと
import Foundation
import Combine

// MARK: - WardrobeExportData
/// エクスポート用データモデル（シグネチャ付き）
struct WardrobeExportData: Codable, Sendable {
    let signature: String
    let exportedAt: String
    let version: String
    let wardrobes: [SavedWardrobe]

    static let currentSignature = "nanobananaMacOS-wardrobe-db-v1"
    static let currentVersion = "1.0"

    init(wardrobes: [SavedWardrobe]) {
        self.signature = Self.currentSignature
        self.exportedAt = Date().ISO8601Format()
        self.version = Self.currentVersion
        self.wardrobes = wardrobes
    }
}

// MARK: - WardrobeImportError
/// インポート時のエラー
enum WardrobeImportError: LocalizedError {
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

// MARK: - WardrobeDatabaseService
/// 衣装データベースの永続化サービス
/// JSONファイルでローカル保存
class WardrobeDatabaseService: ObservableObject {
    @Published private(set) var wardrobes: [SavedWardrobe] = []

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent(AppConstants.appSupportFolderName)
        self.fileURL = appFolder.appendingPathComponent(AppConstants.wardrobeDatabaseFileName)

        // フォルダがなければ作成
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        load()
    }

    // MARK: - CRUD Operations

    /// 衣装を追加
    /// - Returns: 成功した場合true
    func add(_ wardrobe: SavedWardrobe) -> Bool {
        guard isNameUnique(wardrobe.name) else {
            return false
        }
        wardrobes.append(wardrobe)
        save()
        return true
    }

    /// 衣装を更新
    /// - Returns: 成功した場合true
    func update(_ wardrobe: SavedWardrobe) -> Bool {
        guard let index = wardrobes.firstIndex(where: { $0.id == wardrobe.id }) else {
            return false
        }
        // 名前変更時の重複チェック
        if wardrobes[index].name != wardrobe.name {
            guard isNameUnique(wardrobe.name, excludingId: wardrobe.id) else {
                return false
            }
        }
        wardrobes[index] = wardrobe
        save()
        return true
    }

    /// 衣装を削除
    /// - Returns: 成功した場合true
    func delete(id: UUID) -> Bool {
        guard let index = wardrobes.firstIndex(where: { $0.id == id }) else {
            return false
        }
        wardrobes.remove(at: index)
        save()
        return true
    }

    /// 名前で衣装を検索
    func find(byName name: String) -> SavedWardrobe? {
        wardrobes.first { $0.name == name }
    }

    /// IDで衣装を検索
    func find(byId id: UUID) -> SavedWardrobe? {
        wardrobes.first { $0.id == id }
    }

    // MARK: - Validation

    /// 名前が一意かチェック
    func isNameUnique(_ name: String, excludingId: UUID? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return false
        }
        return !wardrobes.contains { wardrobe in
            if let excludingId = excludingId, wardrobe.id == excludingId {
                return false
            }
            return wardrobe.name == trimmedName
        }
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            wardrobes = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            wardrobes = try decoder.decode([SavedWardrobe].self, from: data)
        } catch {
            print("WardrobeDatabaseService: Failed to load - \(error)")
            wardrobes = []
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(wardrobes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("WardrobeDatabaseService: Failed to save - \(error)")
        }
    }

    // MARK: - Export / Import

    /// 外部ファイルにエクスポート
    /// - Parameter url: 保存先URL
    func exportToFile(url: URL) throws {
        let exportData = WardrobeExportData(wardrobes: wardrobes)
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

        let importData: WardrobeExportData
        do {
            importData = try decoder.decode(WardrobeExportData.self, from: data)
        } catch {
            throw WardrobeImportError.invalidFormat(error.localizedDescription)
        }

        // シグネチャ検証
        guard importData.signature == WardrobeExportData.currentSignature else {
            throw WardrobeImportError.invalidSignature
        }

        // インポート実行（既存データを上書き）
        wardrobes = importData.wardrobes
        save()
    }
}
