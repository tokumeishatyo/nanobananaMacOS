// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// スタイル変換設定ウィンドウ
struct StyleTransformSettingsView: View {
    @StateObject private var viewModel: StyleTransformSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((StyleTransformSettingsViewModel) -> Void)?

    init(initialSettings: StyleTransformSettingsViewModel? = nil, onApply: ((StyleTransformSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = StyleTransformSettingsViewModel()
            vm.sourceImagePath = settings.sourceImagePath
            vm.transformType = settings.transformType
            vm.chibiStyle = settings.chibiStyle
            vm.keepOutfit = settings.keepOutfit
            vm.keepPose = settings.keepPose
            vm.pixelStyle = settings.pixelStyle
            vm.spriteSize = settings.spriteSize
            vm.keepColors = settings.keepColors
            vm.transparentBackground = settings.transparentBackground
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: StyleTransformSettingsViewModel())
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
            ScrollView {
                VStack(spacing: 16) {
                    // 入力画像
                    inputImageSection

                    // 変換タイプ選択
                    transformTypeSection

                    // タイプ別設定
                    if viewModel.transformType == .chibi {
                        chibiSettingsSection
                    } else {
                        pixelSettingsSection
                    }

                    // 共通設定（背景透過）
                    commonSettingsSection
                }
                .padding(16)
            }

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
        .frame(width: 700, height: 650)
    }

    // MARK: - 入力画像セクション
    private var inputImageSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("入力画像")
                    .font(.headline)
                    .fontWeight(.bold)

                ImageDropField(
                    imagePath: $viewModel.sourceImagePath,
                    label: "元画像:",
                    placeholder: "変換する画像をドロップ"
                )

                Text("※ 素体/衣装/ポーズなど、どの段階の画像でも変換可能")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(10)
        }
    }

    // MARK: - 変換タイプセクション
    private var transformTypeSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("変換タイプ")
                    .font(.headline)
                    .fontWeight(.bold)

                Picker("", selection: $viewModel.transformType) {
                    ForEach(StyleTransformType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300, alignment: .leading)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - ちびキャラ化設定
    private var chibiSettingsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ちびキャラ化設定")
                    .font(.headline)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("スタイル:")
                    Picker("", selection: $viewModel.chibiStyle) {
                        ForEach(ChibiStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle("元の衣装を維持", isOn: $viewModel.keepOutfit)
                Toggle("元のポーズを維持", isOn: $viewModel.keepPose)
            }
            .padding(10)
        }
    }

    // MARK: - ドットキャラ化設定
    private var pixelSettingsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ドットキャラ化設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("スタイル:")
                        .frame(width: 120, alignment: .leading)
                    Picker("", selection: $viewModel.pixelStyle) {
                        ForEach(PixelStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 200, alignment: .leading)
                    Spacer()
                }

                HStack {
                    Text("スプライトサイズ:")
                        .frame(width: 120, alignment: .leading)
                    Picker("", selection: $viewModel.spriteSize) {
                        ForEach(SpriteSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 200, alignment: .leading)
                    Spacer()
                }

                Toggle("元の色味を維持", isOn: $viewModel.keepColors)
            }
            .padding(10)
        }
    }

    // MARK: - 共通設定セクション
    private var commonSettingsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("出力設定")
                    .font(.headline)
                    .fontWeight(.bold)

                Toggle("背景透過（合成用素材として出力）", isOn: $viewModel.transparentBackground)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    StyleTransformSettingsView()
}
