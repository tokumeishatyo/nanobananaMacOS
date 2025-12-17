import SwiftUI

/// 顔三面図設定ウィンドウ
struct FaceSheetSettingsView: View {
    @StateObject private var viewModel = FaceSheetSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((FaceSheetSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // コンテンツエリア
            ScrollView {
                VStack(spacing: 16) {
                    // キャラクター情報セクション
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("キャラクター情報")
                                .font(.headline)
                                .fontWeight(.bold)

                            // 名前
                            HStack {
                                Text("名前:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("キャラクター名", text: $viewModel.characterName)
                                    .textFieldStyle(.roundedBorder)
                            }

                            // スタイル
                            HStack {
                                Text("スタイル:")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.characterStyle) {
                                    ForEach(CharacterStyle.allCases) { style in
                                        Text(style.rawValue).tag(style)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150)
                                Spacer()
                            }

                            // 参照画像
                            HStack {
                                Text("参照画像:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("参照画像パス（任意）", text: $viewModel.referenceImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }

                            // 外見説明
                            VStack(alignment: .leading, spacing: 4) {
                                Text("外見説明:")
                                TextEditor(text: $viewModel.appearanceDescription)
                                    .frame(height: 120)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .overlay(
                                        Group {
                                            if viewModel.appearanceDescription.isEmpty {
                                                Text(viewModel.placeholderText)
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(8)
                                                    .allowsHitTesting(false)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                            }
                        }
                        .padding(10)
                    }
                }
                .padding(16)
            }

            Divider()

            // ボタンエリア
            HStack {
                Spacer()
                Button("適用") {
                    onApply?(viewModel)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])

                Button("キャンセル") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(16)
        }
        .frame(width: 600, height: 400)
    }
}

#Preview {
    FaceSheetSettingsView()
}
