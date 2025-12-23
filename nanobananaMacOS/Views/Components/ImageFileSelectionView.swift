// rule.mdを読むこと
import SwiftUI
import UniformTypeIdentifiers

/// 画像ファイル選択ダイアログ
struct ImageFileSelectionView: View {
    @ObservedObject var viewModel: ImageFileSelectionViewModel
    @Environment(\.windowDismiss) private var windowDismiss

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Header
            Text("参考画像の選択")
                .font(.headline)
                .padding(.top, 8)

            // MARK: - Required Files List
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("以下のファイルが必要です:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(viewModel.requiredFiles) { file in
                        HStack {
                            Image(systemName: file.isMatched ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(file.isMatched ? .green : .gray)

                            Text(file.filename)
                                .font(.system(.body, design: .monospaced))
                                .strikethrough(file.isMatched, color: .green)
                                .foregroundColor(file.isMatched ? .secondary : .primary)

                            Spacer()
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 200)

            // MARK: - Drop Zone
            DropZoneView(viewModel: viewModel)
                .frame(height: 120)

            // MARK: - Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // MARK: - Buttons
            HStack {
                Spacer()

                Button("キャンセル") {
                    viewModel.cancel()
                    windowDismiss?()
                }
                .keyboardShortcut(.escape)

                Button("OK") {
                    viewModel.confirmSelection()
                    windowDismiss?()
                }
                .keyboardShortcut(.return)
                .disabled(!viewModel.isAllFilesMatched)
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .frame(width: 450)
    }
}

// MARK: - Drop Zone View

/// ドラッグ&ドロップエリア
struct DropZoneView: View {
    @ObservedObject var viewModel: ImageFileSelectionViewModel
    @State private var isDropTargeted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .foregroundColor(isDropTargeted ? .blue : .gray)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDropTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                )

            VStack(spacing: 12) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)

                Text("ここにファイルをドラッグ&ドロップ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("または")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("ファイルを選択...") {
                    viewModel.showFilePicker()
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDroppedFiles(providers)
            return true
        }
    }
}

// MARK: - Preview

#Preview {
    ImageFileSelectionView(
        viewModel: ImageFileSelectionViewModel(
            requiredFilenames: [
                "彩瀬翔子_顔三面図.png",
                "school_background.jpg",
                "decorative_text_01.png"
            ]
        )
    )
}
