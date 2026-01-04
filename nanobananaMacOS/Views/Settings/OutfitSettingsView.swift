// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 衣装着用設定ウィンドウ
struct OutfitSettingsView: View {
    @StateObject private var viewModel: OutfitSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((OutfitSettingsViewModel) -> Void)?

    init(initialSettings: OutfitSettingsViewModel? = nil, onApply: ((OutfitSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = OutfitSettingsViewModel()
            vm.useBodySheet = settings.useBodySheet
            vm.bodySheetImagePath = settings.bodySheetImagePath
            vm.useOutfitBuilder = settings.useOutfitBuilder
            vm.outfitCategory = settings.outfitCategory
            vm.outfitShape = settings.outfitShape
            vm.outfitColor = settings.outfitColor
            vm.outfitPattern = settings.outfitPattern
            vm.outfitStyle = settings.outfitStyle
            vm.referenceOutfitImagePath = settings.referenceOutfitImagePath
            vm.referenceDescription = settings.referenceDescription
            vm.fitMode = settings.fitMode
            vm.includeHeadwear = settings.includeHeadwear
            vm.additionalDescription = settings.additionalDescription
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: OutfitSettingsViewModel())
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
                    // MARK: - 入力画像（素体三面図）
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("入力画像（素体三面図）")
                                .font(.headline)
                                .fontWeight(.bold)

                            Toggle("素体三面図を使う", isOn: $viewModel.useBodySheet)

                            Text("オフ: 透明人間モード（衣装のみ描画） / オン: キャラクターに衣装を着せる")
                                .font(.caption)
                                .foregroundColor(.gray)

                            ImageDropField(
                                imagePath: $viewModel.bodySheetImagePath,
                                label: "素体三面図:",
                                placeholder: "素体三面図をドロップ",
                                isDisabled: !viewModel.useBodySheet
                            )
                        }
                        .padding(10)
                    }

                    // MARK: - 衣装選択方法
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("衣装選択方法")
                                .font(.headline)
                                .fontWeight(.bold)

                            Picker("", selection: $viewModel.useOutfitBuilder) {
                                Text("プリセットから選ぶ").tag(true)
                                Text("参考画像から着せる").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: - プリセット衣装 / 参考画像（排他表示）
                    if viewModel.useOutfitBuilder {
                        // プリセット衣装
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("プリセット衣装")
                                    .font(.headline)
                                    .fontWeight(.bold)

                                HStack {
                                    Text("カテゴリ:")
                                        .frame(width: 60, alignment: .leading)
                                    Picker("", selection: $viewModel.outfitCategory) {
                                        ForEach(OutfitCategory.allCases) { cat in
                                            Text(cat.rawValue).tag(cat)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 180, alignment: .leading)
                                    Spacer()
                                }

                                HStack {
                                    Text("形状:")
                                        .frame(width: 60, alignment: .leading)
                                    Picker("", selection: $viewModel.outfitShape) {
                                        ForEach(viewModel.outfitCategory.shapes, id: \.self) { shape in
                                            Text(shape).tag(shape)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 180, alignment: .leading)
                                    Spacer()
                                }

                                HStack {
                                    Text("色:")
                                        .frame(width: 60, alignment: .leading)
                                    Picker("", selection: $viewModel.outfitColor) {
                                        ForEach(OutfitColor.allCases) { color in
                                            Text(color.rawValue).tag(color)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 180, alignment: .leading)
                                    Spacer()
                                }

                                HStack {
                                    Text("柄:")
                                        .frame(width: 60, alignment: .leading)
                                    Picker("", selection: $viewModel.outfitPattern) {
                                        ForEach(OutfitPattern.allCases) { pattern in
                                            Text(pattern.rawValue).tag(pattern)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 180, alignment: .leading)
                                    Spacer()
                                }

                                HStack {
                                    Text("印象:")
                                        .frame(width: 60, alignment: .leading)
                                    Picker("", selection: $viewModel.outfitStyle) {
                                        ForEach(OutfitFashionStyle.allCases) { style in
                                            Text(style.rawValue).tag(style)
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
                    } else {
                        // 参考画像から衣装を着せる
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("参考画像から衣装を着せる")
                                    .font(.headline)
                                    .fontWeight(.bold)

                                ImageDropField(
                                    imagePath: $viewModel.referenceOutfitImagePath,
                                    label: "衣装参考画像:",
                                    placeholder: "着せたい衣装の参考画像をドロップ"
                                )

                                HStack(alignment: .top) {
                                    Text("衣装説明:")
                                        .frame(width: 90, alignment: .leading)
                                    TextField("（任意）参考画像の衣装について補足説明", text: $viewModel.referenceDescription)
                                        .textFieldStyle(.roundedBorder)
                                }

                                HStack {
                                    Text("フィットモード:")
                                        .frame(width: 90, alignment: .leading)
                                    Picker("", selection: $viewModel.fitMode) {
                                        Text("素体優先").tag("素体優先")
                                        Text("衣装優先").tag("衣装優先")
                                        Text("ハイブリッド").tag("ハイブリッド")
                                    }
                                    .pickerStyle(.segmented)
                                    .labelsHidden()
                                }

                                Text("素体優先: 衣装を素体にフィット / 衣装優先: 体型を衣装に合わせる / ハイブリッド: 顔は素体、体型は衣装")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 90)

                                Toggle("頭部装飾（帽子・ヘルメット等）を含める", isOn: $viewModel.includeHeadwear)
                                    .disabled(viewModel.fitMode == "ハイブリッド")

                                Text("※ ハイブリッドモードでは頭部全体（髪型含む）が素体から取られるため、このオプションは無効です")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text("※ 参考画像の著作権はユーザー責任です")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(10)
                        }
                    }

                    // MARK: - 追加説明
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("追加説明")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack(alignment: .top) {
                                Text("詳細:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("（任意）衣装の追加詳細を記述", text: $viewModel.additionalDescription)
                                    .textFieldStyle(.roundedBorder)
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
                                Text("• 素体三面図の顔・体型をそのまま使用（変更禁止）")
                                Text("• 指定された衣装を着用（素体の上に衣装を描画）")
                                Text("• 三面図形式を維持（正面/横/背面）")
                                Text("• 衣装のみを変更（髪型・顔は変更しない）")
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
        .frame(width: 780, height: 820)
    }
}

#Preview {
    OutfitSettingsView()
}
