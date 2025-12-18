import SwiftUI

/// インフォグラフィック設定ウィンドウ
struct InfographicSettingsView: View {
    @StateObject private var viewModel = InfographicSettingsViewModel()
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((InfographicSettingsViewModel) -> Void)?

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
                    // 基本設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("基本設定")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("スタイル:")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.infographicStyle) {
                                    ForEach(InfographicStyle.allCases) { style in
                                        Text(style.rawValue).tag(style)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 180)

                                Text("出力言語:")
                                    .padding(.leading, 20)
                                Picker("", selection: $viewModel.outputLanguage) {
                                    ForEach(InfographicLanguage.allCases) { lang in
                                        Text(lang.rawValue).tag(lang)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150)

                                if viewModel.outputLanguage == .other {
                                    TextField("言語を入力", text: $viewModel.customLanguage)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 150)
                                }
                                Spacer()
                            }

                            HStack {
                                Text("タイトル:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("メインタイトル", text: $viewModel.mainTitle)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("副題:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("サブタイトル（任意）", text: $viewModel.subtitle)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(10)
                    }

                    // キャラクター画像
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("キャラクター画像")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("メイン:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("中央に配置するキャラ画像", text: $viewModel.mainCharacterImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }

                            HStack {
                                Text("おまけ:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("ちびキャラなど（任意）", text: $viewModel.subCharacterImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }
                        }
                        .padding(10)
                    }

                    // セクション設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("情報セクション")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Button("セクション追加") {
                                    if viewModel.sections.count < 8 {
                                        viewModel.sections.append(InfographicSection())
                                    }
                                }
                                .disabled(viewModel.sections.count >= 8)
                            }

                            Text("配置: 1-8の位置を指定（0=おまかせ）")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("""
                            位置レイアウト:
                            [1] [2] [3]
                            [4] 画像 [5]
                            [6] [7] [8]
                            """)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)

                            ForEach(viewModel.sections.indices, id: \.self) { index in
                                sectionRow(index: index)
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
        .frame(width: 750, height: 700)
    }

    private func sectionRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("セクション\(index + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 100, alignment: .leading)

                TextField("タイトル", text: Binding(
                    get: { viewModel.sections[index].title },
                    set: { viewModel.sections[index].title = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

                Text("位置:")
                Picker("", selection: Binding(
                    get: { viewModel.sections[index].position },
                    set: { viewModel.sections[index].position = $0 }
                )) {
                    Text("おまかせ").tag(0)
                    ForEach(1...8, id: \.self) { pos in
                        Text("\(pos)").tag(pos)
                    }
                }
                .labelsHidden()
                .frame(width: 100)

                if viewModel.sections.count > 1 {
                    Button(action: {
                        viewModel.sections.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("")
                    .frame(width: 100)
                TextField("説明", text: Binding(
                    get: { viewModel.sections[index].content },
                    set: { viewModel.sections[index].content = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    InfographicSettingsView()
}
