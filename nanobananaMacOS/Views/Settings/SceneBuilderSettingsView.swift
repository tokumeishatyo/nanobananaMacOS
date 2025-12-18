import SwiftUI

/// シーンビルダー設定ウィンドウ（Python版準拠）
struct SceneBuilderSettingsView: View {
    @StateObject private var viewModel: SceneBuilderSettingsViewModel
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss
    var onApply: ((SceneBuilderSettingsViewModel) -> Void)?

    init(initialSettings: SceneBuilderSettingsViewModel? = nil, onApply: ((SceneBuilderSettingsViewModel) -> Void)? = nil) {
        self.onApply = onApply
        if let settings = initialSettings {
            let vm = SceneBuilderSettingsViewModel()
            // シーンタイプ
            vm.sceneType = settings.sceneType
            // 共通: 背景設定
            vm.backgroundSourceType = settings.backgroundSourceType
            vm.backgroundImagePath = settings.backgroundImagePath
            vm.backgroundDescription = settings.backgroundDescription
            // バトルシーン用
            vm.battleDimming = settings.battleDimming
            vm.leftCutinEnabled = settings.leftCutinEnabled
            vm.leftCutinImagePath = settings.leftCutinImagePath
            vm.leftCutinBlendMode = settings.leftCutinBlendMode
            vm.rightCutinEnabled = settings.rightCutinEnabled
            vm.rightCutinImagePath = settings.rightCutinImagePath
            vm.rightCutinBlendMode = settings.rightCutinBlendMode
            vm.collisionType = settings.collisionType
            vm.dominantSide = settings.dominantSide
            vm.borderVFX = settings.borderVFX
            vm.battleLeftCharImagePath = settings.battleLeftCharImagePath
            vm.battleLeftCharScale = settings.battleLeftCharScale
            vm.battleLeftCharName = settings.battleLeftCharName
            vm.battleLeftCharTraits = settings.battleLeftCharTraits
            vm.battleRightCharImagePath = settings.battleRightCharImagePath
            vm.battleRightCharScale = settings.battleRightCharScale
            vm.battleRightCharName = settings.battleRightCharName
            vm.battleRightCharTraits = settings.battleRightCharTraits
            vm.screenShake = settings.screenShake
            vm.showUI = settings.showUI
            // ストーリーシーン用
            vm.storyBlurAmount = settings.storyBlurAmount
            vm.storyLightingMood = settings.storyLightingMood
            vm.storyCustomMood = settings.storyCustomMood
            vm.storyLayout = settings.storyLayout
            vm.storyCustomLayout = settings.storyCustomLayout
            vm.storyDistance = settings.storyDistance
            vm.storyCharacterCount = settings.storyCharacterCount
            vm.storyCharacters = settings.storyCharacters
            vm.storyNarration = settings.storyNarration
            vm.storyDialogues = settings.storyDialogues
            // ボスレイド用
            vm.bossImagePath = settings.bossImagePath
            vm.bossScale = settings.bossScale
            vm.bossAllowCrop = settings.bossAllowCrop
            vm.partyMembers = settings.partyMembers
            vm.partyBaseScale = settings.partyBaseScale
            vm.convergenceEnabled = settings.convergenceEnabled
            vm.beamColor = settings.beamColor
            // 共通: 装飾テキストオーバーレイ
            vm.textOverlayItems = settings.textOverlayItems
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: SceneBuilderSettingsViewModel())
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
            // 合成タイプ選択
            HStack {
                Text("合成タイプ:")
                    .fontWeight(.semibold)
                Picker("", selection: $viewModel.sceneType) {
                    ForEach(SceneType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .frame(width: 180)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 12) {
                    // シーンタイプ別コンテンツ
                    switch viewModel.sceneType {
                    case .story:
                        storySceneContent
                    case .battle:
                        battleSceneContent
                    case .bossRaid:
                        bossRaidContent
                    }

                    // 装飾テキストオーバーレイ（全シーン共通）
                    textOverlaySection
                }
                .padding(16)
            }
            .sheet(isPresented: $viewModel.showTextOverlaySheet) {
                TextOverlayPlacementView(items: $viewModel.textOverlayItems)
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
        .frame(width: 850, height: 900)
    }

    // MARK: - ストーリーシーン
    private var storySceneContent: some View {
        VStack(spacing: 12) {
            // 背景設定
            storyBackgroundSection

            // 配置設定
            storyLayoutSection

            // キャラクター配置
            storyCharacterSection

            // ダイアログ設定
            storyDialogSection
        }
    }

    private var storyBackgroundSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("背景設定")
                    .font(.headline)
                    .fontWeight(.bold)

                // 背景タイプ選択
                HStack(spacing: 20) {
                    ForEach(BackgroundSourceType.allCases) { type in
                        HStack {
                            Image(systemName: viewModel.backgroundSourceType == type ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(viewModel.backgroundSourceType == type ? .accentColor : .gray)
                            Text(type.rawValue)
                        }
                        .onTapGesture {
                            viewModel.backgroundSourceType = type
                        }
                    }
                }

                if viewModel.backgroundSourceType == .file {
                    HStack {
                        Text("背景画像:")
                            .frame(width: 80, alignment: .leading)
                        TextField("背景画像パス", text: $viewModel.backgroundImagePath)
                            .textFieldStyle(.roundedBorder)
                        Button("参照") {
                            // TODO: ファイル選択
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("情景説明:")
                        TextEditor(text: $viewModel.backgroundDescription)
                            .frame(height: 60)
                            .border(Color.gray.opacity(0.3), width: 1)
                    }
                }

                // ぼかし・雰囲気
                HStack {
                    Text("ぼかし:")
                        .frame(width: 60, alignment: .leading)
                    Slider(value: $viewModel.storyBlurAmount, in: 0...100, step: 5)
                    Text("\(Int(viewModel.storyBlurAmount))")
                        .frame(width: 30)
                }

                HStack {
                    Text("雰囲気:")
                        .frame(width: 60, alignment: .leading)
                    Picker("", selection: $viewModel.storyLightingMood) {
                        ForEach(LightingMood.allCases) { mood in
                            Text(mood.rawValue).tag(mood)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                    Spacer()
                }

                if viewModel.storyLightingMood == .custom {
                    TextField("例: 雨上がりの午後、虹がかかる空", text: $viewModel.storyCustomMood)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(10)
        }
    }

    private var storyLayoutSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("配置設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    HStack {
                        Text("配置パターン:")
                        Picker("", selection: $viewModel.storyLayout) {
                            ForEach(StoryLayout.allCases) { layout in
                                Text(layout.rawValue).tag(layout)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    HStack {
                        Text("距離感:")
                        Picker("", selection: $viewModel.storyDistance) {
                            ForEach(StoryDistance.allCases) { distance in
                                Text(distance.rawValue).tag(distance)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }
                    Spacer()
                }

                if viewModel.storyLayout == .custom {
                    TextField("例: 背中合わせで立つ二人、夕日を見つめる", text: $viewModel.storyCustomLayout)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(10)
        }
    }

    private var storyCharacterSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("キャラクター配置")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Text("人数:")
                    Picker("", selection: $viewModel.storyCharacterCount) {
                        ForEach(CharacterCount.allCases) { count in
                            Text(count.rawValue).tag(count)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 70)
                }

                // キャラクター入力欄（横並び）
                HStack(alignment: .top, spacing: 8) {
                    ForEach(0..<viewModel.storyCharacterCount.intValue, id: \.self) { index in
                        storyCharacterInput(index: index)
                    }
                }
            }
            .padding(10)
        }
    }

    private func storyCharacterInput(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // ラベル
            Text(characterLabel(index: index, total: viewModel.storyCharacterCount.intValue))
                .font(.caption)
                .fontWeight(.semibold)

            // 画像
            HStack(spacing: 2) {
                TextField("画像", text: storyCharacterImageBinding(index: index))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Button("参照") {}
                    .font(.caption)
            }

            // 表情
            HStack {
                Text("表情:")
                    .font(.caption)
                TextField("笑顔", text: storyCharacterExpressionBinding(index: index))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }

            // 特徴
            HStack {
                Text("特徴:")
                    .font(.caption)
                TextField("黒髪", text: storyCharacterTraitsBinding(index: index))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
        }
        .padding(6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }

    private func characterLabel(index: Int, total: Int) -> String {
        if total == 1 { return "キャラ1" }
        if index == 0 { return "キャラ1（左端）" }
        return "キャラ\(index + 1)（\(index)の右隣）"
    }

    private var storyDialogSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("ダイアログ設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("ナレーション:")
                        .frame(width: 90, alignment: .leading)
                    TextField("今日から新学期が始まる", text: $viewModel.storyNarration)
                        .textFieldStyle(.roundedBorder)
                }

                // セリフ入力欄
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.storyCharacterCount.intValue, id: \.self) { index in
                        HStack {
                            Text("キャラ\(index + 1):")
                                .font(.caption)
                            TextField("セリフ", text: storyDialogueBinding(index: index))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                    }
                }
            }
            .padding(10)
        }
    }

    // MARK: - バトルシーン
    private var battleSceneContent: some View {
        VStack(spacing: 12) {
            // 背景設定
            battleBackgroundSection

            // カットイン演出
            battleCutinSection

            // 衝突設定
            battleCollisionSection

            // キャラクター配置
            battleCharacterSection

            // 画面効果
            battleEffectSection
        }
    }

    private var battleBackgroundSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("背景設定")
                    .font(.headline)
                    .fontWeight(.bold)

                // 背景タイプ選択
                HStack(spacing: 20) {
                    ForEach(BackgroundSourceType.allCases) { type in
                        HStack {
                            Image(systemName: viewModel.backgroundSourceType == type ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(viewModel.backgroundSourceType == type ? .accentColor : .gray)
                            Text(type.rawValue)
                        }
                        .onTapGesture {
                            viewModel.backgroundSourceType = type
                        }
                    }
                }

                if viewModel.backgroundSourceType == .file {
                    HStack {
                        Text("背景画像:")
                            .frame(width: 80, alignment: .leading)
                        TextField("背景画像パス", text: $viewModel.backgroundImagePath)
                            .textFieldStyle(.roundedBorder)
                        Button("参照") {}
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("情景説明:")
                        TextEditor(text: $viewModel.backgroundDescription)
                            .frame(height: 60)
                            .border(Color.gray.opacity(0.3), width: 1)
                    }
                }

                HStack {
                    Text("暗さ:")
                        .frame(width: 50, alignment: .leading)
                    Slider(value: $viewModel.battleDimming, in: 0...1, step: 0.1)
                    Text(String(format: "%.1f", viewModel.battleDimming))
                        .frame(width: 30)
                }
            }
            .padding(10)
        }
    }

    private var battleCutinSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("カットイン演出")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    // 左カットイン
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("左", isOn: $viewModel.leftCutinEnabled)
                            .toggleStyle(.checkbox)

                        HStack {
                            TextField("画像", text: $viewModel.leftCutinImagePath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                                .disabled(!viewModel.leftCutinEnabled)
                            Button("参照") {}
                                .disabled(!viewModel.leftCutinEnabled)
                        }

                        Picker("", selection: $viewModel.leftCutinBlendMode) {
                            ForEach(BlendMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                        .disabled(!viewModel.leftCutinEnabled)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)

                    // 右カットイン
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("右", isOn: $viewModel.rightCutinEnabled)
                            .toggleStyle(.checkbox)

                        HStack {
                            TextField("画像", text: $viewModel.rightCutinImagePath)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                                .disabled(!viewModel.rightCutinEnabled)
                            Button("参照") {}
                                .disabled(!viewModel.rightCutinEnabled)
                        }

                        Picker("", selection: $viewModel.rightCutinBlendMode) {
                            ForEach(BlendMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                        .disabled(!viewModel.rightCutinEnabled)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)

                    Spacer()
                }
            }
            .padding(10)
        }
    }

    private var battleCollisionSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("衝突設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    HStack {
                        Text("衝突タイプ:")
                        Picker("", selection: $viewModel.collisionType) {
                            ForEach(CollisionType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 140)
                    }

                    HStack {
                        Text("優勢:")
                        Picker("", selection: $viewModel.dominantSide) {
                            ForEach(DominantSide.allCases) { side in
                                Text(side.rawValue).tag(side)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }

                    HStack {
                        Text("境界エフェクト:")
                        Picker("", selection: $viewModel.borderVFX) {
                            ForEach(BorderVFX.allCases) { vfx in
                                Text(vfx.rawValue).tag(vfx)
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

    private var battleCharacterSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("キャラクター配置")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    // 左キャラ
                    VStack(alignment: .leading, spacing: 6) {
                        Text("左キャラクター")
                            .fontWeight(.semibold)

                        HStack {
                            TextField("画像パス", text: $viewModel.battleLeftCharImagePath)
                                .textFieldStyle(.roundedBorder)
                            Button("参照") {}
                            Text("スケール:")
                            TextField("1.2", text: $viewModel.battleLeftCharScale)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }

                        HStack {
                            Text("名前:")
                            TextField("AYASE KOYOMI", text: $viewModel.battleLeftCharName)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Text("特徴:")
                            TextField("長い黒髪、身長高め", text: $viewModel.battleLeftCharTraits)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // 右キャラ
                    VStack(alignment: .leading, spacing: 6) {
                        Text("右キャラクター")
                            .fontWeight(.semibold)

                        HStack {
                            TextField("画像パス", text: $viewModel.battleRightCharImagePath)
                                .textFieldStyle(.roundedBorder)
                            Button("参照") {}
                            Text("スケール:")
                            TextField("1.2", text: $viewModel.battleRightCharScale)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }

                        HStack {
                            Text("名前:")
                            TextField("SHINOMIYA RIN", text: $viewModel.battleRightCharName)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Text("特徴:")
                            TextField("ツインテール金髪", text: $viewModel.battleRightCharTraits)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
            }
            .padding(10)
        }
    }

    private var battleEffectSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("画面効果")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 30) {
                    HStack {
                        Text("画面揺れ:")
                        Picker("", selection: $viewModel.screenShake) {
                            ForEach(ScreenShake.allCases) { shake in
                                Text(shake.rawValue).tag(shake)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }

                    Toggle("UI表示", isOn: $viewModel.showUI)
                        .toggleStyle(.checkbox)

                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - ボスレイド
    private var bossRaidContent: some View {
        VStack(spacing: 12) {
            // ボス設定
            bossSection

            // パーティ設定
            partySection

            // 攻撃エフェクト
            attackEffectSection
        }
    }

    private var bossSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("巨大ボス設定")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("ボス画像:")
                        .frame(width: 80, alignment: .leading)
                    TextField("巨大ボス画像", text: $viewModel.bossImagePath)
                        .textFieldStyle(.roundedBorder)
                    Button("参照") {}
                }

                HStack {
                    Text("スケール:")
                        .frame(width: 80, alignment: .leading)
                    TextField("2.5", text: $viewModel.bossScale)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)

                    Toggle("画面からはみ出し許可", isOn: $viewModel.bossAllowCrop)
                        .toggleStyle(.checkbox)
                        .padding(.leading, 20)

                    Spacer()
                }
            }
            .padding(10)
        }
    }

    private var partySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("攻撃部隊（パーティ）")
                    .font(.headline)
                    .fontWeight(.bold)

                ForEach(0..<3, id: \.self) { index in
                    HStack {
                        Text("メンバー\(index + 1):")
                            .frame(width: 80, alignment: .leading)
                        TextField("ちびキャラ画像", text: partyMemberImageBinding(index: index))
                            .textFieldStyle(.roundedBorder)
                        Button("参照") {}
                        TextField("Jumping Slash", text: partyMemberActionBinding(index: index))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                }

                HStack {
                    Text("パーティ基本スケール:")
                    TextField("0.6", text: $viewModel.partyBaseScale)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                    Spacer()
                }
            }
            .padding(10)
        }
    }

    private var attackEffectSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text("集中砲火エフェクト")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 30) {
                    Toggle("集中砲火有効", isOn: $viewModel.convergenceEnabled)
                        .toggleStyle(.checkbox)

                    HStack {
                        Text("ビーム色:")
                        TextField("Blue & Pink Lasers", text: $viewModel.beamColor)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 180)
                            .disabled(!viewModel.convergenceEnabled)
                    }

                    Spacer()
                }
            }
            .padding(10)
        }
    }

    // MARK: - 装飾テキストオーバーレイ（全シーン共通）
    private var textOverlaySection: some View {
        GroupBox {
            HStack {
                Text("装飾テキスト:")
                    .font(.headline)
                    .fontWeight(.bold)

                Button("配置設定...") {
                    viewModel.showTextOverlaySheet = true
                }

                if viewModel.textOverlayItems.isEmpty {
                    Text("なし")
                        .foregroundColor(.gray)
                } else {
                    Text("\(viewModel.textOverlayItems.count)個配置")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding(10)
        }
    }

    // MARK: - Bindings Helper
    private func storyCharacterImageBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.storyCharacters[index].imagePath },
            set: { viewModel.storyCharacters[index].imagePath = $0 }
        )
    }

    private func storyCharacterExpressionBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.storyCharacters[index].expression },
            set: { viewModel.storyCharacters[index].expression = $0 }
        )
    }

    private func storyCharacterTraitsBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.storyCharacters[index].traits },
            set: { viewModel.storyCharacters[index].traits = $0 }
        )
    }

    private func storyDialogueBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.storyDialogues[index] },
            set: { viewModel.storyDialogues[index] = $0 }
        )
    }

    private func partyMemberImageBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.partyMembers[index].imagePath },
            set: { viewModel.partyMembers[index].imagePath = $0 }
        )
    }

    private func partyMemberActionBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.partyMembers[index].action },
            set: { viewModel.partyMembers[index].action = $0 }
        )
    }
}

#Preview {
    SceneBuilderSettingsView()
}
