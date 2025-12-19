import SwiftUI
import UniformTypeIdentifiers

/// 4コマ漫画設定ウィンドウ（Python版準拠）
struct FourPanelSettingsView: View {
    @StateObject private var viewModel: FourPanelSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((FourPanelSettingsViewModel) -> Void)?

    private let panelLabels = ["1コマ目（起）", "2コマ目（承）", "3コマ目（転）", "4コマ目（結）"]

    // MARK: - File Picker State
    private enum FilePickerTarget {
        case character1
        case character2
    }
    @State private var showingFilePicker = false
    @State private var filePickerTarget: FilePickerTarget = .character1

    init(initialSettings: FourPanelSettingsViewModel? = nil, onApply: ((FourPanelSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = FourPanelSettingsViewModel()
            vm.character1Name = settings.character1Name
            vm.character1Description = settings.character1Description
            vm.character1ImagePath = settings.character1ImagePath
            vm.character2Name = settings.character2Name
            vm.character2Description = settings.character2Description
            vm.character2ImagePath = settings.character2ImagePath
            vm.panels = settings.panels
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: FourPanelSettingsViewModel())
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
                    // 登場人物設定
                    characterSection

                    // 4コマ説明
                    panelHeaderSection

                    // 各コマの入力
                    ForEach(0..<4, id: \.self) { index in
                        panelInputSection(index: index)
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
        .frame(width: 800, height: 1000)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
    }

    // MARK: - 登場人物設定
    private var characterSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("登場人物")
                    .font(.headline)
                    .fontWeight(.bold)

                // キャラ1
                HStack(spacing: 10) {
                    Text("キャラ1名:")
                        .frame(width: 70, alignment: .leading)
                    TextField("キャラクター名", text: $viewModel.character1Name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)

                    Text("説明:")
                        .frame(width: 40, alignment: .leading)
                    TextField("外見の説明", text: $viewModel.character1Description)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("画像1:")
                        .frame(width: 70, alignment: .leading)
                    TextField("キャラクター参照画像パス", text: $viewModel.character1ImagePath)
                        .textFieldStyle(.roundedBorder)
                    Button("参照") {
                        filePickerTarget = .character1
                        showingFilePicker = true
                    }
                }

                Divider()

                // キャラ2（任意）
                HStack(spacing: 10) {
                    Text("キャラ2名:")
                        .frame(width: 70, alignment: .leading)
                    TextField("キャラクター名（任意）", text: $viewModel.character2Name)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)

                    Text("説明:")
                        .frame(width: 40, alignment: .leading)
                    TextField("外見の説明", text: $viewModel.character2Description)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("画像2:")
                        .frame(width: 70, alignment: .leading)
                    TextField("キャラクター参照画像パス（任意）", text: $viewModel.character2ImagePath)
                        .textFieldStyle(.roundedBorder)
                    Button("参照") {
                        filePickerTarget = .character2
                        showingFilePicker = true
                    }
                }
            }
            .padding(10)
        }
    }

    // MARK: - File Selection Handler

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            switch filePickerTarget {
            case .character1:
                viewModel.character1ImagePath = url.path
            case .character2:
                viewModel.character2ImagePath = url.path
            }
        case .failure(let error):
            print("ファイル選択エラー: \(error.localizedDescription)")
        }
    }

    // MARK: - 4コマ説明ヘッダー
    private var panelHeaderSection: some View {
        HStack {
            Text("4コマ内容")
                .font(.headline)
                .fontWeight(.bold)

            Text("起承転結の流れで4コマを設定してください")
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()
        }
    }

    // MARK: - 各コマの入力セクション
    private func panelInputSection(index: Int) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                // ヘッダー
                Text(panelLabels[index])
                    .font(.subheadline)
                    .fontWeight(.bold)

                // シーン説明
                HStack {
                    Text("シーン:")
                        .frame(width: 70, alignment: .leading)
                    TextField("背景、キャラクターの配置、表情、アクションなど", text: panelSceneBinding(index: index))
                        .textFieldStyle(.roundedBorder)
                }

                // セリフ1
                HStack(spacing: 8) {
                    Text("セリフ1:")
                        .frame(width: 70, alignment: .leading)

                    // キャラ選択（3択→ボタン）
                    Picker("", selection: panelSpeech1CharBinding(index: index)) {
                        ForEach(SpeechCharacter.allCases) { char in
                            Text(char.rawValue).tag(char)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    TextField("セリフ内容", text: panelSpeech1TextBinding(index: index))
                        .textFieldStyle(.roundedBorder)

                    // 位置選択（2択→ボタン）
                    Picker("", selection: panelSpeech1PosBinding(index: index)) {
                        ForEach(SpeechPosition.allCases) { pos in
                            Text(pos.rawValue).tag(pos)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }

                // セリフ2（同時セリフ対応）
                HStack(spacing: 8) {
                    Text("セリフ2:")
                        .frame(width: 70, alignment: .leading)

                    Picker("", selection: panelSpeech2CharBinding(index: index)) {
                        ForEach(SpeechCharacter.allCases) { char in
                            Text(char.rawValue).tag(char)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    TextField("セリフ内容（任意）", text: panelSpeech2TextBinding(index: index))
                        .textFieldStyle(.roundedBorder)

                    Picker("", selection: panelSpeech2PosBinding(index: index)) {
                        ForEach(SpeechPosition.allCases) { pos in
                            Text(pos.rawValue).tag(pos)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }

                // ナレーション
                HStack {
                    Text("ナレーション:")
                        .frame(width: 70, alignment: .leading)
                    TextField("ナレーション（任意）", text: panelNarrationBinding(index: index))
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(10)
        }
    }

    // MARK: - Bindings Helper
    private func panelSceneBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.panels[index].scene },
            set: { viewModel.panels[index].scene = $0 }
        )
    }

    private func panelSpeech1CharBinding(index: Int) -> Binding<SpeechCharacter> {
        Binding(
            get: { viewModel.panels[index].speech1Char },
            set: { viewModel.panels[index].speech1Char = $0 }
        )
    }

    private func panelSpeech1TextBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.panels[index].speech1Text },
            set: { viewModel.panels[index].speech1Text = $0 }
        )
    }

    private func panelSpeech1PosBinding(index: Int) -> Binding<SpeechPosition> {
        Binding(
            get: { viewModel.panels[index].speech1Position },
            set: { viewModel.panels[index].speech1Position = $0 }
        )
    }

    private func panelSpeech2CharBinding(index: Int) -> Binding<SpeechCharacter> {
        Binding(
            get: { viewModel.panels[index].speech2Char },
            set: { viewModel.panels[index].speech2Char = $0 }
        )
    }

    private func panelSpeech2TextBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.panels[index].speech2Text },
            set: { viewModel.panels[index].speech2Text = $0 }
        )
    }

    private func panelSpeech2PosBinding(index: Int) -> Binding<SpeechPosition> {
        Binding(
            get: { viewModel.panels[index].speech2Position },
            set: { viewModel.panels[index].speech2Position = $0 }
        )
    }

    private func panelNarrationBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.panels[index].narration },
            set: { viewModel.panels[index].narration = $0 }
        )
    }
}

#Preview {
    FourPanelSettingsView()
}
