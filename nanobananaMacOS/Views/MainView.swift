// rule.mdを読むこと
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
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.showAlert = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else if let successMessage = viewModel.successMessage {
                Text(successMessage)
            }
        }
    }
}

#Preview {
    MainView()
        .frame(width: 1400, height: 700)
}
