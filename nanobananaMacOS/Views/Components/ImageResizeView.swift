// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 画像リサイズツールのメインビュー
struct ImageResizeView: View {
    @StateObject private var viewModel = ImageResizeViewModel()
    @State private var isDropTargeted = false
    @Environment(\.windowDismiss) private var windowDismiss

    var body: some View {
        VStack(spacing: 16) {
            // ドロップゾーン
            dropZone

            // 選択中ファイル情報
            if viewModel.isImageSelected {
                fileInfoSection
            }

            // リサイズ設定
            if viewModel.isImageSelected {
                resizeSettingsSection
            }

            // プレビュー
            if let image = viewModel.previewImage {
                previewSection(image: image)
            }

            // メッセージ表示
            messageSection

            Spacer()

            // アクションボタン
            actionButtonsSection

            // 閉じるボタン
            closeButtonSection
        }
        .padding(.top, 16)
        .frame(minWidth: 500, minHeight: 850)
    }

    // MARK: - Subviews

    /// ドロップゾーン
    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor : Color.gray.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDropTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
                )

            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)

                Text("画像をドラッグ＆ドロップ")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("または")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("ファイルを選択") {
                    viewModel.selectFile()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(height: 150)
        .padding(.horizontal)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDroppedProviders(providers)
            return true
        }
    }

    /// ファイル情報セクション
    private var fileInfoSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("ファイル:")
                    .frame(width: 70, alignment: .trailing)
                Text(viewModel.selectedFilename)
                    .fontWeight(.medium)
                Spacer()
            }

            HStack {
                Text("元サイズ:")
                    .frame(width: 70, alignment: .trailing)
                Text("\(viewModel.originalWidth) × \(viewModel.originalHeight) px")
                    .fontWeight(.medium)
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    /// リサイズ設定セクション
    private var resizeSettingsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("横幅:")
                    .frame(width: 70, alignment: .trailing)
                TextField("", text: $viewModel.targetWidthString)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                Text("px")
                Spacer()
            }

            HStack {
                Text("縦幅:")
                    .frame(width: 70, alignment: .trailing)
                Text("\(viewModel.calculatedHeight)")
                    .frame(width: 100, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                Text("px（自動計算）")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    /// プレビューセクション
    private func previewSection(image: NSImage) -> some View {
        VStack(spacing: 4) {
            Text("プレビュー")
                .font(.caption)
                .foregroundColor(.secondary)

            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 500)
                .background(CheckerboardBackground())
                .cornerRadius(8)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    /// メッセージセクション
    private var messageSection: some View {
        VStack {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            if let success = viewModel.successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
    }

    /// アクションボタンセクション
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button("クリア") {
                viewModel.clear()
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.isImageSelected)

            Button("プレビュー") {
                viewModel.generatePreview()
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canPreview)

            Button("保存") {
                viewModel.save()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSave)
        }
        .padding(.horizontal)
    }

    /// 閉じるボタンセクション
    private var closeButtonSection: some View {
        HStack {
            Spacer()
            Button("閉じる") {
                windowDismiss?()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    ImageResizeView()
}
