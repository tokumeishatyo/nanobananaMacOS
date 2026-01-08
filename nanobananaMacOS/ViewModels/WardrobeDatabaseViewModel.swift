// rule.mdを読むこと
import Foundation
import Combine

// MARK: - WardrobeDatabaseViewModel
/// 衣装管理画面用ViewModel
class WardrobeDatabaseViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 編集中の衣装（新規の場合nil）
    @Published var editingWardrobeId: UUID?

    /// 編集モードかどうか
    @Published var isEditing: Bool = false

    // フォーム入力
    @Published var formName: String = ""
    @Published var formDescription: String = ""

    // バリデーションエラー
    @Published var nameError: String?

    // MARK: - Dependencies

    private let service: WardrobeDatabaseService
    private var cancellables = Set<AnyCancellable>()

    /// 登録済み衣装一覧
    var wardrobes: [SavedWardrobe] {
        service.wardrobes
    }

    // MARK: - Initialization

    init(service: WardrobeDatabaseService) {
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
        editingWardrobeId = nil
        isEditing = true
        clearForm()
        clearErrors()
    }

    /// 編集モードを開始
    func startEditing(_ wardrobe: SavedWardrobe) {
        editingWardrobeId = wardrobe.id
        isEditing = true
        formName = wardrobe.name
        formDescription = wardrobe.description
        clearErrors()
    }

    /// 編集をキャンセル
    func cancelEditing() {
        isEditing = false
        editingWardrobeId = nil
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
        let trimmedDescription = formDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        let success: Bool

        if let existingId = editingWardrobeId {
            // 更新
            let wardrobe = SavedWardrobe(
                id: existingId,
                name: trimmedName,
                description: trimmedDescription
            )
            success = service.update(wardrobe)
        } else {
            // 新規追加
            let wardrobe = SavedWardrobe(
                name: trimmedName,
                description: trimmedDescription
            )
            success = service.add(wardrobe)
        }

        if success {
            isEditing = false
            editingWardrobeId = nil
            clearForm()
        } else {
            nameError = "保存に失敗しました"
        }

        return success
    }

    /// 衣装を削除
    func delete(_ wardrobe: SavedWardrobe) {
        _ = service.delete(id: wardrobe.id)
        // 編集中の衣装が削除された場合、編集モードを解除
        if editingWardrobeId == wardrobe.id {
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

        // 衣装名チェック
        if trimmedName.isEmpty {
            nameError = "衣装名は必須です"
            isValid = false
        } else if !service.isNameUnique(trimmedName, excludingId: editingWardrobeId) {
            nameError = "この衣装名は既に登録されています"
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
        formDescription = ""
    }

    private func clearErrors() {
        nameError = nil
    }
}
