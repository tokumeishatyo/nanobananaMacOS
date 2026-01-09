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
    static let minCharacterCount = 0  // 0人も許容（NO HUMANS VISIBLEシーン用）
    static let maxCharacterCount = 3
    static let minActorCount = 1
    static let maxActorCount = 3
    static let minWardrobeCount = 1
    static let maxWardrobeCount = 10

    // MARK: - Actors (登場人物)
    @Published var actors: [ActorEntry] = []

    // MARK: - Wardrobes (衣装)
    @Published var wardrobes: [WardrobeEntry] = []

    // MARK: - Registered (登録済み)
    @Published var registeredActors: [ActorEntry] = []
    @Published var registeredWardrobes: [WardrobeEntry] = []

    // MARK: - Panels
    @Published var panels: [MangaPanel] = []

    private var cancellables: Set<AnyCancellable> = []

    init() {
        // 初期アクターを追加
        let initialActor = ActorEntry()
        actors = [initialActor]
        observeActor(initialActor)

        // 初期衣装を追加
        let initialWardrobe = WardrobeEntry(index: 1)
        wardrobes = [initialWardrobe]
        observeWardrobe(initialWardrobe)

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

    /// アクターの変更を監視
    private func observeActor(_ actor: ActorEntry) {
        actor.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    /// 衣装の変更を監視
    private func observeWardrobe(_ wardrobe: WardrobeEntry) {
        wardrobe.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties (Actors)

    /// アクターを追加可能か
    var canAddActor: Bool {
        actors.count < Self.maxActorCount
    }

    /// アクターを削除可能か
    var canRemoveActor: Bool {
        actors.count > Self.minActorCount
    }

    // MARK: - Computed Properties (Wardrobes)

    /// 衣装を追加可能か
    var canAddWardrobe: Bool {
        wardrobes.count < Self.maxWardrobeCount
    }

    /// 衣装を削除可能か
    var canRemoveWardrobe: Bool {
        wardrobes.count > Self.minWardrobeCount
    }

    // MARK: - Computed Properties (Panels)

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

    /// 登録済みのアクターがあるか
    var hasRegisteredActors: Bool {
        !registeredActors.isEmpty
    }

    /// 登録済みの衣装があるか
    var hasRegisteredWardrobes: Bool {
        !registeredWardrobes.isEmpty
    }

    // MARK: - Actions (Actors)

    /// アクターを追加
    func addActor() {
        guard canAddActor else { return }
        let newActor = ActorEntry()
        actors.append(newActor)
        observeActor(newActor)
    }

    /// アクターを削除
    func removeActor(at index: Int) {
        guard canRemoveActor, actors.indices.contains(index) else { return }
        actors.remove(at: index)
    }

    // MARK: - Actions (Wardrobes)

    /// 衣装を追加
    func addWardrobe() {
        guard canAddWardrobe else { return }
        let newWardrobe = WardrobeEntry(index: wardrobes.count + 1)
        wardrobes.append(newWardrobe)
        observeWardrobe(newWardrobe)
    }

    /// 衣装を削除
    func removeWardrobe(at index: Int) {
        guard canRemoveWardrobe, wardrobes.indices.contains(index) else { return }
        wardrobes.remove(at: index)
    }

    // MARK: - Actions (Registration)

    /// アクターと衣装を登録
    func registerActorsAndWardrobes() {
        // 有効なアクターのみ登録
        registeredActors = actors.filter { $0.isValid }
        // 有効な衣装のみ登録
        registeredWardrobes = wardrobes.filter { $0.isValid }
    }

    /// 登録をクリア
    func clearRegistration() {
        registeredActors = []
        registeredWardrobes = []
    }

    /// アクターと衣装の入力をクリア
    func clearActorsAndWardrobes() {
        cancellables.removeAll()

        // アクターをリセット
        let initialActor = ActorEntry()
        actors = [initialActor]
        observeActor(initialActor)

        // 衣装をリセット
        let initialWardrobe = WardrobeEntry(index: 1)
        wardrobes = [initialWardrobe]
        observeWardrobe(initialWardrobe)

        // 登録もクリア
        clearRegistration()

        // パネルの監視を再設定
        for panel in panels {
            observePanel(panel)
        }
    }

    // MARK: - Actions (Panels)

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

        // アクターをリセット
        let initialActor = ActorEntry()
        actors = [initialActor]
        observeActor(initialActor)

        // 衣装をリセット
        let initialWardrobe = WardrobeEntry(index: 1)
        wardrobes = [initialWardrobe]
        observeWardrobe(initialWardrobe)

        // 登録をクリア
        registeredActors = []
        registeredWardrobes = []

        // パネルをリセット
        let initialPanel = MangaPanel()
        panels = [initialPanel]
        observePanel(initialPanel)
    }

    // MARK: - Apply (位置情報追記)

    /// 適用時に各コマのシーンに位置情報を追記
    /// インポートされたパネルはスキップ（YAMLに既に位置情報が含まれている）
    func appendPositionInfoToScenes() {
        for panel in panels {
            // インポートされたパネルはスキップ
            // YAMLに既に位置情報が含まれているため追記しない
            guard !panel.isImported else { continue }

            // 有効なキャラクター（アクターが選択されている）を取得
            let validCharacters = panel.characters.filter { $0.selectedActorId != nil }
            guard !validCharacters.isEmpty else { continue }

            // 各キャラクターの名前を取得
            let characterNames: [String] = validCharacters.compactMap { character in
                guard let actorId = character.selectedActorId,
                      let actor = registeredActors.first(where: { $0.id == actorId }) else {
                    return nil
                }
                return actor.name
            }

            // 位置情報テキストを生成
            let positionText = generatePositionText(for: characterNames)

            // シーンに追記（既に位置情報がなければ）
            if !positionText.isEmpty && !panel.scene.contains("左:") && !panel.scene.contains("中央:") && !panel.scene.contains("右:") {
                panel.scene = panel.scene.trimmingCharacters(in: .whitespaces) + " " + positionText
            }
        }
    }

    /// キャラクター名から位置情報テキストを生成
    private func generatePositionText(for names: [String]) -> String {
        switch names.count {
        case 1:
            // 1人: 中央
            return "中央:\(names[0])"
        case 2:
            // 2人: 左、右
            return "左:\(names[0])、右:\(names[1])"
        case 3:
            // 3人: 左、真ん中、右
            return "左:\(names[0])、真ん中:\(names[1])、右:\(names[2])"
        default:
            return ""
        }
    }

    // MARK: - Import (YAML読み込み)

    /// YAMLインポート結果を反映
    func applyImportedStory(
        yaml: MangaStoryYAML,
        matchResults: [CharacterMatchResult],
        savedCharacters: [SavedCharacter]
    ) {
        // Combineの監視をクリア
        cancellables.removeAll()

        // 1. アクターを再構築
        applyActors(from: matchResults, savedCharacters: savedCharacters)

        // 2. パネルを再構築
        applyPanels(from: yaml.panels ?? [], matchResults: matchResults)
    }

    private func applyActors(
        from matchResults: [CharacterMatchResult],
        savedCharacters: [SavedCharacter]
    ) {
        actors = []

        for result in matchResults {
            guard let matched = result.matchedCharacter else { continue }

            let actor = ActorEntry()
            actor.selectCharacter(matched)
            // faceSheetPath は空のまま（手動入力）
            actors.append(actor)
            observeActor(actor)
        }

        // 最低1人は必要
        if actors.isEmpty {
            let initialActor = ActorEntry()
            actors = [initialActor]
            observeActor(initialActor)
        }
    }

    private func applyPanels(
        from yamlPanels: [MangaStoryPanel],
        matchResults: [CharacterMatchResult]
    ) {
        panels = []

        for yamlPanel in yamlPanels {
            // インポート用の初期化（初期キャラクターなし）
            let panel = MangaPanel(forImport: true)
            panel.scene = yamlPanel.scene ?? ""
            panel.narration = yamlPanel.narration ?? ""
            panel.hasMobCharacters = yamlPanel.mob ?? false

            // キャラクターを設定
            applyPanelCharacters(
                to: panel,
                from: yamlPanel.characters ?? [],
                matchResults: matchResults
            )

            panels.append(panel)
            observePanel(panel)
        }

        // 最低1コマは必要
        if panels.isEmpty {
            let initialPanel = MangaPanel()
            panels = [initialPanel]
            observePanel(initialPanel)
        }
    }

    private func applyPanelCharacters(
        to panel: MangaPanel,
        from yamlCharacters: [MangaStoryPanelCharacter],
        matchResults: [CharacterMatchResult]
    ) {
        panel.characters = []

        for yamlChar in yamlCharacters {
            let character = PanelCharacter()
            character.dialogue = yamlChar.dialogue ?? ""
            character.features = yamlChar.features ?? ""
            // YAMLからインポートされたキャラクターとしてマーク
            // features結合をスキップするため
            character.isImported = true

            // 名前からアクターを検索してIDを設定
            if let name = yamlChar.name,
               let matchResult = matchResults.first(where: { $0.yamlName == name }),
               let matchedChar = matchResult.matchedCharacter {
                // アクターリストから該当するactorIdを検索
                if let actor = actors.first(where: { $0.name == matchedChar.name }) {
                    character.selectedActorId = actor.id
                }
            }

            // selectedWardrobeId は nil のまま（手動選択）

            panel.characters.append(character)
            panel.observeCharacter(character)
        }
        // キャラクター0人も許容（NO HUMANS VISIBLEシーン用）
    }
}

// MARK: - Manga Panel
/// 漫画の1コマ分のデータ
final class MangaPanel: ObservableObject, Identifiable {
    let id = UUID()

    // MARK: - Panel Content
    @Published var scene: String = ""           // シーン説明（必須）
    @Published var narration: String = ""       // ナレーション（任意）
    @Published var narrationPosition: NarrationPosition = .auto  // ナレーション位置
    @Published var hasMobCharacters: Bool = false  // モブキャラを含める
    @Published var drawMobsClearly: Bool = false   // モブキャラもしっかり描く（被写界深度なし）

    // MARK: - Import Flag
    /// YAMLからインポートされたパネルかどうか
    /// true: scene/featuresはYAMLの内容をそのまま使用（位置情報追記・特徴結合をスキップ）
    var isImported: Bool = false

    // MARK: - Characters (1〜3人)
    @Published var characters: [PanelCharacter] = []

    private var cancellables: Set<AnyCancellable> = []

    /// 通常の初期化（キャラクター0人で開始）
    init() {
        // キャラクターは「+」ボタンで追加する
        characters = []
    }

    /// インポート用の初期化（キャラクターなしで作成）
    init(forImport: Bool) {
        // キャラクターは後から設定する
        self.isImported = forImport
    }

    /// 監視をクリア（インポート時に使用）
    func clearObservers() {
        cancellables.removeAll()
    }

    /// キャラクターの変更を監視
    /// インポート時に外部から呼び出せるようinternalに変更
    func observeCharacter(_ character: PanelCharacter) {
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
        // シーンが必須（キャラクター0人でもシーンがあればOK）
        hasScene
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

// MARK: - Bubble Style
/// 吹き出し形状の定義
enum BubbleStyle: String, CaseIterable {
    case auto = "auto"
    case normal = "normal"
    case scream = "scream"
    case shout = "shout"
    case thought = "thought"

    /// UI表示用のラベル
    var displayLabel: String {
        switch self {
        case .auto: return "AIにおまかせ"
        case .normal: return "通常"
        case .scream: return "叫び"
        case .shout: return "大声"
        case .thought: return "心の声"
        }
    }
}

// MARK: - Render Mode
/// 描画モードの定義
enum RenderMode: String, CaseIterable {
    case fullBody = "full_body"
    case bubbleOnly = "bubble_only"

    /// UI表示用のラベル
    var displayLabel: String {
        switch self {
        case .fullBody: return "体を描く"
        case .bubbleOnly: return "吹き出しのみ"
        }
    }
}

// MARK: - Character Position
/// キャラクター配置位置の定義
enum CharacterPosition: String, CaseIterable {
    case auto = "auto"
    case left = "on the left side"
    case center = "center"
    case right = "on the right side"

    /// UI表示用のラベル
    var displayLabel: String {
        switch self {
        case .auto: return "AIにおまかせ"
        case .left: return "左"
        case .center: return "中央"
        case .right: return "右"
        }
    }

    /// YAML出力時のソート優先度（明示的な位置指定を優先）
    /// left → center → right → auto の順
    var sortPriority: Int {
        switch self {
        case .left: return 0
        case .center: return 1
        case .right: return 2
        case .auto: return 3
        }
    }
}

// MARK: - Panel Character
/// コマ内のキャラクター情報（登録されたアクター・衣装から選択）
final class PanelCharacter: ObservableObject, Identifiable {
    let id = UUID()

    @Published var selectedActorId: UUID?       // 選択されたアクターのID
    @Published var selectedWardrobeId: UUID?    // 選択された衣装のID
    @Published var renderMode: RenderMode = .fullBody  // 描画モード（デフォルト: full_body）
    @Published var position: CharacterPosition = .auto  // 配置位置（デフォルト: auto）
    @Published var dialogue: String = ""        // セリフ
    @Published var bubbleStyle: BubbleStyle = .auto  // 吹き出し形状（デフォルト: auto）
    @Published var features: String = ""        // 特徴（表情・ポーズ）

    // MARK: - Import Flag
    /// YAMLからインポートされたキャラクターかどうか
    /// true: featuresはYAMLの内容のみ使用（アクター特徴・衣装特徴との結合をスキップ）
    var isImported: Bool = false

    // MARK: - Legacy (後方互換性)
    @Published var name: String = ""            // キャラクター名（相対位置参照用、必須）
    @Published var imagePath: String = ""       // キャラクター画像パス

    /// 有効か（アクターと衣装が選択されているか）
    var isValid: Bool {
        selectedActorId != nil && selectedWardrobeId != nil
    }

    /// 名前が入力されているか（後方互換性）
    var hasName: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 選択されたアクター名を取得（表示用）
    func getActorName(from actors: [ActorEntry]) -> String {
        guard let actorId = selectedActorId,
              let actor = actors.first(where: { $0.id == actorId }) else {
            return "(未選択)"
        }
        return actor.name
    }

    /// 選択された衣装ラベルを取得（表示用）
    func getWardrobeLabel(from wardrobes: [WardrobeEntry]) -> String {
        guard let wardrobeId = selectedWardrobeId,
              let wardrobe = wardrobes.first(where: { $0.id == wardrobeId }) else {
            return "(未選択)"
        }
        return wardrobe.displayLabel
    }
}

// MARK: - Actor Entry
/// 登場人物の定義（顔三面図ベース）
final class ActorEntry: ObservableObject, Identifiable {
    let id = UUID()

    @Published var selectedCharacterId: UUID?       // 選択されたキャラクターのID（データベースから）
    @Published var name: String = ""                // キャラクタ名（選択時に自動設定）
    @Published var faceSheetPath: String = ""       // 顔三面図パス（必須、都度入力）
    @Published var faceFeatures: String = ""        // 顔の特徴（選択時に自動設定）
    @Published var bodyFeatures: String = ""        // 体型の特徴（選択時に自動設定）
    @Published var personality: String = ""         // パーソナリティ（選択時に自動設定）

    /// キャラクターを選択して自動入力
    func selectCharacter(_ character: SavedCharacter) {
        selectedCharacterId = character.id
        name = character.name
        faceFeatures = character.faceFeatures
        bodyFeatures = character.bodyFeatures
        personality = character.personality
    }

    /// 選択をクリア
    func clearSelection() {
        selectedCharacterId = nil
        name = ""
        faceFeatures = ""
        bodyFeatures = ""
        personality = ""
    }

    /// 有効か（必須項目が入力されているか）
    var isValid: Bool {
        selectedCharacterId != nil &&
        !faceSheetPath.isEmpty &&
        !faceFeatures.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 表示用ラベル（ドロップダウン用）
    var displayLabel: String {
        name.isEmpty ? "(未設定)" : name
    }
}

// MARK: - Wardrobe Entry
/// 衣装の定義（衣装三面図ベース）
final class WardrobeEntry: ObservableObject, Identifiable {
    let id = UUID()
    let index: Int  // 衣装番号（1〜10）

    /// 手動入力モード選択用の特殊値
    static let manualInputKey = "__manual_input__"

    @Published var name: String = ""                // 衣装名（DBから選択 or 手動入力）
    @Published var outfitSheetPath: String = ""     // 衣装三面図パス（必須）
    @Published var features: String = ""            // 衣装の説明（DBから自動入力、編集可）
    @Published var isManualInput: Bool = false      // 手動入力モードかどうか
    @Published var manualName: String = ""          // 手動入力時の衣装名

    init(index: Int) {
        self.index = index
    }

    /// 有効か（衣装三面図が設定されているか）
    var isValid: Bool {
        !outfitSheetPath.isEmpty
    }

    /// 表示用ラベル（ドロップダウン用）
    var displayLabel: String {
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        let indexLabel = index >= 1 && index <= 10 ? labels[index - 1] : "\(index)"
        return "衣装\(indexLabel)"
    }

    /// 実際に使用する衣装名（DB選択時はname、手動入力時はmanualName）
    var effectiveName: String {
        isManualInput ? manualName : name
    }

    /// 登録済み衣装を選択して自動入力
    func selectSavedWardrobe(_ saved: SavedWardrobe) {
        name = saved.name
        features = saved.description
        isManualInput = false
        manualName = ""
    }

    /// 手動入力モードに切り替え
    func switchToManualInput() {
        isManualInput = true
        name = Self.manualInputKey
        // featuresとmanualNameはユーザーが入力するのでクリアしない
    }

    /// 選択解除（未選択状態に戻す）
    func clearSelection() {
        isManualInput = false
        name = ""
        manualName = ""
        features = ""
    }
}
