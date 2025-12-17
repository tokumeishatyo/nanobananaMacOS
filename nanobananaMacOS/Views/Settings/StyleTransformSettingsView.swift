import SwiftUI

/// スタイル変換設定ウィンドウ
struct StyleTransformSettingsView: View {
    @StateObject private var viewModel = StyleTransformSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((StyleTransformSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // 入力画像
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("入力画像")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("元画像:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("変換する画像のパス", text: $viewModel.sourceImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }
                        }
                        .padding(10)
                    }

                    // 変換タイプ選択
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
                        }
                        .padding(10)
                    }

                    // タイプ別設定
                    if viewModel.transformType == .chibi {
                        chibiSettings
                    } else {
                        pixelSettings
                    }
                }
                .padding(16)
            }

            Divider()

            HStack {
                Spacer()
                Button("適用") {
                    onApply?(viewModel)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("キャンセル") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .frame(width: 600, height: 450)
    }

    // MARK: - ちびキャラ化設定
    private var chibiSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ちびキャラ化設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("スタイル:")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.chibiStyle) {
                        Text("スタンダード(2頭身)").tag("スタンダード(2頭身)")
                        Text("ミニマム(1.5頭身)").tag("ミニマム(1.5頭身)")
                        Text("ぷちキャラ(3頭身)").tag("ぷちキャラ(3頭身)")
                    }
                    .labelsHidden()
                    .frame(width: 180)
                    Spacer()
                }

                Toggle("元の衣装を維持", isOn: $viewModel.keepOutfit)
                Toggle("元のポーズを維持", isOn: $viewModel.keepPose)
            }
            .padding(10)
        }
    }

    // MARK: - ドットキャラ化設定
    private var pixelSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ドットキャラ化設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("スタイル:")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.pixelStyle) {
                        Text("8bit風").tag("8bit風")
                        Text("16bit風").tag("16bit風")
                        Text("モダンピクセル").tag("モダンピクセル")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }

                HStack {
                    Text("スプライトサイズ:")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.spriteSize) {
                        Text("32x32").tag("32x32")
                        Text("64x64").tag("64x64")
                        Text("128x128").tag("128x128")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }

                Toggle("元の色味を維持", isOn: $viewModel.keepColors)
            }
            .padding(10)
        }
    }
}

#Preview {
    StyleTransformSettingsView()
}
