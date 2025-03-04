import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: [Int]

    private let weekdays = Calendar.current.weekdaySymbols

    var body: some View {
        List {
            ForEach(weekdays.indices, id: \.self) { index in
                Button(action: {
                    toggleDay(index)
                }) {
                    HStack {
                        Text(weekdays[index])
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedDays.contains(index) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .navigationTitle(NSLocalizedString("Select Days", comment:""))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleDay(_ index: Int) {
        if let existingIndex = selectedDays.firstIndex(of: index) {
            selectedDays.remove(at: existingIndex)
        } else {
            selectedDays.append(index)
        }
    }
}

