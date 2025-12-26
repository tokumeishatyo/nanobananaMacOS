// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Manga Composer ViewModel
/// 漫画ページコンポーザーのメインViewModel
@MainActor
final class MangaComposerViewModel: ObservableObject {
    // MARK: - Mode Selection
    @Published var selectedMode: ComposerMode = .characterSheet

    // MARK: - Sub ViewModels
    @Published var characterSheetViewModel = CharacterSheetViewModel()

    // MARK: - State
    @Published var isApplied: Bool = false

    // MARK: - Callbacks
    /// 適用ボタン押下時のコールバック
    var onApply: (() -> Void)?
    /// キャンセルボタン押下時のコールバック
    var onCancel: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // CharacterSheetViewModelの変更を監視してViewを更新
        characterSheetViewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    /// 現在のモードが有効か
    var isCurrentModeEnabled: Bool {
        selectedMode.isEnabled
    }

    /// 適用ボタンが有効か
    var canApply: Bool {
        switch selectedMode {
        case .characterSheet:
            return characterSheetViewModel.isValid
        case .mangaCreation:
            return false  // 後日実装
        }
    }

    // MARK: - Actions

    /// 適用
    func apply() {
        guard canApply else { return }
        isApplied = true
        onApply?()
    }

    /// キャンセル
    func cancel() {
        onCancel?()
    }

    /// リセット
    func reset() {
        selectedMode = .characterSheet
        characterSheetViewModel.reset()
        isApplied = false
    }

    // MARK: - Mode Descriptions

    /// 現在のモードの説明
    var currentModeDescription: String {
        selectedMode.description
    }
}

// MARK: - YAML Generation Support
extension MangaComposerViewModel {
    /// YAML生成用の変数辞書を構築（登場人物シート用）
    func buildCharacterSheetVariables() -> [String: String] {
        let vm = characterSheetViewModel
        var variables: [String: String] = [:]

        // シートタイトル
        variables["sheet_title"] = vm.sheetTitle

        // 背景設定
        variables["background_source_type"] = vm.backgroundSourceType == .file ? "file" : "generate"
        variables["background_image"] = vm.backgroundSourceType == .file
            ? (vm.backgroundImagePath as NSString).lastPathComponent
            : ""
        variables["background_description"] = vm.backgroundSourceType == .prompt
            ? vm.backgroundDescription
            : ""

        // キャラクター数
        let validCharacters = vm.characters.filter { $0.isValid }
        variables["character_count"] = String(validCharacters.count)

        // 各キャラクター（1〜3）
        for i in 1...CharacterEntry.maxCount {
            let index = i - 1
            if index < validCharacters.count {
                let char = validCharacters[index]
                variables["character_\(i)_name"] = char.name
                variables["character_\(i)_image"] = (char.imagePath as NSString).lastPathComponent
                variables["character_\(i)_info"] = char.info
            } else {
                // 空値
                variables["character_\(i)_name"] = ""
                variables["character_\(i)_image"] = ""
                variables["character_\(i)_info"] = ""
            }
        }

        return variables
    }
}
