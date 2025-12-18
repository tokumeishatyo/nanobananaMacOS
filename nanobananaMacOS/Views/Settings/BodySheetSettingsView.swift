import SwiftUI

/// 素体三面図設定ウィンドウ
struct BodySheetSettingsView: View {
    @StateObject private var viewModel: BodySheetSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((BodySheetSettingsViewModel) -> Void)?

    init(initialSettings: BodySheetSettingsViewModel? = nil, onApply: ((BodySheetSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = BodySheetSettingsViewModel()
            vm.faceSheetImagePath = settings.faceSheetImagePath
            vm.bodyTypePreset = settings.bodyTypePreset
            vm.bustFeature = settings.bustFeature
            vm.bodyRenderType = settings.bodyRenderType
            vm.additionalDescription = settings.additionalDescription
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: BodySheetSettingsViewModel())
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
                VStack(spacing: 12) {
                    // MARK: - 入力画像（顔三面図）
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("入力画像（顔三面図）")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("顔三面図:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("顔三面図の画像パス", text: $viewModel.faceSheetImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }
                        }
                        .padding(10)
                    }

                    // MARK: - 体型設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("体型設定")
                                .font(.headline)
                                .fontWeight(.bold)

                            // 体型プリセット
                            HStack {
                                Text("体型:")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.bodyTypePreset) {
                                    ForEach(BodyTypePreset.allCases) { preset in
                                        Text(preset.rawValue).tag(preset)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 180, alignment: .leading)
                                Spacer()
                            }

                            // バスト特徴
                            HStack {
                                Text("バスト:")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.bustFeature) {
                                    ForEach(BustFeature.allCases) { feature in
                                        Text(feature.rawValue).tag(feature)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 180, alignment: .leading)
                                Spacer()
                            }

                            // 素体表現タイプ
                            HStack {
                                Text("表現:")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.bodyRenderType) {
                                    ForEach(BodyRenderType.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 180, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(10)
                    }

                    // MARK: - 詳細設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("詳細設定")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack(alignment: .top) {
                                Text("追加説明:")
                                    .frame(width: 80, alignment: .leading)
                                TextEditor(text: $viewModel.additionalDescription)
                                    .frame(height: 80)
                                    .border(Color.gray.opacity(0.3), width: 1)
                            }
                        }
                        .padding(10)
                    }

                    // MARK: - 生成時の制約
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("生成時の制約")
                                .font(.headline)
                                .fontWeight(.bold)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 顔三面図の顔をそのまま使用（変更禁止）")
                                Text("• 体型は指定されたプリセットに従う")
                                Text("• 服装は追加しない（素体のみ）")
                                Text("• 三面図形式を維持（正面/横/背面）")
                            }
                            .font(.caption)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
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
}

#Preview {
    BodySheetSettingsView()
}
