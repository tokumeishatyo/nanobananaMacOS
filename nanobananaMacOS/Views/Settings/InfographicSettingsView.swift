// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// インフォグラフィック設定ウィンドウ
struct InfographicSettingsView: View {
    @StateObject private var viewModel: InfographicSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((InfographicSettingsViewModel) -> Void)?

    private enum FilePickerTarget {
        case mainCharacter
        case subCharacter
    }
    @State private var showingFilePicker = false
    @State private var filePickerTarget: FilePickerTarget = .mainCharacter

    init(initialSettings: InfographicSettingsViewModel? = nil, onApply: ((InfographicSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = InfographicSettingsViewModel()
            vm.infographicStyle = settings.infographicStyle
            vm.outputLanguage = settings.outputLanguage
            vm.customLanguage = settings.customLanguage
            vm.mainTitle = settings.mainTitle
            vm.subtitle = settings.subtitle
            vm.mainCharacterImagePath = settings.mainCharacterImagePath
            vm.subCharacterImagePath = settings.subCharacterImagePath
            vm.sections = settings.sections
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: InfographicSettingsViewModel())
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
                                    filePickerTarget = .mainCharacter
                                    showingFilePicker = true
                                }
                            }

                            HStack {
                                Text("おまけ:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("ちびキャラなど（任意）", text: $viewModel.subCharacterImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    filePickerTarget = .subCharacter
                                    showingFilePicker = true
                                }
                            }
                        }
                        .padding(10)
                    }

                    // セクション設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("情報セクション")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("""
                            位置レイアウト（空欄のセクションは無視されます）:
                            [1] [2] [3]
                            [4] 画像 [5]
                            [6] [7] [8]
                            """)
                            .font(.caption)
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
        .frame(width: 750, height: 1000)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    switch filePickerTarget {
                    case .mainCharacter:
                        viewModel.mainCharacterImagePath = url.path
                    case .subCharacter:
                        viewModel.subCharacterImagePath = url.path
                    }
                }
            case .failure(let error):
                print("ファイル選択エラー: \(error.localizedDescription)")
            }
        }
    }

    private func sectionRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("[\(index + 1)]")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 30, alignment: .leading)

                TextField("タイトル", text: Binding(
                    get: { viewModel.sections[index].title },
                    set: { viewModel.sections[index].title = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)

                TextField("説明", text: Binding(
                    get: { viewModel.sections[index].content },
                    set: { viewModel.sections[index].content = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    InfographicSettingsView()
}
