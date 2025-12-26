// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

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

    /// 出力タイプ変更確認ダイアログ表示フラグ
    @Published var showOutputTypeChangeConfirmation: Bool = false

    /// 変更前の出力タイプ（キャンセル時に戻す用）
    private var previousOutputType: OutputType = .faceSheet

    // MARK: - Settings Storage (各出力タイプの設定保持)

    /// 顔三面図設定
    @Published var faceSheetSettings: FaceSheetSettingsViewModel?

    /// 素体三面図設定
    @Published var bodySheetSettings: BodySheetSettingsViewModel?

    /// 衣装着用設定
    @Published var outfitSettings: OutfitSettingsViewModel?

    /// ポーズ設定
    @Published var poseSettings: PoseSettingsViewModel?

    /// シーンビルダー設定
    @Published var sceneBuilderSettings: SceneBuilderSettingsViewModel?

    /// 背景生成設定
    @Published var backgroundSettings: BackgroundSettingsViewModel?

    /// 装飾テキスト設定
    @Published var decorativeTextSettings: DecorativeTextSettingsViewModel?

    /// 4コマ漫画設定
    @Published var fourPanelSettings: FourPanelSettingsViewModel?

    /// スタイル変換設定
    @Published var styleTransformSettings: StyleTransformSettingsViewModel?

    /// インフォグラフィック設定
    @Published var infographicSettings: InfographicSettingsViewModel?

    /// 登場人物シート設定（漫画コンポーザー）
    @Published var characterSheetSettings: CharacterSheetViewModel?

    /// 登場人物シートYAML生成モード（適用ボタンでtrueになる）
    @Published var isCharacterSheetMode: Bool = false

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

    // MARK: - Services

    /// バリデーションサービス
    private let validationService = ValidationService()

    /// YAML生成サービス
    private let yamlGeneratorService = YAMLGeneratorService()

    /// クリップボードサービス
    private let clipboardService = ClipboardService()

    /// ファイルサービス
    private let fileService = FileService()

    // MARK: - State

    /// 生成中かどうか
    @Published var isGenerating: Bool = false

    /// 生成開始時間（経過時間表示用）
    @Published var generationStartTime: Date? = nil

    /// エラーメッセージ
    @Published var errorMessage: String? = nil

    /// 成功メッセージ
    @Published var successMessage: String? = nil

    /// アラート表示フラグ
    @Published var showAlert: Bool = false

    /// アラートタイトル
    @Published var alertTitle: String = ""

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
            // シンプルモード: プロンプトが入力されていれば活性
            return !simplePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .redraw:
            // 清書モード: YAMLがあれば活性（参考画像はAPI送信前にダイアログで指定）
            return !yamlPreviewText.isEmpty
        case .normal:
            // 通常モード: YAMLがあれば活性
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
        // 登場人物シートモードの場合
        if isCharacterSheetMode {
            generateCharacterSheetYAML()
            return
        }

        // 既存YAMLがある場合は部分更新モード
        if !yamlPreviewText.isEmpty {
            updateExistingYAML()
            return
        }

        // 新規生成モード：バリデーション
        let validationResult = validationService.validateForYAMLGeneration(mainViewModel: self)

        switch validationResult {
        case .success:
            // 出力タイプに応じたYAML生成
            generateYAMLForCurrentOutputType()
        case .failure(let message):
            showErrorAlert(message: message)
        }
    }

    /// 登場人物シートYAML生成
    private func generateCharacterSheetYAML() {
        // タイトル必須チェック
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showErrorAlert(message: "タイトルを入力してください")
            return
        }

        // 設定チェック
        guard let settings = characterSheetSettings else {
            showErrorAlert(message: "登場人物シートの設定がありません。漫画コンポーザーで設定を行ってください。")
            return
        }

        // YAML生成
        yamlPreviewText = yamlGeneratorService.generateCharacterSheetYAML(
            mainViewModel: self,
            settings: settings
        )

        // フラグをリセット
        isCharacterSheetMode = false
    }

    /// 既存YAMLの部分更新（カラーモード、アスペクト比、タイトル、作者名、タイトルオーバーレイ）
    private func updateExistingYAML() {
        // タイトル必須チェック
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showErrorAlert(message: "タイトルを入力してください")
            return
        }

        var yaml = yamlPreviewText

        // 1. トップレベルのtitle:を更新
        let escapedTitle = YAMLUtilities.escapeYAMLString(title)
        let titlePattern = #"(^|\n)(title:\s*)"[^"]*""#
        if let titleRegex = try? NSRegularExpression(pattern: titlePattern, options: []) {
            let range = NSRange(yaml.startIndex..., in: yaml)
            yaml = titleRegex.stringByReplacingMatches(
                in: yaml,
                options: [],
                range: range,
                withTemplate: "$1$2\"\(escapedTitle)\""
            )
        }

        // 2. トップレベルのauthor:を更新（空欄の場合は行ごと削除）
        let trimmedAuthor = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAuthor.isEmpty {
            // author行を削除
            let removeAuthorPattern = #"\nauthor:\s*"[^"]*""#
            if let removeRegex = try? NSRegularExpression(pattern: removeAuthorPattern, options: []) {
                let range = NSRange(yaml.startIndex..., in: yaml)
                yaml = removeRegex.stringByReplacingMatches(in: yaml, options: [], range: range, withTemplate: "")
            }
        } else {
            // author行を更新
            let escapedAuthor = YAMLUtilities.escapeYAMLString(trimmedAuthor)
            let authorPattern = #"(^|\n)(author:\s*)"[^"]*""#
            if let authorRegex = try? NSRegularExpression(pattern: authorPattern, options: []) {
                let range = NSRange(yaml.startIndex..., in: yaml)
                yaml = authorRegex.stringByReplacingMatches(
                    in: yaml,
                    options: [],
                    range: range,
                    withTemplate: "$1$2\"\(escapedAuthor)\""
                )
            }
        }

        // 3. color_modeを個別に更新（styleセクション内のどこにあっても対応）
        let colorModeValue = selectedColorMode.yamlValue
        let colorModePattern = #"(color_mode:\s*)"[^"]*""#
        if let colorModeRegex = try? NSRegularExpression(pattern: colorModePattern, options: []) {
            let range = NSRange(yaml.startIndex..., in: yaml)
            yaml = colorModeRegex.stringByReplacingMatches(
                in: yaml,
                options: [],
                range: range,
                withTemplate: "$1\"\(colorModeValue)\""
            )
        }

        // 4. aspect_ratioを個別に更新（styleセクション内のどこにあっても対応）
        let aspectRatioValue = selectedAspectRatio.yamlValue
        let aspectRatioPattern = #"(aspect_ratio:\s*)"[^"]*""#
        if let aspectRatioRegex = try? NSRegularExpression(pattern: aspectRatioPattern, options: []) {
            let range = NSRange(yaml.startIndex..., in: yaml)
            yaml = aspectRatioRegex.stringByReplacingMatches(
                in: yaml,
                options: [],
                range: range,
                withTemplate: "$1\"\(aspectRatioValue)\""
            )
        }

        // 5. タイトルオーバーレイの更新
        yaml = updateTitleOverlay(in: yaml)

        yamlPreviewText = yaml
        showSuccessAlert(message: "YAMLを更新しました")
    }

    /// タイトルオーバーレイセクションの更新
    private func updateTitleOverlay(in yaml: String) -> String {
        var result = yaml

        // 既存のtitle_overlayセクションを削除（複数行対応）
        // title_overlay: から次のセクション（# または空行2つ）まで
        let removePattern = #"\n?title_overlay:\s*\n(?:  [^\n]*\n)*(?:    [^\n]*\n)*"#
        if let removeRegex = try? NSRegularExpression(pattern: removePattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = removeRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
        }

        // 新しいtitle_overlayを追加（必要な場合）
        let newTitleOverlay = YAMLUtilities.generateTitleOverlay(
            title: title,
            author: authorName,
            includeTitleInImage: includeTitleInImage
        )

        if !newTitleOverlay.isEmpty {
            result += newTitleOverlay
        }

        return result
    }

    /// 現在の出力タイプに応じたYAML生成
    private func generateYAMLForCurrentOutputType() {
        // 設定がnilの場合はエラーメッセージを表示
        if !hasSettingsForCurrentOutputType() {
            showErrorAlert(message: "\(selectedOutputType.rawValue)の詳細設定を行ってください")
            return
        }

        // 統合YAML生成メソッドを使用
        yamlPreviewText = yamlGeneratorService.generateYAML(
            outputType: selectedOutputType,
            mainViewModel: self
        )
    }

    /// 現在の出力タイプに対して設定が存在するかチェック
    private func hasSettingsForCurrentOutputType() -> Bool {
        switch selectedOutputType {
        case .faceSheet:
            return faceSheetSettings != nil
        case .bodySheet:
            return bodySheetSettings != nil
        case .outfit:
            return outfitSettings != nil
        case .pose:
            return poseSettings != nil
        case .sceneBuilder:
            return sceneBuilderSettings != nil
        case .background:
            return backgroundSettings != nil
        case .decorativeText:
            return decorativeTextSettings != nil
        case .fourPanelManga:
            return fourPanelSettings != nil
        case .styleTransform:
            return styleTransformSettings != nil
        case .infographic:
            return infographicSettings != nil
        }
    }

    /// エラーアラートを表示
    private func showErrorAlert(message: String) {
        alertTitle = "エラー"
        errorMessage = message
        successMessage = nil
        showAlert = true
    }

    /// 成功アラートを表示
    private func showSuccessAlert(message: String) {
        alertTitle = "完了"
        errorMessage = nil
        successMessage = message
        showAlert = true
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

        // 各出力タイプの設定をクリア
        faceSheetSettings = nil
        bodySheetSettings = nil
        outfitSettings = nil
        poseSettings = nil
        sceneBuilderSettings = nil
        backgroundSettings = nil
        decorativeTextSettings = nil
        fourPanelSettings = nil
        styleTransformSettings = nil
        infographicSettings = nil

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

    /// 出力タイプ変更を試みる（設定済みの場合は確認ダイアログを表示）
    func willChangeOutputType(to newType: OutputType) {
        // 同じタイプなら何もしない
        guard newType != previousOutputType else { return }

        if isSettingsConfigured {
            // 設定済みの場合は確認ダイアログを表示
            showOutputTypeChangeConfirmation = true
        } else {
            // 未設定の場合はそのまま変更を確定
            previousOutputType = newType
        }
    }

    /// 出力タイプ変更を確定
    func confirmOutputTypeChange() {
        // 現在の出力タイプの設定をクリア
        clearCurrentOutputTypeSettings()
        isSettingsConfigured = false
        // 新しいタイプを記録
        previousOutputType = selectedOutputType
        showOutputTypeChangeConfirmation = false
    }

    /// 出力タイプ変更をキャンセル
    func cancelOutputTypeChange() {
        // 元の出力タイプに戻す
        selectedOutputType = previousOutputType
        showOutputTypeChangeConfirmation = false
    }

    /// 現在の出力タイプの設定のみをクリア
    private func clearCurrentOutputTypeSettings() {
        switch previousOutputType {
        case .faceSheet:
            faceSheetSettings = nil
        case .bodySheet:
            bodySheetSettings = nil
        case .outfit:
            outfitSettings = nil
        case .pose:
            poseSettings = nil
        case .sceneBuilder:
            sceneBuilderSettings = nil
        case .background:
            backgroundSettings = nil
        case .decorativeText:
            decorativeTextSettings = nil
        case .fourPanelManga:
            fourPanelSettings = nil
        case .styleTransform:
            styleTransformSettings = nil
        case .infographic:
            infographicSettings = nil
        }
    }

    /// APIキーをクリア
    func clearAPIKey() {
        apiKey = ""
    }

    /// 参考画像を選択
    func browseReferenceImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.message = "参考画像を選択してください"

        if panel.runModal() == .OK, let url = panel.url {
            referenceImagePath = url.path
            // プレビュー用に画像を読み込み
            if let image = NSImage(contentsOf: url) {
                referenceImagePreview = image
            }
        }
    }

    /// 画像生成（API）
    func generateImageWithAPI() {
        // 生成中なら何もしない
        guard !isGenerating else { return }

        // バリデーション
        guard !apiKey.isEmpty else {
            showErrorAlert(message: "APIキーを入力してください")
            return
        }

        // モードに応じたバリデーション
        let prompt: String
        switch selectedAPISubMode {
        case .simple:
            guard !simplePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                showErrorAlert(message: "プロンプトを入力してください")
                return
            }
            prompt = simplePrompt

            // シンプルモード: 直接API呼び出し
            executeAPICall(prompt: prompt, characterImages: [], compositionImage: nil)

        case .redraw, .normal:
            guard !yamlPreviewText.isEmpty else {
                showErrorAlert(message: "YAMLを生成または読み込んでください")
                return
            }
            prompt = yamlPreviewText

            // YAMLから必要な画像ファイル名を抽出
            let requiredFilenames = YAMLImageExtractor.extractImageFilenames(from: yamlPreviewText)

            if requiredFilenames.isEmpty {
                // 画像ファイルが不要な場合: 直接API呼び出し
                executeAPICall(prompt: prompt, characterImages: [], compositionImage: nil)
            } else {
                // 画像ファイルが必要な場合: ファイル選択ダイアログを表示
                WindowManager.shared.openImageFileSelectionDialog(
                    requiredFilenames: requiredFilenames,
                    onComplete: { [weak self] images in
                        guard let self = self else { return }
                        // 選択された画像をキャラクター画像として渡す
                        let characterImages = Array(images.values)
                        self.executeAPICall(prompt: prompt, characterImages: characterImages, compositionImage: nil)
                    },
                    onCancel: {
                        // キャンセル時は何もしない
                    }
                )
            }
        }
    }

    /// 実際のAPI呼び出しを実行
    private func executeAPICall(prompt: String, characterImages: [NSImage], compositionImage: NSImage?) {
        // 生成開始
        isGenerating = true
        generationStartTime = Date()
        errorMessage = nil

        Task {
            // 参考画像の読み込み（シンプルモードの場合）
            var finalCompositionImage = compositionImage
            if finalCompositionImage == nil,
               !referenceImagePath.isEmpty,
               selectedAPISubMode == .simple {
                finalCompositionImage = NSImage(contentsOfFile: referenceImagePath)
            }

            // API呼び出し
            let result = await GeminiAPIService.shared.generateImage(
                apiKey: apiKey,
                prompt: prompt,
                characterImages: characterImages,
                compositionImage: finalCompositionImage,
                resolution: selectedResolution,
                aspectRatio: selectedAspectRatio.yamlValue,
                mode: selectedAPISubMode.toAPIMode
            )

            // 結果の処理
            isGenerating = false
            generationStartTime = nil

            if result.success, let image = result.image {
                generatedImage = image
                incrementUsageCount()
                showSuccessAlert(message: "画像を生成しました")
            } else if let error = result.error {
                showErrorAlert(message: error.errorDescription ?? "不明なエラー")
            }
        }
    }

    /// 使用回数をインクリメント
    private func incrementUsageCount() {
        todayUsageCount += 1
        monthlyUsageCount += 1
    }

    /// YAMLをコピー
    func copyYAML() {
        guard !yamlPreviewText.isEmpty else {
            showErrorAlert(message: "コピーするYAMLがありません")
            return
        }
        clipboardService.copyToClipboard(text: yamlPreviewText)
        showSuccessAlert(message: "YAMLをクリップボードにコピーしました")
    }

    /// YAMLを保存
    func saveYAML() {
        guard !yamlPreviewText.isEmpty else {
            showErrorAlert(message: "保存するYAMLがありません")
            return
        }

        Task {
            let result = await fileService.saveYAML(
                content: yamlPreviewText,
                suggestedFileName: title.isEmpty ? "output" : title
            )

            switch result {
            case .success:
                showSuccessAlert(message: "YAMLを保存しました")
            case .cancelled:
                // キャンセルは何もしない
                break
            case .failure(let message):
                showErrorAlert(message: message)
            }
        }
    }

    /// YAMLを読込
    func loadYAML() {
        Task {
            let (result, content) = await fileService.loadYAML()

            switch result {
            case .success:
                if let content = content {
                    yamlPreviewText = content
                }
            case .cancelled:
                // キャンセルは何もしない
                break
            case .failure(let message):
                showErrorAlert(message: message)
            }
        }
    }

    /// 画像を保存
    func saveImage() {
        guard let image = generatedImage else {
            showErrorAlert(message: "保存する画像がありません")
            return
        }

        Task {
            let result = await fileService.saveImage(
                image: image,
                suggestedFileName: title.isEmpty ? "image" : title
            )

            switch result {
            case .success:
                showSuccessAlert(message: "画像を保存しました")
            case .cancelled:
                // キャンセルは何もしない
                break
            case .failure(let message):
                showErrorAlert(message: message)
            }
        }
    }

    /// 画像を加工
    func refineImage() {
        // TODO: 機能実装時に追加
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
                FaceSheetSettingsView(initialSettings: self?.faceSheetSettings) { settings in
                    self?.faceSheetSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .bodySheet:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 650)
            ) { [weak self] in
                BodySheetSettingsView(initialSettings: self?.bodySheetSettings) { settings in
                    self?.bodySheetSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .outfit:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 780, height: 750)
            ) { [weak self] in
                OutfitSettingsView(initialSettings: self?.outfitSettings) { settings in
                    self?.outfitSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .pose:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 800)
            ) { [weak self] in
                PoseSettingsView(initialSettings: self?.poseSettings) { settings in
                    self?.poseSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .sceneBuilder:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 850, height: 900)
            ) { [weak self] in
                SceneBuilderSettingsView(initialSettings: self?.sceneBuilderSettings) { settings in
                    self?.sceneBuilderSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .background:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 500, height: 470)
            ) { [weak self] in
                BackgroundSettingsView(initialSettings: self?.backgroundSettings) { settings in
                    self?.backgroundSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .decorativeText:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 650, height: 650)
            ) { [weak self] in
                DecorativeTextSettingsView(initialSettings: self?.decorativeTextSettings) { settings in
                    self?.decorativeTextSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .fourPanelManga:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 800, height: 1000)
            ) { [weak self] in
                FourPanelSettingsView(initialSettings: self?.fourPanelSettings) { settings in
                    self?.fourPanelSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .styleTransform:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 700, height: 600)
            ) { [weak self] in
                StyleTransformSettingsView(initialSettings: self?.styleTransformSettings) { settings in
                    self?.styleTransformSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        case .infographic:
            WindowManager.shared.openWindow(
                id: windowId,
                title: title,
                size: NSSize(width: 750, height: 1000)
            ) { [weak self] in
                InfographicSettingsView(initialSettings: self?.infographicSettings) { settings in
                    self?.infographicSettings = settings
                    self?.isSettingsConfigured = true
                }
            }
        }
    }

    /// 漫画コンポーザーを開く
    func openMangaComposer() {
        WindowManager.shared.openMangaComposerWindow(mainViewModel: self)
    }

    /// 画像ツール（背景透過）を開く
    func openBackgroundRemover() {
        if #available(macOS 14.0, *) {
            WindowManager.shared.openBackgroundRemovalWindow()
        } else {
            showErrorAlert(message: "背景透過ツールはmacOS 14以降で利用可能です")
        }
    }

    /// 使用量詳細を表示
    func showUsageDetails() {
        // TODO: 機能実装時に追加
    }
}
