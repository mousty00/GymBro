import SwiftUI

struct CreateWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String = ""
    @State private var date: Date = .now
    @State private var steps: Int = 1
    @State private var sets: Int = 1
    @State private var duration: Double = 0.0
    @State private var rest: Double = 0.0
    @State private var type: String = "Cardio"
    @State private var selectedDays: [Int] = []
    
    let types = ["Cardio", "Strength", "HIIT", "Yoga"]
    let weekdays = Calendar.current.weekdaySymbols
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Workout Name", text: $name)

                CustomPicker(selection: $steps, label: "Steps", range: 1...100)
                CustomPicker(selection: $sets, label: "Sets", range: 1...20)

                DoublePicker(selection: $duration, label: "Duration for set", range: stride(from: 0.0, through: 10.0, by: 0.5).map { $0 })
                DoublePicker(selection: $rest, label: "Rest", range: stride(from: 0.0, through: 20.0, by: 0.1).map { $0 })
                
                CustomPicker(selection: $type, label: "Workout Type", options: types)
                
                NavigationLink(destination: WeekdayPicker(selectedDays: $selectedDays)) {
                    HStack {
                        Text("Repeat")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(selectedDays.isEmpty ? "None" : selectedDays.map { weekdays[$0] }.joined(separator: ", "))
                            .foregroundColor(.gray)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("New Workout")
                        .font(.title3)
                        .bold()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let workout = Workout(name: name, date: date, steps: steps, sets: sets, duration: duration, rest: rest, type: type, repeatDays: selectedDays)
                        context.insert(workout)
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .disabled(duration.isEqual(to: 0.0))
                    .disabled(rest.isEqual(to: 0.0))
                    .disabled(selectedDays.isEmpty)
                }
            }
        }
    }
}

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

#Preview {
    CreateWorkout()
}

