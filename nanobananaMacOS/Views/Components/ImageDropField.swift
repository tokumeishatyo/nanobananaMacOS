import SwiftUI
import UniformTypeIdentifiers

/// 画像ファイル選択用の共通コンポーネント
/// D&D（ドラッグ＆ドロップ）とファイル選択ダイアログの両方に対応
struct ImageDropField: View {
    // MARK: - Required Properties

    /// ファイルパスへのバインディング
    @Binding var imagePath: String

    // MARK: - Optional Properties

    /// ラベルテキスト（例: "参照画像:"）
    var label: String? = nil

    /// プレースホルダーテキスト
    var placeholder: String = "画像をドラッグ＆ドロップ"

    /// 許可するファイルタイプ
    var allowedContentTypes: [UTType] = [.png, .jpeg, .gif, .webP]

    /// 無効化フラグ
    var isDisabled: Bool = false

    /// ドロップゾーンの高さ
    var height: CGFloat = 80

    // MARK: - State

    @State private var isDropTargeted = false
    @State private var showingFilePicker = false

    // MARK: - Computed Properties

    private var hasImage: Bool {
        !imagePath.isEmpty
    }

    private var fileName: String {
        guard hasImage else { return "" }
        return URL(fileURLWithPath: imagePath).lastPathComponent
    }

    private var borderColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.3)
        } else if isDropTargeted {
            return Color.accentColor
        } else if hasImage {
            return Color.green.opacity(0.5)
        } else {
            return Color.gray.opacity(0.5)
        }
    }

    private var backgroundColor: Color {
        if isDropTargeted {
            return Color.accentColor.opacity(0.1)
        } else if hasImage {
            return Color.green.opacity(0.05)
        } else {
            return Color.clear
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // ラベル（オプション）
            if let label = label {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // ドロップゾーン
            dropZone
        }
        .opacity(isDisabled ? 0.5 : 1.0)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    // MARK: - Drop Zone

    private var dropZone: some View {
        ZStack {
            // 背景とボーダー
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    borderColor,
                    style: StrokeStyle(lineWidth: 2, dash: hasImage ? [] : [6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                )

            // コンテンツ
            if hasImage {
                // ファイル選択済み
                selectedFileView
            } else {
                // 未選択時
                emptyStateView
            }
        }
        .frame(height: height)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 6) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(.secondary)

            Text(placeholder)
                .font(.caption)
                .foregroundColor(.secondary)

            Button("ファイルを選択") {
                showingFilePicker = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(isDisabled)
        }
    }

    // MARK: - Selected File View

    private var selectedFileView: some View {
        HStack {
            Image(systemName: "photo.fill")
                .foregroundColor(.green)

            Text(fileName)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            // クリアボタン
            Button {
                imagePath = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)

            // 変更ボタン
            Button("変更") {
                showingFilePicker = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(isDisabled)
        }
        .padding(.horizontal, 12)
    }

    // MARK: - Drop Handling

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard !isDisabled else { return false }
        guard let provider = providers.first else { return false }

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                // ファイルタイプの検証
                if isValidImageFile(url: url) {
                    DispatchQueue.main.async {
                        imagePath = url.path
                    }
                }
            }
            return true
        }
        return false
    }

    // MARK: - File Import Handling

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                imagePath = url.path
            }
        case .failure(let error):
            print("ファイル選択エラー: \(error.localizedDescription)")
        }
    }

    // MARK: - Validation

    private func isValidImageFile(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        let validExtensions = ["png", "jpg", "jpeg", "gif", "webp"]
        return validExtensions.contains(ext)
    }
}

// MARK: - Preview

#Preview("Empty State") {
    VStack(spacing: 20) {
        ImageDropField(
            imagePath: .constant(""),
            label: "参照画像:"
        )

        ImageDropField(
            imagePath: .constant(""),
            label: "顔三面図:",
            placeholder: "顔三面図をドロップ"
        )
    }
    .padding()
    .frame(width: 400)
}

#Preview("With Image") {
    VStack(spacing: 20) {
        ImageDropField(
            imagePath: .constant("/Users/test/Documents/character.png"),
            label: "参照画像:"
        )

        ImageDropField(
            imagePath: .constant("/path/to/very_long_filename_that_should_be_truncated.png"),
            label: "衣装参考画像:"
        )
    }
    .padding()
    .frame(width: 400)
}

#Preview("Disabled") {
    ImageDropField(
        imagePath: .constant(""),
        label: "無効化された選択:",
        isDisabled: true
    )
    .padding()
    .frame(width: 400)
}
