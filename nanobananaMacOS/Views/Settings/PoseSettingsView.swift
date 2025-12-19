import SwiftUI
import UniformTypeIdentifiers

/// ポーズ設定ウィンドウ（Python版準拠）
struct PoseSettingsView: View {
    @StateObject private var viewModel: PoseSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    @State private var showingFilePicker = false
    @State private var filePickerTarget: FilePickerTarget = .outfitSheet

    private enum FilePickerTarget {
        case outfitSheet
        case poseReference
    }
    var onApply: ((PoseSettingsViewModel) -> Void)?

    init(initialSettings: PoseSettingsViewModel? = nil, onApply: ((PoseSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = PoseSettingsViewModel()
            vm.selectedPreset = settings.selectedPreset
            vm.usePoseCapture = settings.usePoseCapture
            vm.poseReferenceImagePath = settings.poseReferenceImagePath
            vm.outfitSheetImagePath = settings.outfitSheetImagePath
            vm.eyeLine = settings.eyeLine
            vm.expression = settings.expression
            vm.expressionDetail = settings.expressionDetail
            vm.actionDescription = settings.actionDescription
            vm.includeEffects = settings.includeEffects
            vm.transparentBackground = settings.transparentBackground
            vm.windEffect = settings.windEffect
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: PoseSettingsViewModel())
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
                VStack(spacing: 12) {
                    // MARK: - ポーズプリセット
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ポーズプリセット")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("よく使うポーズを選択すると動作説明が自動入力されます")
                                .font(.caption)
                                .foregroundColor(.gray)

                            // プリセット選択とポーズキャプチャ（横並び）
                            HStack(spacing: 20) {
                                Picker("", selection: $viewModel.selectedPreset) {
                                    ForEach(PosePreset.allCases) { preset in
                                        Text(preset.rawValue).tag(preset)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 200)
                                .disabled(viewModel.usePoseCapture)

                                Toggle("参考画像のポーズをキャプチャ", isOn: $viewModel.usePoseCapture)
                            }

                            // ポーズ参考画像パス
                            HStack {
                                Text("ポーズ参考画像:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("ポーズを取り込みたい画像のパス", text: $viewModel.poseReferenceImagePath)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(!viewModel.usePoseCapture)
                                Button("参照") {
                                    filePickerTarget = .poseReference
                                    showingFilePicker = true
                                }
                                .disabled(!viewModel.usePoseCapture)
                            }

                            Text("※ 参考画像の著作権はユーザー責任です")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(10)
                    }

                    // MARK: - 入力画像（衣装着用三面図）
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("入力画像（衣装着用三面図）")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("衣装着用三面図、または任意のキャラ画像を指定")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack {
                                Text("画像:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("衣装着用三面図の画像パス", text: $viewModel.outfitSheetImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    filePickerTarget = .outfitSheet
                                    showingFilePicker = true
                                }
                            }

                            Text("※ 顔・衣装の同一性は常に保持されます（ポーズのみ変更）")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(10)
                    }

                    // MARK: - 向き・表情
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("向き・表情")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack(spacing: 20) {
                                HStack {
                                    Text("目線:")
                                        .frame(width: 40, alignment: .leading)
                                    Picker("", selection: $viewModel.eyeLine) {
                                        ForEach(EyeLine.allCases) { line in
                                            Text(line.rawValue).tag(line)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: 100)
                                }

                                HStack {
                                    Text("表情:")
                                        .frame(width: 40, alignment: .leading)
                                    Picker("", selection: $viewModel.expression) {
                                        ForEach(PoseExpression.allCases) { exp in
                                            Text(exp.rawValue).tag(exp)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: 100)
                                }
                                Spacer()
                            }

                            HStack {
                                Text("表情補足:")
                                    .frame(width: 70, alignment: .leading)
                                TextField("例：苦笑い、泣き笑い、ニヤリ", text: $viewModel.expressionDetail)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(10)
                    }

                    // MARK: - 動作説明
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("動作説明")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("ポーズや動作を自由に記述してください（日本語/英語どちらでも可）")
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField("例：椅子に座ってコーヒーを飲む、手を振る、考え込むポーズ", text: $viewModel.actionDescription)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(10)
                    }

                    // MARK: - ビジュアル効果
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ビジュアル効果")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack(spacing: 30) {
                                Toggle("エフェクトを描画する（合成用はOFF推奨）", isOn: $viewModel.includeEffects)

                                HStack {
                                    Text("風の影響:")
                                    Picker("", selection: $viewModel.windEffect) {
                                        ForEach(WindEffect.allCases) { wind in
                                            Text(wind.rawValue).tag(wind)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 120, alignment: .leading)
                                }
                            }

                            Toggle("背景を透過にする（合成用）", isOn: $viewModel.transparentBackground)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(width: 700, height: 800)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.png, .jpeg, .gif, .webP],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    switch filePickerTarget {
                    case .outfitSheet:
                        viewModel.outfitSheetImagePath = url.path
                    case .poseReference:
                        viewModel.poseReferenceImagePath = url.path
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    PoseSettingsView()
}
