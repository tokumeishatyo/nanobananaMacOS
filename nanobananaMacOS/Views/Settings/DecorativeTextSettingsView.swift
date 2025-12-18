import SwiftUI

/// 装飾テキスト設定ウィンドウ（Python版準拠）
struct DecorativeTextSettingsView: View {
    @StateObject private var viewModel = DecorativeTextSettingsViewModel()
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((DecorativeTextSettingsViewModel) -> Void)?

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
        .frame(width: 650, height: 550)
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

                // フォント・サイズ（3択ずつ→ボタン）
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("フォント:")
                            .font(.caption)
                        Picker("", selection: $viewModel.titleFont) {
                            ForEach(TitleFont.allCases) { font in
                                Text(font.rawValue).tag(font)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 220)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("サイズ:")
                            .font(.caption)
                        Picker("", selection: $viewModel.titleSize) {
                            ForEach(TitleSize.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                }

                // 文字色・縁取り（5-6択→ドロップダウン）
                HStack(spacing: 20) {
                    HStack {
                        Text("文字色:")
                            .frame(width: 50, alignment: .leading)
                        Picker("", selection: $viewModel.titleColor) {
                            ForEach(GradientColor.allCases) { color in
                                Text(color.rawValue).tag(color)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 130)
                    }

                    HStack {
                        Text("縁取り:")
                            .frame(width: 50, alignment: .leading)
                        Picker("", selection: $viewModel.titleOutline) {
                            ForEach(OutlineColor.allCases) { color in
                                Text(color.rawValue).tag(color)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                    }
                    Spacer()
                }

                // 発光効果・シャドウ
                HStack(spacing: 20) {
                    HStack {
                        Text("発光効果:")
                            .frame(width: 60, alignment: .leading)
                        Picker("", selection: $viewModel.titleGlow) {
                            ForEach(GlowEffect.allCases) { effect in
                                Text(effect.rawValue).tag(effect)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 110)
                    }

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

                // 表現・配色（3-4択→ボタン）
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("表現:")
                            .font(.caption)
                        Picker("", selection: $viewModel.calloutType) {
                            ForEach(CalloutType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 220)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("配色:")
                            .font(.caption)
                        Picker("", selection: $viewModel.calloutColor) {
                            ForEach(CalloutColor.allCases) { color in
                                Text(color.rawValue).tag(color)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 280)
                    }
                }

                // 回転・変形（5択/4択→ドロップダウン/ボタン）
                HStack(spacing: 20) {
                    HStack {
                        Text("回転:")
                            .frame(width: 40, alignment: .leading)
                        Picker("", selection: $viewModel.calloutRotation) {
                            ForEach(TextRotation.allCases) { rotation in
                                Text(rotation.rawValue).tag(rotation)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("変形:")
                            .font(.caption)
                        Picker("", selection: $viewModel.calloutDistortion) {
                            ForEach(TextDistortion.allCases) { distortion in
                                Text(distortion.rawValue).tag(distortion)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 240)
                    }
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

                // デザイン（3択→ボタン）
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("デザイン:")
                            .font(.caption)
                        Picker("", selection: $viewModel.nameTagDesign) {
                            ForEach(NameTagDesign.allCases) { design in
                                Text(design.rawValue).tag(design)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }

                    HStack {
                        Text("回転:")
                            .frame(width: 40, alignment: .leading)
                        Picker("", selection: $viewModel.nameTagRotation) {
                            ForEach(TextRotation.allCases) { rotation in
                                Text(rotation.rawValue).tag(rotation)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                }
            }
            .padding(10)
        }
    }

    // MARK: - メッセージウィンドウスタイル
    private var messageWindowStyleSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("メッセージウィンドウスタイル")
                    .font(.headline)
                    .fontWeight(.bold)

                // モード選択（3択→ボタン）
                VStack(alignment: .leading, spacing: 4) {
                    Text("モード:")
                        .font(.caption)
                    Picker("", selection: $viewModel.messageMode) {
                        ForEach(MessageWindowMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }

                // フルスペック・顔アイコンのみ時: 話者名・スタイル
                if viewModel.messageMode == .full {
                    HStack(spacing: 20) {
                        HStack {
                            Text("話者名:")
                                .frame(width: 50, alignment: .leading)
                            TextField("彩瀬こよみ", text: $viewModel.speakerName)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                        }

                        HStack {
                            Text("スタイル:")
                                .frame(width: 60, alignment: .leading)
                            Picker("", selection: $viewModel.messageStyle) {
                                ForEach(MessageWindowStyle.allCases) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 150)
                        }
                        Spacer()
                    }
                }

                // フルスペック・セリフのみ時: 枠デザイン・透明度
                if viewModel.messageMode == .full || viewModel.messageMode == .textOnly {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("枠デザイン:")
                                .font(.caption)
                            Picker("", selection: $viewModel.messageFrameType) {
                                ForEach(MessageFrameType.allCases) { frame in
                                    Text(frame.rawValue).tag(frame)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 380)
                        }

                        HStack {
                            Text("透明度:")
                            Slider(value: $viewModel.messageOpacity, in: 0.3...1.0, step: 0.1)
                                .frame(width: 80)
                            Text(String(format: "%.1f", viewModel.messageOpacity))
                                .frame(width: 30)
                        }
                    }
                }

                // フルスペック・顔のみ時: 顔アイコン設定
                if viewModel.messageMode == .full || viewModel.messageMode == .faceOnly {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("顔アイコン位置:")
                            .font(.caption)
                        Picker("", selection: $viewModel.faceIconPosition) {
                            ForEach(FaceIconPosition.allCases) { pos in
                                Text(pos.rawValue).tag(pos)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }

                    HStack {
                        Text("顔アイコン画像:")
                            .frame(width: 100, alignment: .leading)
                        TextField("（任意）衣装/ポーズ画像から顔を使用", text: $viewModel.faceIconImagePath)
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
