// rule.mdを読むこと
import SwiftUI

/// ラベル付きピッカービュー
struct LabeledPickerView<T: Hashable & Identifiable>: View where T: RawRepresentable, T.RawValue == String {
    let label: String
    @Binding var selection: T
    let options: [T]

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            Picker("", selection: $selection) {
                ForEach(options) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
    }
}
