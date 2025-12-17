import SwiftUI

/// ポーズ設定ウィンドウ
struct PoseSettingsView: View {
    @StateObject private var viewModel = PoseSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    var onApply: ((PoseSettingsViewModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // 入力画像セクション
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("入力画像")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("衣装三面図:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("衣装三面図の画像パス（必須）", text: $viewModel.outfitSheetImagePath)
                                    .textFieldStyle(.roundedBorder)
                                Button("参照") {
                                    // TODO: ファイル選択
                                }
                            }
                        }
                        .padding(10)
                    }

                    // ポーズ設定セクション
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ポーズ設定")
                                .font(.headline)
                                .fontWeight(.bold)

                            // ポーズキャプチャ
                            Toggle("ポーズキャプチャを使用", isOn: $viewModel.usePoseCapture)

                            if viewModel.usePoseCapture {
                                HStack {
                                    Text("参考画像:")
                                        .frame(width: 100, alignment: .leading)
                                    TextField("ポーズ参考画像", text: $viewModel.poseReferenceImagePath)
                                        .textFieldStyle(.roundedBorder)
                                    Button("参照") {
                                        // TODO: ファイル選択
                                    }
                                }
                            } else {
                                // ポーズプリセット
                                HStack {
                                    Text("ポーズ:")
                                        .frame(width: 100, alignment: .leading)
                                    Picker("", selection: $viewModel.selectedPose) {
                                        ForEach(CharacterPose.allCases) { pose in
                                            Text(pose.rawValue).tag(pose)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: 150)
                                    Spacer()
                                }

                                // カスタムポーズ
                                HStack {
                                    Text("カスタム:")
                                        .frame(width: 100, alignment: .leading)
                                    TextField("自由記述（任意）", text: $viewModel.customPose)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }

                            Divider()

                            // 表情・視線
                            HStack {
                                Text("表情:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("", selection: $viewModel.expression) {
                                    ForEach(CharacterExpression.allCases) { exp in
                                        Text(exp.rawValue).tag(exp)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)

                                Text("向き:")
                                    .frame(width: 40, alignment: .leading)
                                Picker("", selection: $viewModel.facing) {
                                    ForEach(CharacterFacing.allCases) { facing in
                                        Text(facing.rawValue).tag(facing)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 120)
                                Spacer()
                            }

                            // エフェクト
                            HStack {
                                Text("エフェクト:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("", selection: $viewModel.effectType) {
                                    ForEach(EffectType.allCases) { effect in
                                        Text(effect.rawValue).tag(effect)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 100)

                                if viewModel.effectType != .none {
                                    Text("色:")
                                        .frame(width: 30, alignment: .leading)
                                    Picker("", selection: $viewModel.effectColor) {
                                        ForEach(EffectColor.allCases) { color in
                                            Text(color.rawValue).tag(color)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: 100)
                                }
                                Spacer()
                            }

                            Toggle("背景透過（合成用）", isOn: $viewModel.transparentBackground)
                        }
                        .padding(10)
                    }

                    // 角度・ズーム設定
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("角度・ズーム変更")
                                .font(.headline)
                                .fontWeight(.bold)

                            HStack {
                                Text("カメラ角度:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("", selection: $viewModel.cameraAngle) {
                                    ForEach(CameraAngle.allCases) { angle in
                                        Text(angle.rawValue).tag(angle)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150)
                                Spacer()
                            }

                            HStack {
                                Text("ズーム:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("", selection: $viewModel.zoomLevel) {
                                    ForEach(ZoomLevel.allCases) { zoom in
                                        Text(zoom.rawValue).tag(zoom)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150)
                                Spacer()
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
        .frame(width: 700, height: 600)
    }
}

#Preview {
    PoseSettingsView()
}
