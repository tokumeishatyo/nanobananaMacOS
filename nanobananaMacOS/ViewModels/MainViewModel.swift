import Foundation
import SwiftUI
import Combine

/// メイン画面のViewModel
@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Left Column (基本設定)

    /// 出力タイプ
    @Published var selectedOutputType: OutputType = .faceSheet

    /// カラーモード
    @Published var selectedColorMode: ColorMode = .fullColor

    /// 二色刷りカラー（カラーモードが二色刷りの場合のみ使用）
    @Published var selectedDuotoneColor: DuotoneColor = .blueBlack

    /// 出力スタイル
    @Published var selectedOutputStyle: OutputStyle = .anime

    /// アスペクト比
    @Published var selectedAspectRatio: AspectRatio = .square

    /// タイトル
    @Published var title: String = ""

    /// 画像にタイトルを入れるか
    @Published var includeTitleInImage: Bool = false

    /// 作者名
    @Published var authorName: String = ""

    /// 設定済みかどうか
    @Published var isSettingsConfigured: Bool = false

    // MARK: - Middle Column (API設定)

    /// 出力モード
    @Published var selectedOutputMode: OutputMode = .yaml

    /// APIキー（メモリ上のみ保持、保存しない）
    @Published var apiKey: String = ""

    /// APIサブモード
    @Published var selectedAPISubMode: APISubMode = .normal

    /// 参考画像パス
    @Published var referenceImagePath: String = ""

    /// 追加指示（清書モード用）
    @Published var redrawInstruction: String = ""

    /// シンプルプロンプト（シンプルモード用）
    @Published var simplePrompt: String = ""

    /// 解像度
    @Published var selectedResolution: Resolution = .twoK

    /// API使用回数（今日）
    @Published var todayUsageCount: Int = 0

    /// API使用回数（今月）
    @Published var monthlyUsageCount: Int = 0

    // MARK: - Right Column (プレビュー)

    /// YAMLプレビューテキスト
    @Published var yamlPreviewText: String = ""

    /// 生成画像
    @Published var generatedImage: NSImage? = nil

    /// 参考画像プレビュー
    @Published var referenceImagePreview: NSImage? = nil

    // MARK: - State

    /// 生成中かどうか
    @Published var isGenerating: Bool = false

    /// 生成開始時間（経過時間表示用）
    @Published var generationStartTime: Date? = nil

    /// エラーメッセージ
    @Published var errorMessage: String? = nil

    /// 設定シート表示フラグ
    @Published var showSettingsSheet: Bool = false

    /// 設定ステータステキスト
    var settingsStatusText: String {
        if selectedOutputMode == .api {
            switch selectedAPISubMode {
            case .redraw:
                return "清書モード: YAML読込+参照画像が必要"
            case .simple:
                return "シンプルモード: 画像+プロンプトのみ"
            case .normal:
                return isSettingsConfigured ? "設定: 設定済み ✓" : "設定: 未設定"
            }
        }
        return isSettingsConfigured ? "設定: 設定済み ✓" : "設定: 未設定"
    }

    /// 設定ステータスカラー
    var settingsStatusColor: Color {
        if selectedOutputMode == .api {
            switch selectedAPISubMode {
            case .redraw:
                return .blue
            case .simple:
                return .purple
            case .normal:
                return isSettingsConfigured ? .green : .gray
            }
        }
        return isSettingsConfigured ? .green : .gray
    }

    /// API使用状況テキスト
    var usageStatusText: String {
        "今日: \(todayUsageCount)回 | 今月: \(monthlyUsageCount)回"
    }

    /// APIモードが有効かどうか
    var isAPIModeEnabled: Bool {
        selectedOutputMode == .api
    }

    /// 詳細設定ボタンが有効かどうか
    var isSettingsButtonEnabled: Bool {
        if selectedOutputMode == .api {
            return selectedAPISubMode == .normal
        }
        return true
    }

    /// 画像生成ボタンが有効かどうか
    var isAPIGenerateButtonEnabled: Bool {
        guard isAPIModeEnabled else { return false }
        guard !apiKey.isEmpty else { return false }

        switch selectedAPISubMode {
        case .simple:
            return true
        case .redraw:
            return !yamlPreviewText.isEmpty && !referenceImagePath.isEmpty
        case .normal:
            return !yamlPreviewText.isEmpty
        }
    }

    /// 画像保存ボタンが有効かどうか
    var isSaveImageButtonEnabled: Bool {
        generatedImage != nil
    }

    /// 画像加工ボタンが有効かどうか
    var isRefineImageButtonEnabled: Bool {
        generatedImage != nil
    }

    // MARK: - Actions

    /// YAML生成
    func generateYAML() {
        // TODO: 機能実装時に追加
        print("YAML生成")
    }

    /// リセット（APIキー以外）
    func resetAll() {
        // 出力タイプをデフォルトに
        selectedOutputType = .faceSheet

        // スタイル設定をデフォルトに
        selectedColorMode = .fullColor
        selectedDuotoneColor = .blueBlack
        selectedOutputStyle = .anime
        selectedAspectRatio = .square

        // 基本情報をクリア
        title = ""
        includeTitleInImage = false
        authorName = ""

        // 設定状態をリセット
        isSettingsConfigured = false

        // API設定（APIキーは保持）
        selectedOutputMode = .yaml
        selectedAPISubMode = .normal
        referenceImagePath = ""
        redrawInstruction = ""
        simplePrompt = ""
        selectedResolution = .twoK
        referenceImagePreview = nil

        // プレビューをクリア
        yamlPreviewText = ""
        generatedImage = nil

        // 状態をリセット
        isGenerating = false
        generationStartTime = nil
        errorMessage = nil
    }

    /// APIキーをクリア
    func clearAPIKey() {
        apiKey = ""
    }

    /// 参考画像を選択
    func browseReferenceImage() {
        // TODO: 機能実装時に追加
        print("参考画像選択")
    }

    /// 画像生成（API）
    func generateImageWithAPI() {
        // TODO: 機能実装時に追加
        print("画像生成（API）")
    }

    /// YAMLをコピー
    func copyYAML() {
        // TODO: 機能実装時に追加
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(yamlPreviewText, forType: .string)
    }

    /// YAMLを保存
    func saveYAML() {
        // TODO: 機能実装時に追加
        print("YAML保存")
    }

    /// YAMLを読込
    func loadYAML() {
        // TODO: 機能実装時に追加
        print("YAML読込")
    }

    /// 画像を保存
    func saveImage() {
        // TODO: 機能実装時に追加
        print("画像保存")
    }

    /// 画像を加工
    func refineImage() {
        // TODO: 機能実装時に追加
        print("画像加工")
    }

    /// 詳細設定を開く
    func openSettingsWindow() {
        let windowId = "settings-\(selectedOutputType.internalKey)"
        let title = "\(selectedOutputType.rawValue)設定"

        switch selectedOutputType {
        case .faceSheet:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 600, height: 400)
            ) { [weak self] in
                FaceSheetSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .bodySheet:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 650)
            ) { [weak self] in
                BodySheetSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .outfit:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 780, height: 750)
            ) { [weak self] in
                OutfitSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .pose:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 800)
            ) { [weak self] in
                PoseSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .sceneBuilder:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 850, height: 900)
            ) { [weak self] in
                SceneBuilderSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .background:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 500, height: 470)
            ) { [weak self] in
                BackgroundSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .decorativeText:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 650, height: 650)
            ) { [weak self] in
                DecorativeTextSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .fourPanelManga:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 800, height: 1000)
            ) { [weak self] in
                FourPanelSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .styleTransform:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 600)
            ) { [weak self] in
                StyleTransformSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        case .infographic:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 750, height: 1000)
            ) { [weak self] in
                InfographicSettingsView { _ in
                    self?.isSettingsConfigured = true
                }
            }
        }
    }

    /// 漫画コンポーザーを開く
    func openMangaComposer() {
        // TODO: 機能実装時に追加
        print("漫画コンポーザー")
    }

    /// 画像ツール（背景透過）を開く
    func openBackgroundRemover() {
        // TODO: 機能実装時に追加
        print("背景透過ツール")
    }

    /// 使用量詳細を表示
    func showUsageDetails() {
        // TODO: 機能実装時に追加
        print("使用量詳細")
    }
}
