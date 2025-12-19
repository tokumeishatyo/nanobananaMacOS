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
                    ForEach(Array(viewModel.panels.enumerated()), id: \.element.id) { index, panel in
                        PanelInputView(
                            panel: panel,
                            label: panelLabels[index]
                        )
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
}

// MARK: - Panel Input View

/// 各コマの入力セクション（ObservableObjectを直接バインド）
private struct PanelInputView: View {
    @ObservedObject var panel: MangaPanelData
    let label: String

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                // ヘッダー
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)

                // シーン説明
                HStack {
                    Text("シーン:")
                        .frame(width: 70, alignment: .leading)
                    TextField("背景、キャラクターの配置、表情、アクションなど", text: $panel.scene)
                        .textFieldStyle(.roundedBorder)
                }

                // セリフ1
                HStack(spacing: 8) {
                    Text("セリフ1:")
                        .frame(width: 70, alignment: .leading)

                    // キャラ選択（3択→ボタン）
                    Picker("", selection: $panel.speech1Char) {
                        ForEach(SpeechCharacter.allCases) { char in
                            Text(char.rawValue).tag(char)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    TextField("セリフ内容", text: $panel.speech1Text)
                        .textFieldStyle(.roundedBorder)

                    // 位置選択（2択→ボタン）
                    Picker("", selection: $panel.speech1Position) {
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

                    Picker("", selection: $panel.speech2Char) {
                        ForEach(SpeechCharacter.allCases) { char in
                            Text(char.rawValue).tag(char)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    TextField("セリフ内容（任意）", text: $panel.speech2Text)
                        .textFieldStyle(.roundedBorder)

                    Picker("", selection: $panel.speech2Position) {
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
                    TextField("ナレーション（任意）", text: $panel.narration)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(10)
        }
    }
}

#Preview {
    FourPanelSettingsView()
}
