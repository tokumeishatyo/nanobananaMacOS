import SwiftUI

/// セクションヘッダービュー
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
}

#Preview {
    SectionHeaderView(title: "出力タイプ")
        .padding()
}
