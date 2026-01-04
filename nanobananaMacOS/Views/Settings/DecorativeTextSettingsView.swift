// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 装飾テキスト設定ウィンドウ（Python版準拠）
struct DecorativeTextSettingsView: View {
    @StateObject private var viewModel: DecorativeTextSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((DecorativeTextSettingsViewModel) -> Void)?

    init(initialSettings: DecorativeTextSettingsViewModel? = nil, onApply: ((DecorativeTextSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = DecorativeTextSettingsViewModel()
            vm.textType = settings.textType
            vm.text = settings.text
            vm.transparentBackground = settings.transparentBackground
            vm.titleFont = settings.titleFont
            vm.titleSize = settings.titleSize
            vm.titleColor = settings.titleColor
            vm.titleOutline = settings.titleOutline
            vm.titleGlow = settings.titleGlow
            vm.titleShadow = settings.titleShadow
            vm.calloutType = settings.calloutType
            vm.calloutColor = settings.calloutColor
            vm.calloutRotation = settings.calloutRotation
            vm.calloutDistortion = settings.calloutDistortion
            vm.nameTagDesign = settings.nameTagDesign
            vm.nameTagRotation = settings.nameTagRotation
            vm.messageMode = settings.messageMode
            vm.speakerName = settings.speakerName
            vm.messageStyle = settings.messageStyle
            vm.messageFrameType = settings.messageFrameType
            vm.messageOpacity = settings.messageOpacity
            vm.faceIconPosition = settings.faceIconPosition
            vm.faceIconImagePath = settings.faceIconImagePath
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: DecorativeTextSettingsViewModel())
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
                    // テキストタイプ選択
                    typeSelectionSection

                    // テキスト入力
                    textInputSection

                    // タイプ別スタイル設定
                    switch viewModel.textType {
                    case .skillName:
                        skillNameStyleSection
                    case .catchphrase:
                        calloutStyleSection
                    case .namePlate:
                        nameTagStyleSection
                    case .messageWindow:
                        messageWindowStyleSection
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
        .frame(width: 650, height: 650)
    }

    // MARK: - テキストタイプ選択
    private var typeSelectionSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("テキストタイプ")
                    .font(.headline)
                    .fontWeight(.bold)

                Picker("", selection: $viewModel.textType) {
                    ForEach(DecorativeTextType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.textType.description)
                    .font(.caption)
                    .foregroundColor(.gray)

                Toggle("背景透過（合成用素材として出力）", isOn: $viewModel.transparentBackground)
            }
            .padding(10)
        }
    }

    // MARK: - テキスト入力
    private var textInputSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("テキスト内容")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("テキスト:")
                        .frame(width: 70, alignment: .leading)
                    TextField(viewModel.textType.placeholder, text: $viewModel.text)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(10)
        }
    }

    // MARK: - 技名テロップスタイル
    private var skillNameStyleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("技名テロップスタイル")
                    .font(.headline)
                    .fontWeight(.bold)

                // フォント・サイズ
                HStack {
                    Text("フォント:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.titleFont) {
                        ForEach(TitleFont.allCases) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                    Spacer()
                }

                HStack {
                    Text("サイズ:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.titleSize) {
                        ForEach(TitleSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    Spacer()
                }

                // 文字色・縁取り
                HStack {
                    Text("文字色:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.titleColor) {
                        ForEach(GradientColor.allCases) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 130, alignment: .leading)
                    Spacer()
                }

                HStack {
                    Text("縁取り:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.titleOutline) {
                        ForEach(OutlineColor.allCases) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 80, alignment: .leading)
                    Spacer()
                }

                // 発光効果・シャドウ
                HStack {
                    Text("発光効果:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.titleGlow) {
                        ForEach(GlowEffect.allCases) { effect in
                            Text(effect.rawValue).tag(effect)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 110, alignment: .leading)
                    Toggle("ドロップシャドウ", isOn: $viewModel.titleShadow)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - 決め台詞スタイル
    private var calloutStyleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("決め台詞スタイル")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("表現:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.calloutType) {
                        ForEach(CalloutType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                    Spacer()
                }

                HStack {
                    Text("配色:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.calloutColor) {
                        ForEach(CalloutColor.allCases) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 280)
                    Spacer()
                }

                HStack {
                    Text("回転:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.calloutRotation) {
                        ForEach(TextRotation.allCases) { rotation in
                            Text(rotation.rawValue).tag(rotation)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 120, alignment: .leading)
                    Spacer()
                }

                HStack {
                    Text("変形:")
                        .frame(width: 50, alignment: .leading)
                    Picker("", selection: $viewModel.calloutDistortion) {
                        ForEach(TextDistortion.allCases) { distortion in
                            Text(distortion.rawValue).tag(distortion)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - キャラ名プレートスタイル
    private var nameTagStyleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("キャラ名プレートスタイル")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("デザイン:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.nameTagDesign) {
                        ForEach(NameTagDesign.allCases) { design in
                            Text(design.rawValue).tag(design)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                    Spacer()
                }

                HStack {
                    Text("回転:")
                        .frame(width: 70, alignment: .leading)
                    Picker("", selection: $viewModel.nameTagRotation) {
                        ForEach(TextRotation.allCases) { rotation in
                            Text(rotation.rawValue).tag(rotation)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 120, alignment: .leading)
                    Spacer()
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - メッセージウィンドウスタイル
    private var messageWindowStyleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("メッセージウィンドウスタイル")
                    .font(.headline)
                    .fontWeight(.bold)

                // モード選択
                HStack {
                    Text("モード:")
                        .frame(width: 100, alignment: .leading)
                    Picker("", selection: $viewModel.messageMode) {
                        ForEach(MessageWindowMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 380, alignment: .leading)
                    Spacer()
                }

                // フルスペック時: 話者名・スタイル
                if viewModel.messageMode == .full {
                    HStack {
                        Text("話者名:")
                            .frame(width: 100, alignment: .leading)
                        TextField("彩瀬こよみ", text: $viewModel.speakerName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        Spacer()
                    }

                    HStack {
                        Text("スタイル:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $viewModel.messageStyle) {
                            ForEach(MessageWindowStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 380, alignment: .leading)
                        Spacer()
                    }
                }

                // フルスペック・セリフのみ時: 枠デザイン・透明度
                if viewModel.messageMode == .full || viewModel.messageMode == .textOnly {
                    HStack {
                        Text("枠デザイン:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $viewModel.messageFrameType) {
                            ForEach(MessageFrameType.allCases) { frame in
                                Text(frame.rawValue).tag(frame)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 380, alignment: .leading)
                        Spacer()
                    }

                    HStack {
                        Text("枠透明度:")
                            .frame(width: 100, alignment: .leading)
                        Slider(value: $viewModel.messageOpacity, in: 0.3...1.0, step: 0.1)
                            .frame(width: 150)
                        Text(String(format: "%.1f", viewModel.messageOpacity))
                            .frame(width: 30)
                        Spacer()
                    }
                }

                // フルスペック・顔のみ時: 顔アイコン設定
                if viewModel.messageMode == .full || viewModel.messageMode == .faceOnly {
                    HStack {
                        Text("顔アイコン位置:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $viewModel.faceIconPosition) {
                            ForEach(FaceIconPosition.allCases) { pos in
                                Text(pos.rawValue).tag(pos)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 380, alignment: .leading)
                        Spacer()
                    }

                    ImageDropField(
                        imagePath: $viewModel.faceIconImagePath,
                        label: "顔アイコン画像:",
                        placeholder: "衣装/ポーズ画像をドロップ（任意）"
                    )
                }
            }
            .padding(10)
        }
    }
}

#Preview {
    DecorativeTextSettingsView()
}
