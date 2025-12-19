import Foundation

/// テンプレートエンジン
/// 外部テンプレートファイルからYAMLを生成するメインクラス
final class TemplateEngine {

    // MARK: - Properties

    private let parser: TemplateParser
    private let renderer: SectionRenderer
    private let resolver: VariableResolver

    private var masterTemplateContent: String?
    private var selectionMapContent: String?

    private var isLoaded: Bool = false

    // MARK: - Singleton

    static let shared = TemplateEngine()

    // MARK: - Initialization

    init() {
        self.parser = TemplateParser()
        self.renderer = SectionRenderer(parser: parser)
        self.resolver = VariableResolver()
    }

    // MARK: - Public Methods

    /// テンプレートファイルを読み込む
    func loadTemplates() throws {
        guard !isLoaded else { return }

        // MasterTemplate.yaml を読み込み
        guard let masterTemplateURL = Bundle.main.url(
            forResource: "MasterTemplate",
            withExtension: "yaml",
            subdirectory: "Templates"
        ) else {
            throw TemplateEngineError.fileNotFound("MasterTemplate.yaml")
        }

        masterTemplateContent = try String(contentsOf: masterTemplateURL, encoding: .utf8)

        // SelectionMap.yaml を読み込み
        guard let selectionMapURL = Bundle.main.url(
            forResource: "SelectionMap",
            withExtension: "yaml",
            subdirectory: "Templates"
        ) else {
            throw TemplateEngineError.fileNotFound("SelectionMap.yaml")
        }

        selectionMapContent = try String(contentsOf: selectionMapURL, encoding: .utf8)

        isLoaded = true
    }

    /// 開発用: 外部パスからテンプレートを読み込む
    func loadTemplates(masterTemplatePath: String, selectionMapPath: String) throws {
        masterTemplateContent = try String(contentsOfFile: masterTemplatePath, encoding: .utf8)
        selectionMapContent = try String(contentsOfFile: selectionMapPath, encoding: .utf8)
        isLoaded = true
    }

    /// YAMLを生成
    @MainActor
    func generateYAML(
        outputType: OutputType,
        mainViewModel: MainViewModel
    ) throws -> String {
        // テンプレートが読み込まれていない場合は読み込み
        if !isLoaded {
            try loadTemplates()
        }

        guard let masterTemplate = masterTemplateContent,
              let selectionMap = selectionMapContent else {
            throw TemplateEngineError.fileNotFound("Templates not loaded")
        }

        // 変数を解決
        let variables = resolver.resolveVariables(
            outputType: outputType,
            mainViewModel: mainViewModel
        )

        // セクションキーを決定
        let selectionKey = getSelectionKey(outputType: outputType, mainViewModel: mainViewModel)

        // セクションリストを取得
        let sectionNames = parser.extractSectionList(from: selectionMap, selectionKey: selectionKey)

        if sectionNames.isEmpty {
            throw TemplateEngineError.unknownOutputType(outputType.templateKey)
        }

        // ヘッダー値を取得
        let headerValues = parser.extractHeaderValues(from: masterTemplate, outputType: outputType.templateKey)

        // 変数にヘッダー値を追加
        var allVariables = variables
        for (key, value) in headerValues {
            allVariables.set(key, value)
        }

        // 各セクションをレンダリング
        var yamlParts: [String] = []

        for sectionName in sectionNames {
            if let sectionYAML = try renderSection(
                sectionName: sectionName,
                outputType: outputType,
                masterTemplate: masterTemplate,
                variables: allVariables
            ) {
                yamlParts.append(sectionYAML)
            }
        }

        // 結合して返す
        return yamlParts.joined(separator: "\n")
    }

    // MARK: - Private Methods

    /// セクションをレンダリング
    private func renderSection(
        sectionName: String,
        outputType: OutputType,
        masterTemplate: String,
        variables: TemplateVariables
    ) throws -> String? {
        // まず出力タイプ固有のセクションを探す
        if let template = parser.extractSectionTemplate(
            from: masterTemplate,
            outputType: outputType.templateKey,
            sectionName: sectionName
        ) {
            return try renderer.render(template: template, variables: variables)
        }

        // 見つからない場合は共通セクションを探す
        if let template = parser.extractCommonSectionTemplate(
            from: masterTemplate,
            sectionName: sectionName
        ) {
            return try renderer.render(template: template, variables: variables)
        }

        // 条件付きセクション（title_overlay等）は存在しなくてもOK
        let optionalSections = ["title_overlay", "reference_image", "bonus_character"]
        if optionalSections.contains(sectionName) {
            return nil
        }

        // 見つからない場合は警告（エラーにはしない）
        print("Warning: Section '\(sectionName)' not found for output type '\(outputType.templateKey)'")
        return nil
    }

    /// 出力タイプとモードからセクションキーを決定
    @MainActor
    private func getSelectionKey(outputType: OutputType, mainViewModel: MainViewModel) -> String {
        switch outputType {
        case .faceSheet:
            return "face_sheet"

        case .bodySheet:
            return "body_sheet"

        case .outfit:
            // プリセット/参考画像モードで分岐（useOutfitBuilder = false が参考画像モード）
            let isReferenceMode = mainViewModel.outfitSettings.map { !$0.useOutfitBuilder } ?? false
            return isReferenceMode ? "outfit_sheet_reference" : "outfit_sheet_preset"

        case .pose:
            // プリセット/参考画像モードで分岐（usePoseCapture = true が参考画像モード）
            let isReferenceMode = mainViewModel.poseSettings.map { $0.usePoseCapture } ?? false
            return isReferenceMode ? "pose_reference" : "pose_preset"

        case .sceneBuilder:
            // シーンタイプで分岐
            guard let settings = mainViewModel.sceneBuilderSettings else {
                return "scene_builder_story"
            }
            switch settings.sceneType {
            case .story:
                return "scene_builder_story"
            case .battle:
                return "scene_builder_battle"
            case .bossRaid:
                return "scene_builder_boss_raid"
            }

        case .background:
            // 参考画像の有無で分岐
            guard let settings = mainViewModel.backgroundSettings else {
                return "background_without_reference"
            }
            let useReference = settings.useReferenceImage && !settings.referenceImagePath.isEmpty
            return useReference ? "background_with_reference" : "background_without_reference"

        case .decorativeText:
            return "decorative_text"

        case .fourPanelManga:
            return "four_panel"

        case .styleTransform:
            // 透過背景の有無で分岐
            let useTransparent = mainViewModel.styleTransformSettings?.transparentBackground ?? false
            return useTransparent ? "style_transform_transparent" : "style_transform_normal"

        case .infographic:
            return "infographic"
        }
    }
}

// MARK: - Debug Methods

extension TemplateEngine {

    /// テンプレートの読み込み状態を確認
    func debugPrintLoadStatus() {
        print("=== TemplateEngine Status ===")
        print("isLoaded: \(isLoaded)")
        print("masterTemplate: \(masterTemplateContent != nil ? "loaded (\(masterTemplateContent!.count) chars)" : "not loaded")")
        print("selectionMap: \(selectionMapContent != nil ? "loaded (\(selectionMapContent!.count) chars)" : "not loaded")")
    }

    /// セクションリストをデバッグ出力
    func debugPrintSections(for selectionKey: String) {
        guard let selectionMap = selectionMapContent else {
            print("Selection map not loaded")
            return
        }

        let sections = parser.extractSectionList(from: selectionMap, selectionKey: selectionKey)
        print("=== Sections for '\(selectionKey)' ===")
        for (index, section) in sections.enumerated() {
            print("\(index + 1). \(section)")
        }
    }
}
