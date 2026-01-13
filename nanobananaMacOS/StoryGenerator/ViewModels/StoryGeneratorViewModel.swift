// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Story Panel Mode
/// 1コマ/4コマの選択
enum StoryPanelMode: String, CaseIterable {
    case single = "single"
    case fourPanel = "fourPanel"

    var displayLabel: String {
        switch self {
        case .single: return "1コマ"
        case .fourPanel: return "4コマ"
        }
    }

    var panelCount: Int {
        switch self {
        case .single: return 1
        case .fourPanel: return 4
        }
    }
}

// MARK: - Story Render Mode
/// ストーリー用のrender_mode（4コマはinset_visualizationなし）
enum StoryRenderMode: String, CaseIterable {
    case fullBody = "full_body"
    case bubbleOnly = "bubble_only"
    case textOnly = "text_only"
    case insetVisualization = "inset_visualization"

    var displayLabel: String {
        switch self {
        case .fullBody: return "全身描画"
        case .bubbleOnly: return "ちびアイコン付き"
        case .textOnly: return "吹き出しのみ"
        case .insetVisualization: return "インセット（夢・画面）"
        }
    }

    /// 4コマモードで使用可能なモードのみ
    static var fourPanelModes: [StoryRenderMode] {
        [.fullBody, .bubbleOnly, .textOnly]
    }
}

// MARK: - Story Generator ViewModel
/// ストーリーYAML生成のViewModel
@MainActor
final class StoryGeneratorViewModel: ObservableObject {
    // MARK: - Constants
    static let maxCharactersPerPanel = 3
    static let maxGuestsPerInset = 2

    // MARK: - Settings
    @Published var enableTranslation: Bool = false  // 英訳チェック（デフォルトオフ）
    @Published var panelMode: StoryPanelMode = .single  // デフォルト: 1コマ

    // MARK: - Basic Info
    @Published var storyTitle: String = ""

    // MARK: - Selected Characters (from DB)
    @Published var selectedCharacterIds: Set<UUID> = []

    // MARK: - Panels
    @Published var panels: [StoryPanel] = []

    // MARK: - Callbacks
    var onGenerate: (() -> Void)?
    var onCancel: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // 初期パネルを追加（1コマ）
        let initialPanel = StoryPanel(panelNumber: 1)
        panels = [initialPanel]
        observePanel(initialPanel)

        // panelMode変更時にパネル数を調整
        $panelMode
            .dropFirst()
            .sink { [weak self] newMode in
                self?.adjustPanelCount(for: newMode)
            }
            .store(in: &cancellables)
    }

    // MARK: - Panel Count Adjustment

    /// モード変更時にパネル数を調整
    private func adjustPanelCount(for mode: StoryPanelMode) {
        let targetCount = mode.panelCount

        if panels.count < targetCount {
            // パネルを追加
            for i in (panels.count + 1)...targetCount {
                let newPanel = StoryPanel(panelNumber: i)
                panels.append(newPanel)
                observePanel(newPanel)
            }
        } else if panels.count > targetCount {
            // パネルを削減
            panels = Array(panels.prefix(targetCount))
        }

        // 4コマモードの場合、インセットモードをfullBodyに変更
        if mode == .fourPanel {
            for panel in panels {
                for character in panel.characters {
                    if character.renderMode == StoryRenderMode.insetVisualization {
                        character.renderMode = StoryRenderMode.fullBody
                    }
                }
            }
        }
    }

    /// パネルの変更を監視
    private func observePanel(_ panel: StoryPanel) {
        panel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Character Selection

    /// キャラクターを選択/解除
    func toggleCharacterSelection(_ characterId: UUID) {
        if selectedCharacterIds.contains(characterId) {
            selectedCharacterIds.remove(characterId)
        } else {
            selectedCharacterIds.insert(characterId)
        }
    }

    /// 選択済みキャラクターを取得
    func getSelectedCharacters(from allCharacters: [SavedCharacter]) -> [SavedCharacter] {
        allCharacters.filter { selectedCharacterIds.contains($0.id) }
    }

    // MARK: - Validation

    /// 入力が有効か
    var isValid: Bool {
        // タイトルが必須
        guard !storyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        // キャラクターが最低1人選択されている
        guard !selectedCharacterIds.isEmpty else {
            return false
        }

        // 全パネルが有効
        return panels.allSatisfy { $0.isValid }
    }

    // MARK: - Actions

    /// リセット
    func reset() {
        cancellables.removeAll()

        enableTranslation = false
        panelMode = .single
        storyTitle = ""
        selectedCharacterIds = []

        let initialPanel = StoryPanel(panelNumber: 1)
        panels = [initialPanel]
        observePanel(initialPanel)
    }
}

// MARK: - Story Panel
/// ストーリーの1コマ分のデータ
final class StoryPanel: ObservableObject, Identifiable {
    let id = UUID()
    let panelNumber: Int

    @Published var scene: String = ""           // シーン（必須）
    @Published var narration: String = ""       // ナレーション
    @Published var hasMob: Bool = false         // モブを含める

    @Published var characters: [StoryPanelCharacter] = []

    private var cancellables: Set<AnyCancellable> = []

    init(panelNumber: Int) {
        self.panelNumber = panelNumber
    }

    /// キャラクターの変更を監視
    private func observeCharacter(_ character: StoryPanelCharacter) {
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
        characters.count < StoryGeneratorViewModel.maxCharactersPerPanel
    }

    /// キャラクターを削除可能か
    var canRemoveCharacter: Bool {
        characters.count > 0
    }

    /// パネルが有効か
    var isValid: Bool {
        !scene.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    /// キャラクターを追加
    func addCharacter() {
        guard canAddCharacter else { return }
        let newCharacter = StoryPanelCharacter()
        characters.append(newCharacter)
        observeCharacter(newCharacter)
    }

    /// キャラクターを削除
    func removeCharacter(at index: Int) {
        guard characters.indices.contains(index) else { return }
        characters.remove(at: index)
    }
}

// MARK: - Story Character
/// コマ内のキャラクター情報
final class StoryPanelCharacter: ObservableObject, Identifiable {
    let id = UUID()

    @Published var selectedCharacterId: UUID?           // 選択されたキャラクターID
    @Published var renderMode: StoryRenderMode = .fullBody
    @Published var dialogue: String = ""                // セリフ
    @Published var features: String = ""                // 表情・ポーズ（必須）

    // MARK: - Inset Settings (inset_visualization時のみ)
    @Published var internalBackground: String = ""      // 背景
    @Published var internalOutfit: String = ""          // 衣装
    @Published var internalSituation: String = ""       // 行動
    @Published var internalEmotion: String = ""         // 表情
    @Published var internalDialogue: String = ""        // インセット内セリフ

    @Published var guests: [StoryGuest] = []            // ゲスト（最大2人）

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // ゲストの監視は追加時に行う
    }

    /// ゲストの変更を監視
    private func observeGuest(_ guest: StoryGuest) {
        guest.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    /// インセットモードか
    var isInsetMode: Bool {
        renderMode == .insetVisualization
    }

    /// ゲストを追加可能か
    var canAddGuest: Bool {
        guests.count < StoryGeneratorViewModel.maxGuestsPerInset
    }

    /// ゲストを削除可能か
    var canRemoveGuest: Bool {
        guests.count > 0
    }

    /// キャラクターが有効か（非インセット）
    var isValidNonInset: Bool {
        selectedCharacterId != nil &&
        !features.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// キャラクターが有効か（インセット）
    var isValidInset: Bool {
        selectedCharacterId != nil &&
        !internalBackground.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !internalSituation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !internalEmotion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// キャラクターが有効か
    var isValid: Bool {
        if isInsetMode {
            return isValidInset
        } else {
            return isValidNonInset
        }
    }

    // MARK: - Actions

    /// ゲストを追加
    func addGuest() {
        guard canAddGuest else { return }
        let newGuest = StoryGuest()
        guests.append(newGuest)
        observeGuest(newGuest)
    }

    /// ゲストを削除
    func removeGuest(at index: Int) {
        guard guests.indices.contains(index) else { return }
        guests.remove(at: index)
    }
}

// MARK: - Story Guest
/// インセット内のゲストキャラクター
final class StoryGuest: ObservableObject, Identifiable {
    let id = UUID()

    @Published var name: String = ""                    // ゲスト名
    @Published var guestDescription: String = ""        // ゲスト外見
    @Published var dialogue: String = ""                // ゲストのセリフ
}
