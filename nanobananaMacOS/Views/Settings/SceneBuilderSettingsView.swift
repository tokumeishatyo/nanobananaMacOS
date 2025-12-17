import SwiftUI

/// シーンビルダー設定ウィンドウ
struct SceneBuilderSettingsView: View {
    @StateObject private var viewModel = SceneBuilderSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((SceneBuilderSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // タブ切り替え
            Picker("", selection: $viewModel.sceneType) {
                ForEach(SceneType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // 背景設定（共通）
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("背景")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("背景画像:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("背景画像パス（または下記説明で生成）", text: $viewModel.backgroundImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("情景説明:")
                                TextEditor(text: $viewModel.backgroundDescription)
                                    .frame(height: 60)
                                    .border(Color.gray.opacity(0.3), width: 1)
                            }
                        }
                        .padding(10)
                    }

                    // シーンタイプ別コンテンツ
                    switch viewModel.sceneType {
                    case .battle:
                        battleSceneContent
                    case .story:
                        storySceneContent
                    case .bossRaid:
                        bossRaidSceneContent
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
        .frame(width: 800, height: 650)
    }

    // MARK: - バトルシーン
    private var battleSceneContent: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("バトルシーン設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    // 左キャラ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("左キャラクター")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack {
                            TextField("画像パス", text: $viewModel.leftCharacterImagePath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                            Button("参照") {}
                        }
                        TextField("名前", text: $viewModel.leftCharacterName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                    }

                    // 右キャラ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("右キャラクター")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack {
                            TextField("画像パス", text: $viewModel.rightCharacterImagePath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                            Button("参照") {}
                        }
                        TextField("名前", text: $viewModel.rightCharacterName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                    }
                }

                Divider()

                HStack {
                    Text("優勢設定:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.battleAdvantage) {
                        Text("互角").tag("互角")
                        Text("左優勢").tag("左優勢")
                        Text("右優勢").tag("右優勢")
                    }
                    .labelsHidden()
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                }
            }
            .padding(10)
        }
    }

    // MARK: - ストーリーシーン
    private var storySceneContent: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ストーリーシーン設定")
                    .font(.headline)
                    .fontWeight(.bold)

                // キャラクター1
                characterInputRow(
                    title: "キャラ1",
                    imagePath: $viewModel.character1ImagePath,
                    expression: $viewModel.character1Expression
                )

                // キャラクター2
                characterInputRow(
                    title: "キャラ2",
                    imagePath: $viewModel.character2ImagePath,
                    expression: $viewModel.character2Expression
                )

                // キャラクター3（任意）
                characterInputRow(
                    title: "キャラ3",
                    imagePath: $viewModel.character3ImagePath,
                    expression: $viewModel.character3Expression
                )

                Divider()

                HStack {
                    Text("レイアウト:")
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: $viewModel.layoutStyle) {
                        Text("並んで歩く").tag("並んで歩く")
                        Text("向かい合う").tag("向かい合う")
                        Text("背中合わせ").tag("背中合わせ")
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    private func characterInputRow(
        title: String,
        imagePath: Binding<String>,
        expression: Binding<CharacterExpression>
    ) -> some View {
        HStack {
            Text("\(title):")
                .frame(width: 50, alignment: .leading)
            TextField("画像パス", text: imagePath)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            Button("参照") {}
            Text("表情:")
            Picker("", selection: expression) {
                ForEach(CharacterExpression.allCases) { exp in
                    Text(exp.rawValue).tag(exp)
                }
            }
            .labelsHidden()
            .frame(width: 100)
            Spacer()
        }
    }

    // MARK: - ボスレイドシーン
    private var bossRaidSceneContent: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("ボスレイド設定")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("（大型ボス vs パーティ構成）")
                    .font(.caption)
                    .foregroundColor(.gray)

                // ボス
                HStack {
                    Text("ボス:")
                        .frame(width: 60, alignment: .leading)
                    TextField("ボス画像パス", text: $viewModel.leftCharacterImagePath)
                        .textFieldStyle(.roundedBorder)
                    Button("参照") {}
                }

                Divider()

                Text("パーティメンバー（最大4人）")
                    .font(.subheadline)

                ForEach(0..<4) { i in
                    HStack {
                        Text("メンバー\(i+1):")
                            .frame(width: 80, alignment: .leading)
                        TextField("画像パス", text: .constant(""))
                            .textFieldStyle(.roundedBorder)
                        Button("参照") {}
                    }
                }
            }
            .padding(10)
        }
    }
}

#Preview {
    SceneBuilderSettingsView()
}
