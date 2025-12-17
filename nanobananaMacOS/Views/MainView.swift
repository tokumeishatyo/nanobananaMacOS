import SwiftUI

/// メイン画面: 3カラムレイアウト
struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        HSplitView {
            // 左カラム: 基本設定
            LeftColumnView(viewModel: viewModel)
                .frame(minWidth: AppConstants.leftColumnWidth, maxWidth: 400)

            // 中央カラム: API設定
            MiddleColumnView(viewModel: viewModel)
                .frame(minWidth: AppConstants.middleColumnWidth, maxWidth: 450)

            // 右カラム: プレビュー
            RightColumnView(viewModel: viewModel)
                .frame(minWidth: 400)
        }
        .frame(
            minWidth: AppConstants.windowMinWidth,
            minHeight: AppConstants.windowMinHeight
        )
        .sheet(isPresented: $viewModel.showSettingsSheet) {
            settingsSheetContent
        }
    }

    /// 出力タイプに応じた設定シートを返す
    @ViewBuilder
    private var settingsSheetContent: some View {
        switch viewModel.selectedOutputType {
        case .faceSheet:
            FaceSheetSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .bodySheet:
            BodySheetSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .outfit:
            OutfitSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .pose:
            PoseSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .sceneBuilder:
            SceneBuilderSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .background:
            BackgroundSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .decorativeText:
            DecorativeTextSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .fourPanelManga:
            FourPanelSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .styleTransform:
            StyleTransformSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        case .infographic:
            InfographicSettingsView { settings in
                viewModel.isSettingsConfigured = true
            }
        }
    }
}

#Preview {
    MainView()
        .frame(width: 1400, height: 700)
}
