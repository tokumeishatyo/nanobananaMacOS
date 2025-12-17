import SwiftUI

/// 4コマ漫画設定ウィンドウ
struct FourPanelSettingsView: View {
    @StateObject private var viewModel = FourPanelSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((FourPanelSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // キャラクター設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("登場キャラクター")
                                .font(.headline)
                                .fontWeight(.bold)

                            // キャラ1
                            VStack(alignment: .leading, spacing: 8) {
                                Text("キャラクター1")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                HStack {
                                    Text("名前:")
                                        .frame(width: 60, alignment: .leading)
                                    TextField("名前", text: $viewModel.character1Name)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)

                                    Text("画像:")
                                        .frame(width: 40, alignment: .leading)
                                    TextField("参照画像", text: $viewModel.character1ImagePath)
                                        .textFieldStyle(.roundedBorder)
                                    Button("参照") {}
                                }

                                HStack {
                                    Text("説明:")
                                        .frame(width: 60, alignment: .leading)
                                    TextField("キャラの特徴", text: $viewModel.character1Description)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }

                            Divider()

                            // キャラ2（任意）
                            VStack(alignment: .leading, spacing: 8) {
                                Text("キャラクター2（任意）")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                HStack {
                                    Text("名前:")
                                        .frame(width: 60, alignment: .leading)
                                    TextField("名前", text: $viewModel.character2Name)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 120)

                                    Text("画像:")
                                        .frame(width: 40, alignment: .leading)
                                    TextField("参照画像", text: $viewModel.character2ImagePath)
                                        .textFieldStyle(.roundedBorder)
                                    Button("参照") {}
                                }

                                HStack {
                                    Text("説明:")
                                        .frame(width: 60, alignment: .leading)
                                    TextField("キャラの特徴", text: $viewModel.character2Description)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding(10)
                    }

                    // 各コマの内容
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("各コマの内容（起承転結）")
                                .font(.headline)
                                .fontWeight(.bold)

                            panelInputRow(label: "1コマ目（起）:", content: $viewModel.panel1Content, dialogue: $viewModel.panel1Dialogue)
                            panelInputRow(label: "2コマ目（承）:", content: $viewModel.panel2Content, dialogue: $viewModel.panel2Dialogue)
                            panelInputRow(label: "3コマ目（転）:", content: $viewModel.panel3Content, dialogue: $viewModel.panel3Dialogue)
                            panelInputRow(label: "4コマ目（結）:", content: $viewModel.panel4Content, dialogue: $viewModel.panel4Dialogue)
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
        .frame(width: 750, height: 700)
    }

    private func panelInputRow(label: String, content: Binding<String>, dialogue: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack {
                Text("内容:")
                    .frame(width: 50, alignment: .leading)
                TextField("シーンの説明", text: content)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Text("セリフ:")
                    .frame(width: 50, alignment: .leading)
                TextField("キャラのセリフ（任意）", text: dialogue)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    FourPanelSettingsView()
}
