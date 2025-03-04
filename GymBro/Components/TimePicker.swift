
import SwiftUI

struct TimePicker: View {
    var label: String
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        
        Section(header: Text("\(label)") ){
            HStack {
                Picker(NSLocalizedString("Minutes", comment: ""), selection: $minutes) {
                    ForEach(0..<61, id: \.self) { minute in
                        Text("\(minute) min")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Picker(NSLocalizedString("Seconds", comment: ""), selection: $seconds) {
                    ForEach(0..<60, id: \.self) { second in
                        Text("\(second) sec")
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
        }
    }
}
