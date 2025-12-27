// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Manga Creation ViewModel
/// 漫画作成のViewModel
@MainActor
final class MangaCreationViewModel: ObservableObject {
    // MARK: - Constants
    static let minPanelCount = 1
    static let maxPanelCount = 4
    static let minCharacterCount = 1
    static let maxCharacterCount = 3

    // MARK: - Panels
    @Published var panels: [MangaPanel] = []

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // 初期パネルを追加
        let initialPanel = MangaPanel()
        panels = [initialPanel]
        observePanel(initialPanel)
    }

    /// パネルの変更を監視
    private func observePanel(_ panel: MangaPanel) {
        panel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    /// パネルを追加可能か
    var canAddPanel: Bool {
        panels.count < Self.maxPanelCount
    }

    /// パネルを削除可能か
    var canRemovePanel: Bool {
        panels.count > Self.minPanelCount
    }

    /// 入力が有効か（YAML生成可能か）
    /// 全てのコマにシーンが入力されていれば有効
    var isValid: Bool {
        panels.allSatisfy { $0.hasScene }
    }

    // MARK: - Actions

    /// パネルを追加
    func addPanel() {
        guard canAddPanel else { return }
        let newPanel = MangaPanel()
        panels.append(newPanel)
        observePanel(newPanel)
    }

    /// パネルを削除
    func removePanel(at index: Int) {
        guard canRemovePanel, panels.indices.contains(index) else { return }
        panels.remove(at: index)
    }

    /// リセット
    func reset() {
        cancellables.removeAll()
        let initialPanel = MangaPanel()
        panels = [initialPanel]
        observePanel(initialPanel)
    }
}

// MARK: - Manga Panel
/// 漫画の1コマ分のデータ
final class MangaPanel: ObservableObject, Identifiable {
    let id = UUID()

    // MARK: - Panel Content
    @Published var scene: String = ""           // シーン説明（必須）
    @Published var narration: String = ""       // ナレーション（任意）
    @Published var hasMobCharacters: Bool = false  // モブキャラを含める

    // MARK: - Characters (1〜3人)
    @Published var characters: [PanelCharacter] = []

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // 初期キャラクターを追加
        let initialCharacter = PanelCharacter()
        characters = [initialCharacter]
        observeCharacter(initialCharacter)
    }

    /// キャラクターの変更を監視
    private func observeCharacter(_ character: PanelCharacter) {
        character.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    /// キャラクターを追加可能か
    var canAddCharacter: Bool {
        characters.count < MangaCreationViewModel.maxCharacterCount
    }

    /// キャラクターを削除可能か
    var canRemoveCharacter: Bool {
        characters.count > MangaCreationViewModel.minCharacterCount
    }

    /// 有効なキャラクター数
    var validCharacterCount: Int {
        characters.filter { $0.isValid }.count
    }

    /// シーンが入力されているか
    var hasScene: Bool {
        !scene.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// パネルが有効か（YAML生成時の完全な検証用）
    var isValid: Bool {
        // シーンが必須
        guard hasScene else {
            return false
        }
        // 最低1人のキャラクターが有効
        guard validCharacterCount >= 1 else {
            return false
        }
        return true
    }

    // MARK: - Actions

    /// キャラクターを追加
    func addCharacter() {
        guard canAddCharacter else { return }
        let newCharacter = PanelCharacter()
        characters.append(newCharacter)
        observeCharacter(newCharacter)
    }

    /// キャラクターを削除
    func removeCharacter(at index: Int) {
        guard canRemoveCharacter, characters.indices.contains(index) else { return }
        characters.remove(at: index)
    }
}

// MARK: - Panel Character
/// コマ内のキャラクター情報
final class PanelCharacter: ObservableObject, Identifiable {
    let id = UUID()

    @Published var name: String = ""            // キャラクター名（相対位置参照用、必須）
    @Published var imagePath: String = ""       // キャラクター画像パス
    @Published var dialogue: String = ""        // セリフ
    @Published var features: String = ""        // 特徴（表情・ポーズ）

    /// 有効か（名前と画像パスが設定されているか）
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !imagePath.isEmpty
    }

    /// 名前が入力されているか
    var hasName: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
