
import SwiftUI

struct CustomPicker<T: Hashable>: View {
    @Binding var selection: T
    var label: String
    var range: ClosedRange<Int>? = nil
    var options: [T]? = nil
    var afterText: String?

    var body: some View {
        Picker(label, selection: $selection) {
            if let range = range {
                ForEach(range, id: \.self) { item in
                    Text("\(item) \(afterText ?? "")").tag(item)
                }
            } else if let options = options {
                ForEach(options, id: \.self) { item in
                    Text("\(item)").tag(item)
                }
            }
        }
        .pickerStyle(.menu)
    }
}
