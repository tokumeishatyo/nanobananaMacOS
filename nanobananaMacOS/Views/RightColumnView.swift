// rule.mdを読むこと
import SwiftUI

/// 右カラム: YAMLプレビュー・画像プレビュー
struct RightColumnView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - YAMLプレビュー
            GroupBox {
                VStack(spacing: 8) {
                    // ヘッダー
                    HStack {
                        Text("YAMLプレビュー")
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Button("コピー") {
                            viewModel.copyYAML()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button("保存") {
                            viewModel.saveYAML()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button("読込") {
                            viewModel.loadYAML()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 5)

                    // YAMLテキスト（読み取り専用）
                    ScrollView {
                        Text(viewModel.yamlPreviewText.isEmpty ? "YAML生成後に表示されます" : viewModel.yamlPreviewText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(viewModel.yamlPreviewText.isEmpty ? .gray : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .textSelection(.enabled)
                    }
                    .frame(minHeight: 150)
                    .background(Color(nsColor: .textBackgroundColor))
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                }
            }
            .frame(minHeight: 200)

            // MARK: - 画像プレビュー
            GroupBox {
                VStack(spacing: 8) {
                    Text("画像プレビュー")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.top, 5)

                    // 画像表示エリア
                    if let image = viewModel.generatedImage {
                        Image(nsImage: image)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(10)
                    } else {
                        VStack {
                            Spacer()
                            Text("画像生成後に表示されます")
                                .font(.body)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // ボタン
                    HStack(spacing: 10) {
                        Button(action: viewModel.saveImage) {
                            Text("画像を保存")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.isSaveImageButtonEnabled)

                        Button(action: viewModel.refineImage) {
                            Text("画像を加工")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                        .disabled(!viewModel.isRefineImageButtonEnabled)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(10)
    }
}

#Preview {
    RightColumnView(viewModel: MainViewModel())
        .frame(width: 500, height: 600)
}
