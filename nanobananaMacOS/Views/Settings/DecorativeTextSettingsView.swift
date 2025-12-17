import SwiftUI

/// 装飾テキスト設定ウィンドウ
struct DecorativeTextSettingsView: View {
    @StateObject private var viewModel = DecorativeTextSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((DecorativeTextSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // テキストタイプ選択
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("テキストタイプ")
                                .font(.headline)
                                .fontWeight(.bold)

                            Picker("", selection: $viewModel.textType) {
                                ForEach(DecorativeTextType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(10)
                    }

                    // テキスト入力
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("テキスト")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("メインテキスト:")
                                    .frame(width: 120, alignment: .leading)
                                TextField("表示するテキスト", text: $viewModel.mainText)
                                    .textFieldStyle(.roundedBorder)
                            }

                            if viewModel.textType == .skillName || viewModel.textType == .catchphrase {
                                HStack {
                                    Text("サブテキスト:")
                                        .frame(width: 120, alignment: .leading)
                                    TextField("ふりがな・補足（任意）", text: $viewModel.subText)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding(10)
                    }

                    // タイプ別設定
                    switch viewModel.textType {
                    case .skillName:
                        skillNameSettings
                    case .catchphrase:
                        catchphraseSettings
                    case .namePlate:
                        namePlateSettings
                    case .messageWindow:
                        messageWindowSettings
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
        .frame(width: 700, height: 550)
    }

    // MARK: - 技名テロップ設定
    private var skillNameSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("技名テロップ設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("フォント:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.fontStyle) {
                        Text("極太明朝").tag("極太明朝")
                        Text("極太ゴシック").tag("極太ゴシック")
                        Text("筆書き").tag("筆書き")
                        Text("ポップ体").tag("ポップ体")
                    }
                    .labelsHidden()
                    .frame(width: 120)

                    Text("サイズ:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.fontSize) {
                        Text("特大").tag("特大")
                        Text("大").tag("大")
                        Text("中").tag("中")
                        Text("小").tag("小")
                    }
                    .labelsHidden()
                    .frame(width: 80)
                    Spacer()
                }

                HStack {
                    Text("グラデ:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.gradientStyle) {
                        Text("白→青").tag("白→青")
                        Text("赤→黄").tag("赤→黄")
                        Text("金→オレンジ").tag("金→オレンジ")
                        Text("虹色").tag("虹色")
                    }
                    .labelsHidden()
                    .frame(width: 120)

                    Text("縁取り:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.borderStyle) {
                        Text("金").tag("金")
                        Text("銀").tag("銀")
                        Text("黒").tag("黒")
                        Text("なし").tag("なし")
                    }
                    .labelsHidden()
                    .frame(width: 80)
                    Spacer()
                }

                HStack {
                    Text("発光効果:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.glowEffect) {
                        Text("青い稲妻").tag("青い稲妻")
                        Text("炎").tag("炎")
                        Text("電撃").tag("電撃")
                        Text("オーラ").tag("オーラ")
                        Text("なし").tag("なし")
                    }
                    .labelsHidden()
                    .frame(width: 120)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - 決め台詞設定
    private var catchphraseSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("決め台詞設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("スタイル:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.fontStyle) {
                        Text("書き文字風").tag("書き文字風")
                        Text("縦書き叫び").tag("縦書き叫び")
                        Text("ポップ体").tag("ポップ体")
                        Text("回転・変形").tag("回転・変形")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - キャラ名プレート設定
    private var namePlateSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("キャラ名プレート設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("フォント:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.fontStyle) {
                        Text("ゴシック").tag("ゴシック")
                        Text("明朝").tag("明朝")
                        Text("ファンタジー").tag("ファンタジー")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }

                HStack {
                    Text("装飾:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.borderStyle) {
                        Text("シンプル枠").tag("シンプル枠")
                        Text("装飾枠").tag("装飾枠")
                        Text("リボン風").tag("リボン風")
                        Text("なし").tag("なし")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - メッセージウィンドウ設定
    private var messageWindowSettings: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("メッセージウィンドウ設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("モード:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.windowStyle) {
                        Text("フルスペック").tag("フルスペック")
                        Text("顔アイコンのみ").tag("顔アイコンのみ")
                        Text("セリフのみ").tag("セリフのみ")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }

                if viewModel.windowStyle != "セリフのみ" {
                    HStack {
                        Text("キャラ名:")
                            .frame(width: 80, alignment: .leading)
                        TextField("発言者名", text: $viewModel.characterName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                        Spacer()
                    }

                    HStack {
                        Text("顔アイコン:")
                            .frame(width: 80, alignment: .leading)
                        TextField("顔画像パス", text: $viewModel.faceIconImagePath)
                            .textFieldStyle(.roundedBorder)
                        Button("参照") {
                            // TODO: ファイル選択
                        }
                    }
                }
            }
            .padding(10)
        }
    }
}

#Preview {
    DecorativeTextSettingsView()
}
