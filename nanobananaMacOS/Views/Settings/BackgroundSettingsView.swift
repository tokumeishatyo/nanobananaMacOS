import SwiftUI

/// 背景生成設定ウィンドウ
struct BackgroundSettingsView: View {
    @StateObject private var viewModel = BackgroundSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((BackgroundSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // 背景設定セクション
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("背景設定")
                                .font(.headline)
                                .fontWeight(.bold)

                            // プリセット選択
                            HStack {
                                Text("プリセット:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("", selection: $viewModel.backgroundPreset) {
                                    ForEach(BackgroundPreset.allCases) { preset in
                                        Text(preset.rawValue).tag(preset)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150)
                                Spacer()
                            }

                            // カスタム説明
                            if viewModel.backgroundPreset == .custom {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("背景説明:")
                                    TextEditor(text: $viewModel.customDescription)
                                        .frame(height: 100)
                                        .border(Color.gray.opacity(0.3), width: 1)
                                        .overlay(
                                            Group {
                                                if viewModel.customDescription.isEmpty {
                                                    Text("例: 夕暮れの屋上、オレンジ色の空、手すり、遠くにビル群")
                                                        .foregroundColor(.gray.opacity(0.5))
                                                        .padding(8)
                                                        .allowsHitTesting(false)
                                                }
                                            },
                                            alignment: .topLeading
                                        )
                                }
                            }
                        }
                        .padding(10)
                    }

                    // 参考画像から生成
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("参考画像から背景を生成", isOn: $viewModel.useReferenceImage)
                                .font(.headline)

                            if viewModel.useReferenceImage {
                                HStack {
                                    Text("参考画像:")
                                        .frame(width: 100, alignment: .leading)
                                    TextField("参考画像パス", text: $viewModel.referenceImagePath)
                                        .textFieldStyle(.roundedBorder)
                                    Button("参照") {
                                        // TODO: ファイル選択
                                    }
                                }

                                Toggle("人物を自動除去", isOn: $viewModel.removeCharacters)
                                    .padding(.leading, 100)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("変換指示:")
                                        .frame(width: 100, alignment: .leading)
                                    TextEditor(text: $viewModel.transformInstruction)
                                        .frame(height: 60)
                                        .border(Color.gray.opacity(0.3), width: 1)
                                        .overlay(
                                            Group {
                                                if viewModel.transformInstruction.isEmpty {
                                                    Text("例: アニメ調に変換、夕暮れにする")
                                                        .foregroundColor(.gray.opacity(0.5))
                                                        .padding(8)
                                                        .allowsHitTesting(false)
                                                }
                                            },
                                            alignment: .topLeading
                                        )
                                }
                            }
                        }
                        .padding(10)
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
        .frame(width: 650, height: 500)
    }
}

#Preview {
    BackgroundSettingsView()
}
