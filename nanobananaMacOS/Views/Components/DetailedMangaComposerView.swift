import SwiftUI
import UniformTypeIdentifiers

/// 詳細漫画コンポーザーのメインビュー
struct DetailedMangaComposerView: View {
    @StateObject private var viewModel = DetailedMangaComposerViewModel()
    @Environment(\.windowDismiss) private var windowDismiss

    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ（2カラム）
            HStack(spacing: 0) {
                // 左カラム: 設定エリア
                settingsColumn
                    .frame(width: 350)

                Divider()

                // 右カラム: プレビューエリア
                previewColumn
                    .frame(minWidth: 300)
            }

            Divider()

            // 下部: アクションボタン
            actionButtonsSection
        }
        .frame(minWidth: 700, minHeight: 600)
    }

    // MARK: - Settings Column

    private var settingsColumn: some View {
        ScrollView {
            VStack(spacing: 16) {
                // タイトル・作者入力
                metaInfoSection

                Divider()

                // コマリスト
                panelsSection

                // コマ追加ボタン
                addPanelButton
            }
            .padding()
        }
    }

    /// メタ情報セクション
    private var metaInfoSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("タイトル:")
                    .frame(width: 60, alignment: .trailing)
                TextField("タイトル", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Text("作者:")
                    .frame(width: 60, alignment: .trailing)
                TextField("作者名", text: $viewModel.authorName)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    /// コマリストセクション
    private var panelsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.panels.enumerated()), id: \.element.id) { index, panel in
                PanelRowView(
                    panel: panel,
                    index: index,
                    viewModel: viewModel,
                    canDelete: viewModel.panels.count > 1
                )
            }
        }
    }

    /// コマ追加ボタン
    private var addPanelButton: some View {
        Button(action: viewModel.addPanel) {
            HStack {
                Image(systemName: "plus.circle")
                Text("コマを追加")
            }
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Preview Column

    private var previewColumn: some View {
        VStack(spacing: 12) {
            Text("プレビュー")
                .font(.headline)
                .padding(.top)

            // プレビュー表示エリア
            if let image = viewModel.previewImage {
                ScrollView {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(CheckerboardBackground())
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding()
                }
            } else {
                VStack {
                    Spacer()
                    Text("プレビューなし")
                        .foregroundColor(.secondary)
                    Text("「プレビュー更新」を押してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }

            // プレビュー更新ボタン
            Button(action: viewModel.updatePreview) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("プレビュー更新")
                }
            }
            .buttonStyle(.bordered)
            .padding(.bottom)

            // メッセージ表示
            messageSection
        }
    }

    /// メッセージセクション
    private var messageSection: some View {
        VStack {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if let success = viewModel.successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Spacer()

            Button("クリア") {
                viewModel.clear()
            }
            .buttonStyle(.bordered)

            Button("合成・保存") {
                viewModel.composeAndSave()
            }
            .buttonStyle(.borderedProminent)

            Button("キャンセル") {
                windowDismiss?()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Panel Row View

/// コマ1行のビュー
struct PanelRowView: View {
    @ObservedObject var panel: ComposerPanel
    let index: Int
    @ObservedObject var viewModel: DetailedMangaComposerViewModel
    let canDelete: Bool

    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                // ヘッダー
                HStack {
                    Text("コマ \(index + 1)")
                        .font(.headline)
                    Spacer()
                    if canDelete {
                        Button(action: { viewModel.removePanel(panel) }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 画像エリア
                if panel.isSplit {
                    // 左右分割
                    HStack(spacing: 8) {
                        ImageDropZoneView(
                            panelImage: panel.leftImage,
                            label: "左",
                            onSelect: { viewModel.selectLeftImage(for: panel) },
                            onDrop: { providers in
                                viewModel.handleDropForLeftImage(providers, panel: panel)
                            },
                            onRemove: { viewModel.removeLeftImage(from: panel) }
                        )

                        ImageDropZoneView(
                            panelImage: panel.rightImage ?? ComposerPanelImage(),
                            label: "右",
                            onSelect: { viewModel.selectRightImage(for: panel) },
                            onDrop: { providers in
                                viewModel.handleDropForRightImage(providers, panel: panel)
                            },
                            onRemove: { viewModel.removeRightImage(from: panel) }
                        )
                    }
                } else {
                    // 単一画像
                    HStack(spacing: 8) {
                        ImageDropZoneView(
                            panelImage: panel.leftImage,
                            label: nil,
                            onSelect: { viewModel.selectLeftImage(for: panel) },
                            onDrop: { providers in
                                viewModel.handleDropForLeftImage(providers, panel: panel)
                            },
                            onRemove: nil
                        )

                        // 画像を追加ボタン
                        Button(action: { viewModel.addSplitToPanel(panel) }) {
                            VStack {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                Text("画像を追加")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(width: 100)
                    }
                }
            }
            .padding(8)
        }
    }
}

// MARK: - Image Drop Zone View

/// 画像ドロップゾーン
struct ImageDropZoneView: View {
    let panelImage: ComposerPanelImage
    let label: String?
    let onSelect: () -> Void
    let onDrop: ([NSItemProvider]) -> Bool
    let onRemove: (() -> Void)?

    @State private var isDropTargeted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor : Color.gray.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2, dash: [6])
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDropTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
                )

            if let image = panelImage.image {
                // 画像表示
                VStack(spacing: 4) {
                    if let label = label {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 80)
                        .cornerRadius(4)

                    Text(panelImage.filename)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    if let onRemove = onRemove {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
            } else {
                // プレースホルダー
                VStack(spacing: 4) {
                    if let label = label {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Text("D&D")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Button("選択") {
                        onSelect()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
            }
        }
        .frame(height: 120)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            onDrop(providers)
        }
    }
}

// MARK: - Preview

#Preview {
    DetailedMangaComposerView()
}
