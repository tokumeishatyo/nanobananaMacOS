import SwiftUI

/// 背景生成設定ウィンドウ（シンプル版）
struct BackgroundSettingsView: View {
    @StateObject private var viewModel: BackgroundSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((BackgroundSettingsViewModel) -> Void)?

    init(initialSettings: BackgroundSettingsViewModel? = nil, onApply: ((BackgroundSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = BackgroundSettingsViewModel()
            vm.useReferenceImage = settings.useReferenceImage
            vm.referenceImagePath = settings.referenceImagePath
            vm.removeCharacters = settings.removeCharacters
            vm.description = settings.description
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: BackgroundSettingsViewModel())
        }
    }

    private func dismissWindow() {
        if let windowDismiss = windowDismiss {
            windowDismiss()
        } else {
            standardDismiss()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                // タイトル
                Text("背景生成")
                    .font(.headline)
                    .fontWeight(.bold)

                // 参考画像セクション
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("参考画像を使用", isOn: $viewModel.useReferenceImage)

                        HStack {
                            Text("画像パス:")
                                .frame(width: 70, alignment: .leading)
                            TextField("参考画像のパス", text: $viewModel.referenceImagePath)
                                .textFieldStyle(.roundedBorder)
                                .disabled(!viewModel.useReferenceImage)
                            Button("参照") {
                                // TODO: ファイル選択
                            }
                            .disabled(!viewModel.useReferenceImage)
                        }

                        Toggle("人物を自動除去（推奨）", isOn: $viewModel.removeCharacters)
                            .disabled(!viewModel.useReferenceImage)
                    }
                    .padding(10)
                }

                // 背景説明 / 変形指示
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("背景説明 / 変形指示:")
                            .fontWeight(.semibold)

                        TextEditor(text: $viewModel.description)
                            .frame(height: 120)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .overlay(
                                Group {
                                    if viewModel.description.isEmpty {
                                        Text(placeholderText)
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )

                        // 説明テキスト
                        Text(helpText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                }

                Spacer()
            }
            .padding(16)

            Divider()

            HStack {
                Spacer()
                Button("適用") {
                    onApply?(viewModel)
                    dismissWindow()
                }
                .buttonStyle(.borderedProminent)

                Button("キャンセル") {
                    dismissWindow()
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .frame(width: 500, height: 470)
    }

    /// プレースホルダーテキスト
    private var placeholderText: String {
        if viewModel.useReferenceImage {
            return "例: 夕暮れの雰囲気にする、雪景色にする"
        } else {
            return "例: 夕暮れの屋上、オレンジ色の空、手すり、遠くにビル群"
        }
    }

    /// ヘルプテキスト
    private var helpText: String {
        if viewModel.useReferenceImage {
            return "※ 変形指示を入力してください（空欄の場合はアニメ調に変換）"
        } else {
            return "※ 生成したい背景の説明を入力してください"
        }
    }
}

#Preview {
    BackgroundSettingsView()
}
