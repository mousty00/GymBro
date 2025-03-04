
import SwiftUI

struct EditWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String
    @State private var date: Date
    @State private var steps: Int
    @State private var sets: Int
    @State private var duration: Double
    @State private var rest: Double
    @State private var type: String
    @State private var selectedDays: [Int]
    
    let types = ["Cardio", "Strength", "HIIT", "Yoga"]
    let weekdays = Calendar.current.weekdaySymbols
    
    var workout: Workout

    init(workout: Workout) {
        self.workout = workout
        _name = State(initialValue: workout.name)
        _date = State(initialValue: workout.date)
        _steps = State(initialValue: workout.steps)
        _sets = State(initialValue: workout.sets)
        _duration = State(initialValue: workout.duration)
        _rest = State(initialValue: workout.rest)
        _type = State(initialValue: workout.type)
        _selectedDays = State(initialValue: workout.repeatDays)
    }

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
                    Text("Edit Workout")
                        .font(.title3)
                        .bold()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        updateWorkout()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func updateWorkout() {
        workout.name = name
        workout.date = date
        workout.steps = steps
        workout.sets = sets
        workout.duration = duration
        workout.rest = rest
        workout.type = type
        workout.repeatDays = selectedDays
        
        try? context.save()
    }
}
