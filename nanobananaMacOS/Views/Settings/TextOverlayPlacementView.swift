import SwiftUI

/// 装飾テキスト配置設定ウィンドウ（Python版準拠）
/// シーンビルダーから呼び出される、最大10個の装飾テキストを配置
struct TextOverlayPlacementView: View {
    @Binding var items: [TextOverlayItem]
    @Environment(\.dismiss) private var standardDismiss
    @Environment(\.windowDismiss) private var windowDismiss

    private let maxItems = 10

    private func dismissWindow() {
        if let windowDismiss = windowDismiss {
            windowDismiss()
        } else {
            standardDismiss()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            VStack(alignment: .leading, spacing: 4) {
                Text("装飾テキスト配置")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("位置は自由入力（例: Top Center, Bottom Right, Near Character 1）")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            // 追加/削除ボタン
            HStack {
                Button("＋ 追加") {
                    addItem()
                }
                .disabled(items.count >= maxItems)

                Button("－ 削除") {
                    removeLastItem()
                }
                .disabled(items.isEmpty)

                Spacer()

                Text("\(items.count) / \(maxItems)")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // アイテムリスト
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(items.indices, id: \.self) { index in
                        overlayItemRow(index: index)
                    }

                    if items.isEmpty {
                        Text("「＋ 追加」ボタンで装飾テキストを追加")
                            .foregroundColor(.gray)
                            .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 16)
            }

            Divider()

            // フッターボタン
            HStack {
                Spacer()
                Button("OK") {
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
        .frame(width: 600, height: 500)
    }

    private func overlayItemRow(index: Int) -> some View {
        HStack(spacing: 8) {
            // 番号
            Text("\(index + 1).")
                .frame(width: 25)
                .foregroundColor(.gray)

            // 画像パス
            TextField("画像パス", text: itemImageBinding(index: index))
                .textFieldStyle(.roundedBorder)
                .frame(width: 160)

            Button("参照") {
                // TODO: ファイル選択
            }
            .font(.caption)

            // 位置
            TextField("Center", text: itemPositionBinding(index: index))
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)

            // サイズ
            TextField("100%", text: itemSizeBinding(index: index))
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)

            // レイヤー
            Picker("", selection: itemLayerBinding(index: index)) {
                ForEach(TextOverlayLayer.allCases) { layer in
                    Text(layer.rawValue).tag(layer)
                }
            }
            .labelsHidden()
            .frame(width: 110)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }

    private func addItem() {
        guard items.count < maxItems else { return }
        items.append(TextOverlayItem())
    }

    private func removeLastItem() {
        guard !items.isEmpty else { return }
        items.removeLast()
    }

    // MARK: - Bindings
    private func itemImageBinding(index: Int) -> Binding<String> {
        Binding(
            get: { items[index].imagePath },
            set: { items[index].imagePath = $0 }
        )
    }

    private func itemPositionBinding(index: Int) -> Binding<String> {
        Binding(
            get: { items[index].position },
            set: { items[index].position = $0 }
        )
    }

    private func itemSizeBinding(index: Int) -> Binding<String> {
        Binding(
            get: { items[index].size },
            set: { items[index].size = $0 }
        )
    }

    private func itemLayerBinding(index: Int) -> Binding<TextOverlayLayer> {
        Binding(
            get: { items[index].layer },
            set: { items[index].layer = $0 }
        )
    }
}

#Preview {
    TextOverlayPlacementView(items: .constant([
        TextOverlayItem(imagePath: "test.png", position: "Top Center", size: "80%", layer: .frontmost)
    ]))
}
