
import SwiftUI

struct DoublePicker: View {
    @Binding var selection: Double
    var label: String
    var range: [Double]
    
    var body: some View {
        VStack{
            Text("\(label)")
            Picker(label, selection: $selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value, specifier: "%.1f") min")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)
        }
    }
}
