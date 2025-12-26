// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Character Sheet ViewModel
/// 登場人物生成シートのViewModel
@MainActor
final class CharacterSheetViewModel: ObservableObject {
    // MARK: - Sheet Title
    @Published var sheetTitle: String = ""

    // MARK: - Background Settings
    @Published var backgroundSourceType: BackgroundSourceType = .prompt  // .file or .prompt
    @Published var backgroundImagePath: String = ""
    @Published var backgroundDescription: String = ""

    // MARK: - Characters (1〜3名)
    @Published var characters: [CharacterEntry] = [CharacterEntry()] {
        didSet {
            setupCharacterObservers()
        }
    }

    private var characterCancellables: [AnyCancellable] = []

    init() {
        setupCharacterObservers()
    }

    /// キャラクターの変更を監視してViewを更新
    private func setupCharacterObservers() {
        characterCancellables.removeAll()
        for character in characters {
            character.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &characterCancellables)
        }
    }

    // MARK: - Computed Properties

    /// 有効なキャラクター数
    var validCharacterCount: Int {
        characters.filter { $0.isValid }.count
    }

    /// キャラクターを追加可能か
    var canAddCharacter: Bool {
        characters.count < CharacterEntry.maxCount
    }

    /// キャラクターを削除可能か
    var canRemoveCharacter: Bool {
        characters.count > CharacterEntry.minCount
    }

    /// 入力が有効かどうか（YAML生成可能か）
    var isValid: Bool {
        // シートタイトルが必須
        guard !sheetTitle.isEmpty else { return false }

        // 背景設定が有効か
        switch backgroundSourceType {
        case .prompt:
            guard !backgroundDescription.isEmpty else { return false }
        case .file:
            guard !backgroundImagePath.isEmpty else { return false }
        }

        // 最低1人のキャラクターが有効か
        guard validCharacterCount >= 1 else { return false }

        return true
    }

    // MARK: - Actions

    /// キャラクターを追加
    func addCharacter() {
        guard canAddCharacter else { return }
        characters.append(CharacterEntry())
    }

    /// キャラクターを削除
    func removeCharacter(at index: Int) {
        guard canRemoveCharacter, characters.indices.contains(index) else { return }
        characters.remove(at: index)
    }

    /// リセット
    func reset() {
        sheetTitle = ""
        backgroundSourceType = .prompt
        backgroundImagePath = ""
        backgroundDescription = ""
        characters = [CharacterEntry()]
    }

    // MARK: - Placeholders

    var sheetTitlePlaceholder: String {
        "例: 登場人物"
    }

    var backgroundDescriptionPlaceholder: String {
        "キャラクターシートの背景の様子を説明する"
    }
}
