// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 背景透過ツールのメインビュー
/// 対応OS: macOS 14.0以降
@available(macOS 14.0, *)
struct BackgroundRemovalView: View {
    @StateObject private var viewModel = BackgroundRemovalViewModel()
    @State private var isDropTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            // ドロップゾーン
            dropZone

            // 選択中ファイル名
            if let filename = viewModel.selectedFilename {
                HStack {
                    Text("選択中:")
                        .foregroundColor(.secondary)
                    Text(filename)
                        .fontWeight(.medium)
                }
                .font(.caption)
            }

            // プレビュー
            if let image = viewModel.selectedImage {
                imagePreview(image: image, label: "元画像")
            }

            // エラーメッセージ
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Spacer()

            // 透過処理ボタン
            Button(action: {
                Task {
                    await viewModel.processImage()
                }
            }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                    }
                    Text(viewModel.isProcessing ? "処理中..." : "透過処理を実行")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canProcess)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $viewModel.showCompletionDialog) {
            completionDialog
        }
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
        .frame(height: 180)
        .padding(.horizontal)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDroppedProviders(providers)
            return true
        }
    }

    /// 画像プレビュー
    private func imagePreview(image: NSImage, label: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .background(
                    // 透過確認用のチェッカーボード
                    CheckerboardBackground()
                )
                .cornerRadius(8)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    /// 完了ダイアログ
    private var completionDialog: some View {
        VStack(spacing: 20) {
            Text("処理が完了しました")
                .font(.headline)

            if let result = viewModel.resultImage {
                VStack(spacing: 4) {
                    Text("処理結果")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(nsImage: result)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .background(CheckerboardBackground())
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
            }

            HStack(spacing: 16) {
                Button("閉じる") {
                    viewModel.closeCompletionDialog()
                }
                .buttonStyle(.bordered)

                Button("ファイルを保存") {
                    viewModel.saveResult()
                    viewModel.closeCompletionDialog()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(minWidth: 400, minHeight: 400)
    }
}

// MARK: - Checkerboard Background

/// 透過確認用のチェッカーボード背景
struct CheckerboardBackground: View {
    let squareSize: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let columns = Int(ceil(geometry.size.width / squareSize))
            let rows = Int(ceil(geometry.size.height / squareSize))

            Canvas { context, size in
                for row in 0..<rows {
                    for col in 0..<columns {
                        let isLight = (row + col) % 2 == 0
                        let rect = CGRect(
                            x: CGFloat(col) * squareSize,
                            y: CGFloat(row) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )
                        context.fill(
                            Path(rect),
                            with: .color(isLight ? .white : Color.gray.opacity(0.3))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

@available(macOS 14.0, *)
#Preview {
    BackgroundRemovalView()
}
