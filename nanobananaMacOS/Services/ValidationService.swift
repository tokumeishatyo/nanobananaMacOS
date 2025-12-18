import Foundation

/// バリデーション結果
enum ValidationResult {
    case success
    case failure(message: String)
}

/// バリデーションサービスプロトコル
protocol ValidationServiceProtocol {
    func validateForYAMLGeneration(mainViewModel: MainViewModel) -> ValidationResult
}

/// バリデーションサービス実装
final class ValidationService: ValidationServiceProtocol {

    /// YAML生成前のバリデーション
    /// - Parameter mainViewModel: メインビューモデル
    /// - Returns: バリデーション結果
    @MainActor
    func validateForYAMLGeneration(mainViewModel: MainViewModel) -> ValidationResult {
        // 1. タイトル必須チェック
        if mainViewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .failure(message: "タイトルを入力してください")
        }

        // 2. 詳細設定チェック
        if !mainViewModel.isSettingsConfigured {
            return .failure(message: "詳細設定を行ってください")
        }

        // 3. 出力タイプに応じた設定存在チェック
        let settingsCheckResult = validateSettingsForOutputType(mainViewModel: mainViewModel)
        if case .failure = settingsCheckResult {
            return settingsCheckResult
        }

        return .success
    }

    /// 出力タイプに応じた設定の存在チェック
    @MainActor
    private func validateSettingsForOutputType(mainViewModel: MainViewModel) -> ValidationResult {
        switch mainViewModel.selectedOutputType {
        case .faceSheet:
            guard mainViewModel.faceSheetSettings != nil else {
                return .failure(message: "顔三面図の詳細設定を行ってください")
            }
            // 外見説明は必須
            if let settings = mainViewModel.faceSheetSettings,
               settings.appearanceDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .failure(message: "外見説明を入力してください")
            }

        case .bodySheet:
            guard mainViewModel.bodySheetSettings != nil else {
                return .failure(message: "素体三面図の詳細設定を行ってください")
            }

        case .outfit:
            guard mainViewModel.outfitSettings != nil else {
                return .failure(message: "衣装着用の詳細設定を行ってください")
            }

        case .pose:
            guard mainViewModel.poseSettings != nil else {
                return .failure(message: "ポーズの詳細設定を行ってください")
            }

        case .sceneBuilder:
            guard mainViewModel.sceneBuilderSettings != nil else {
                return .failure(message: "シーンビルダーの詳細設定を行ってください")
            }

        case .background:
            guard mainViewModel.backgroundSettings != nil else {
                return .failure(message: "背景生成の詳細設定を行ってください")
            }

        case .decorativeText:
            guard mainViewModel.decorativeTextSettings != nil else {
                return .failure(message: "装飾テキストの詳細設定を行ってください")
            }

        case .fourPanelManga:
            guard mainViewModel.fourPanelSettings != nil else {
                return .failure(message: "4コマ漫画の詳細設定を行ってください")
            }

        case .styleTransform:
            guard mainViewModel.styleTransformSettings != nil else {
                return .failure(message: "スタイル変換の詳細設定を行ってください")
            }

        case .infographic:
            guard mainViewModel.infographicSettings != nil else {
                return .failure(message: "インフォグラフィックの詳細設定を行ってください")
            }
        }

        return .success
    }
}
