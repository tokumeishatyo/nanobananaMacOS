import Foundation
import Combine

// MARK: - CharacterDatabaseViewModel
/// キャラクター管理画面用ViewModel
class CharacterDatabaseViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 編集中のキャラクター（新規の場合nil）
    @Published var editingCharacterId: UUID?

    /// 編集モードかどうか
    @Published var isEditing: Bool = false

    // フォーム入力
    @Published var formName: String = ""
    @Published var formFaceFeatures: String = ""
    @Published var formBodyFeatures: String = ""
    @Published var formPersonality: String = ""

    // バリデーションエラー
    @Published var nameError: String?
    @Published var faceFeaturesError: String?

    // MARK: - Dependencies

    private let service: CharacterDatabaseService
    private var cancellables = Set<AnyCancellable>()

    /// 登録済みキャラクター一覧
    var characters: [SavedCharacter] {
        service.characters
    }

    // MARK: - Initialization

    init(service: CharacterDatabaseService) {
        self.service = service

        // Serviceの変更をViewに伝播
        service.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Form Operations

    /// 新規登録モードを開始
    func startNewEntry() {
        editingCharacterId = nil
        isEditing = true
        clearForm()
        clearErrors()
    }

    /// 編集モードを開始
    func startEditing(_ character: SavedCharacter) {
        editingCharacterId = character.id
        isEditing = true
        formName = character.name
        formFaceFeatures = character.faceFeatures
        formBodyFeatures = character.bodyFeatures
        formPersonality = character.personality
        clearErrors()
    }

    /// 編集をキャンセル
    func cancelEditing() {
        isEditing = false
        editingCharacterId = nil
        clearForm()
        clearErrors()
    }

    /// 保存（新規追加または更新）
    /// - Returns: 成功した場合true
    func save() -> Bool {
        guard validate() else {
            return false
        }

        let trimmedName = formName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFaceFeatures = formFaceFeatures.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBodyFeatures = formBodyFeatures.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPersonality = formPersonality.trimmingCharacters(in: .whitespacesAndNewlines)

        let success: Bool

        if let existingId = editingCharacterId {
            // 更新
            let character = SavedCharacter(
                id: existingId,
                name: trimmedName,
                faceFeatures: trimmedFaceFeatures,
                bodyFeatures: trimmedBodyFeatures,
                personality: trimmedPersonality
            )
            success = service.update(character)
        } else {
            // 新規追加
            let character = SavedCharacter(
                name: trimmedName,
                faceFeatures: trimmedFaceFeatures,
                bodyFeatures: trimmedBodyFeatures,
                personality: trimmedPersonality
            )
            success = service.add(character)
        }

        if success {
            isEditing = false
            editingCharacterId = nil
            clearForm()
        } else {
            nameError = "保存に失敗しました"
        }

        return success
    }

    /// キャラクターを削除
    func delete(_ character: SavedCharacter) {
        _ = service.delete(id: character.id)
        // 編集中のキャラクターが削除された場合、編集モードを解除
        if editingCharacterId == character.id {
            cancelEditing()
        }
    }

    // MARK: - Validation

    /// バリデーション実行
    /// - Returns: 有効な場合true
    func validate() -> Bool {
        clearErrors()
        var isValid = true

        let trimmedName = formName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFaceFeatures = formFaceFeatures.trimmingCharacters(in: .whitespacesAndNewlines)

        // キャラクタ名チェック
        if trimmedName.isEmpty {
            nameError = "キャラクタ名は必須です"
            isValid = false
        } else if !service.isNameUnique(trimmedName, excludingId: editingCharacterId) {
            nameError = "このキャラクタ名は既に登録されています"
            isValid = false
        }

        // 顔の特徴チェック
        if trimmedFaceFeatures.isEmpty {
            faceFeaturesError = "顔の特徴は必須です"
            isValid = false
        }

        return isValid
    }

    // MARK: - Export / Import

    /// 外部ファイルにエクスポート
    /// - Parameter url: 保存先URL
    /// - Returns: エラーメッセージ（成功時はnil）
    func exportToFile(url: URL) -> String? {
        do {
            try service.exportToFile(url: url)
            return nil
        } catch {
            return "エクスポートに失敗しました: \(error.localizedDescription)"
        }
    }

    /// 外部ファイルからインポート
    /// - Parameter url: 読み込み元URL
    /// - Returns: エラーメッセージ（成功時はnil）
    func importFromFile(url: URL) -> String? {
        do {
            try service.importFromFile(url: url)
            // 編集モードを解除
            cancelEditing()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    // MARK: - Private Methods

    private func clearForm() {
        formName = ""
        formFaceFeatures = ""
        formBodyFeatures = ""
        formPersonality = ""
    }

    private func clearErrors() {
        nameError = nil
        faceFeaturesError = nil
    }
}
