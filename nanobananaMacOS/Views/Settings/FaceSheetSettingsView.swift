import SwiftUI
import UniformTypeIdentifiers

/// 顔三面図設定ウィンドウ
struct FaceSheetSettingsView: View {
    @StateObject private var viewModel: FaceSheetSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    @State private var showingFilePicker = false
    var onApply: ((FaceSheetSettingsViewModel) -> Void)?

    init(initialSettings: FaceSheetSettingsViewModel? = nil, onApply: ((FaceSheetSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            // 既存設定がある場合はコピーして復元
            let vm = FaceSheetSettingsViewModel()
            vm.characterName = settings.characterName
            vm.referenceImagePath = settings.referenceImagePath
            vm.appearanceDescription = settings.appearanceDescription
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: FaceSheetSettingsViewModel())
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

                            // 参照画像
                            HStack {
                                Text("参照画像:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("参照画像パス（任意）", text: $viewModel.referenceImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    showingFilePicker = true
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
                    dismissWindow()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])

                Button("キャンセル") {
                    dismissWindow()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(16)
        }
        .frame(width: 600, height: 400)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.png, .jpeg, .gif, .webP],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.referenceImagePath = url.path
                }
            case .failure(let error):
                print("ファイル選択エラー: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    FaceSheetSettingsView(initialSettings: nil, onApply: nil)
}
