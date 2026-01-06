// rule.mdを読むこと
import SwiftUI

/// 左カラム: 基本設定
struct LeftColumnView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // MARK: - 出力タイプ選択
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "出力タイプ")

                        HStack {
                            Text("タイプ:")
                                .frame(width: 60, alignment: .leading)

                            Picker("", selection: $viewModel.selectedOutputType) {
                                ForEach(OutputType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 150)
                            .onChange(of: viewModel.selectedOutputType) { _, newValue in
                                viewModel.willChangeOutputType(to: newValue)
                            }

                            Button("詳細設定...") {
                                viewModel.openSettingsWindow()
                            }
                            .disabled(!viewModel.isSettingsButtonEnabled)
                        }
                        .padding(.horizontal, 10)
                        .confirmationDialog(
                            "確認",
                            isPresented: $viewModel.showOutputTypeChangeConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("OK") {
                                viewModel.confirmOutputTypeChange()
                            }
                            Button("キャンセル", role: .cancel) {
                                viewModel.cancelOutputTypeChange()
                            }
                        } message: {
                            Text("保持した入力内容が消えますが、変更してもよろしいですか？")
                        }

                        // 設定状態表示
                        Text(viewModel.settingsStatusText)
                            .font(.caption)
                            .foregroundColor(viewModel.settingsStatusColor)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 5)
                    }
                }

                // MARK: - スタイル設定
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "スタイル設定")

                        // カラーモード
                        HStack {
                            Text("カラーモード:")
                                .frame(width: 100, alignment: .leading)

                            Picker("", selection: $viewModel.selectedColorMode) {
                                ForEach(ColorMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 100)

                            // 二色刷り選択時のみ表示（現在は赤×黒固定）
                            if viewModel.selectedColorMode == .duotone {
                                Text("(赤×黒)")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 10)

                        // スタイル
                        LabeledPickerView(
                            label: "スタイル:",
                            selection: $viewModel.selectedOutputStyle,
                            options: OutputStyle.allCases
                        )

                        // アスペクト比
                        LabeledPickerView(
                            label: "アスペクト比:",
                            selection: $viewModel.selectedAspectRatio,
                            options: AspectRatio.allCases
                        )
                    }
                    .padding(.bottom, 5)
                }

                // MARK: - 基本情報
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "基本情報")

                        // タイトル
                        HStack {
                            Text("タイトル:")
                                .frame(width: 100, alignment: .leading)

                            TextField("作品タイトル（必須）", text: $viewModel.title)
                                .textFieldStyle(.roundedBorder)

                            Toggle("画像に入れる", isOn: $viewModel.includeTitleInImage)
                                .toggleStyle(.checkbox)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)

                        // 作者名
                        LabeledTextFieldView(
                            label: "作者名:",
                            placeholder: "Unknown",
                            text: $viewModel.authorName
                        )
                    }
                    .padding(.bottom, 5)
                }

                // MARK: - 生成ボタン・リセットボタン
                GroupBox {
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Button(action: viewModel.generateYAML) {
                                Text("YAML生成")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)

                            Button(action: viewModel.resetAll) {
                                Text("リセット")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)

                        // キャラクタ管理
                        Button(action: viewModel.openCharacterDatabase) {
                            Text("キャラクタ管理")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .padding(.horizontal, 10)

                        // 漫画ページコンポーザー
                        Button(action: viewModel.openMangaComposer) {
                            Text("漫画ページコンポーザー")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                        .padding(.horizontal, 10)

                        // 詳細漫画コンポーザー
                        Button(action: viewModel.openDetailedMangaComposer) {
                            Text("詳細漫画コンポーザー")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                        .padding(.horizontal, 10)

                        // 画像ツール
                        Button(action: viewModel.openBackgroundRemover) {
                            Text("画像ツール（背景透過）")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                        .padding(.horizontal, 10)

                        // 画像サイズ調整
                        Button(action: viewModel.openImageResize) {
                            Text("画像サイズ調整")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                }

                Spacer()
            }
            .padding(10)
        }
        .frame(minWidth: AppConstants.leftColumnWidth)
    }
}

#Preview {
    LeftColumnView(viewModel: MainViewModel())
        .frame(width: 350, height: 600)
}
