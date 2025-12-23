// rule.mdを読むこと
import SwiftUI

/// 中央カラム: API設定
struct MiddleColumnView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // MARK: - API設定
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "API設定")

                        // 出力モード
                        HStack {
                            Text("出力モード:")
                                .frame(width: 100, alignment: .leading)

                            Picker("", selection: $viewModel.selectedOutputMode) {
                                ForEach(OutputMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200, alignment: .leading)
                            Spacer()
                        }
                        .padding(.horizontal, 10)

                        // APIキー
                        HStack {
                            Text("API Key:")
                                .frame(width: 100, alignment: .leading)

                            SecureField("Google AI API Key", text: $viewModel.apiKey)
                                .textFieldStyle(.roundedBorder)
                                .disabled(!viewModel.isAPIModeEnabled)

                            Button(action: viewModel.clearAPIKey) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.isAPIModeEnabled)
                            .help("APIキーをクリア")
                        }
                        .padding(.horizontal, 10)

                        // APIモード
                        HStack {
                            Text("APIモード:")
                                .frame(width: 100, alignment: .leading)

                            Picker("", selection: $viewModel.selectedAPISubMode) {
                                ForEach(APISubMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200, alignment: .leading)
                            .disabled(!viewModel.isAPIModeEnabled)
                            Spacer()
                        }
                        .padding(.horizontal, 10)

                        // 参考画像（シンプルモードのみ表示）
                        if viewModel.selectedAPISubMode == .simple && viewModel.isAPIModeEnabled {
                            HStack {
                                Text("参考画像:")
                                    .frame(width: 100, alignment: .leading)

                                TextField("参考画像（任意）", text: $viewModel.referenceImagePath)
                                    .textFieldStyle(.roundedBorder)

                                Button("参照") {
                                    viewModel.browseReferenceImage()
                                }
                            }
                            .padding(.horizontal, 10)
                        }

                        // 追加指示（清書モード）
                        if viewModel.selectedAPISubMode == .redraw && viewModel.isAPIModeEnabled {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("追加指示:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)

                                TextEditor(text: $viewModel.redrawInstruction)
                                    .frame(height: 60)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .padding(.horizontal, 10)
                            }
                        }

                        // プロンプト（シンプルモード）
                        if viewModel.selectedAPISubMode == .simple && viewModel.isAPIModeEnabled {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("プロンプト:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)

                                TextEditor(text: $viewModel.simplePrompt)
                                    .frame(height: 80)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .padding(.horizontal, 10)
                            }
                        }

                        // 解像度
                        HStack {
                            Text("解像度:")
                                .frame(width: 100, alignment: .leading)

                            Picker("", selection: $viewModel.selectedResolution) {
                                ForEach(Resolution.allCases) { res in
                                    Text(res.rawValue).tag(res)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200, alignment: .leading)
                            .disabled(!viewModel.isAPIModeEnabled)
                            Spacer()
                        }
                        .padding(.horizontal, 10)

                        // 画像生成ボタン
                        Button(action: viewModel.generateImageWithAPI) {
                            HStack {
                                if viewModel.isGenerating {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.8)
                                        .padding(.trailing, 4)
                                    Text("生成中...")
                                } else {
                                    Text("画像生成（API）")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                        .disabled(!viewModel.isAPIGenerateButtonEnabled || viewModel.isGenerating)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 10)
                }

                // MARK: - 参考画像プレビュー（シンプルモードのみ表示）
                if viewModel.selectedAPISubMode == .simple && viewModel.isAPIModeEnabled {
                    GroupBox {
                        VStack(spacing: 8) {
                            Text("参考画像プレビュー")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.top, 5)

                            if let image = viewModel.referenceImagePreview {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .padding(5)
                            } else {
                                Text("画像未読込")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(height: 100)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                // MARK: - API使用状況
                GroupBox {
                    VStack(spacing: 4) {
                        Text(viewModel.usageStatusText)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                viewModel.showUsageDetails()
                            }

                        Text("クリックで詳細表示")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                }

                Spacer()
            }
            .padding(10)
        }
        .frame(minWidth: AppConstants.middleColumnWidth)
    }
}

#Preview {
    MiddleColumnView(viewModel: MainViewModel())
        .frame(width: 400, height: 600)
}
