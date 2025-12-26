// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Manga Composer ViewModel
/// 漫画ページコンポーザーのメインViewModel
@MainActor
final class MangaComposerViewModel: ObservableObject {
    // MARK: - Mode Selection
    @Published var selectedMode: ComposerMode = .characterCard  // デフォルトはキャラカード

    // MARK: - Sub ViewModels
    @Published var characterSheetViewModel = CharacterSheetViewModel()
    @Published var mangaCreationViewModel = MangaCreationViewModel()

    // MARK: - Character Card Mode
    /// キャラカード用の単一キャラクター
    @Published var characterCardEntry = CharacterEntry()

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

        // CharacterCardEntryの変更を監視してViewを更新
        characterCardEntry.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // MangaCreationViewModelの変更を監視してViewを更新
        mangaCreationViewModel.objectWillChange
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
        case .characterCard:
            return characterCardEntry.isValid
        case .characterSheet:
            return characterSheetViewModel.isValid
        case .mangaCreation:
            return mangaCreationViewModel.isValid
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
        selectedMode = .characterCard  // デフォルトに戻す
        characterCardEntry = CharacterEntry()
        characterSheetViewModel.reset()
        mangaCreationViewModel.reset()
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
    /// YAML生成用の変数辞書を構築（登場人物シート用 - カード画像ベース）
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

        // カード画像パス（有効なものだけ）
        let validCardPaths = vm.cardImagePaths.filter { !$0.isEmpty }
        variables["card_count"] = String(validCardPaths.count)

        // 各カード画像（1〜3）
        for i in 1...CharacterSheetViewModel.maxCardCount {
            let index = i - 1
            if index < validCardPaths.count {
                variables["card_\(i)_image"] = (validCardPaths[index] as NSString).lastPathComponent
            } else {
                variables["card_\(i)_image"] = ""
            }
        }

        return variables
    }
}
