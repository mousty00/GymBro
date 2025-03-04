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
    
    let types = [
        NSLocalizedString("Cardio", comment: "Cardio workout type"),
        NSLocalizedString("Strength", comment: "Strength workout type"),
        NSLocalizedString("HIIT", comment: "HIIT workout type"),
        NSLocalizedString("Yoga", comment: "Yoga workout type")
    ]
    
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
                TextField(NSLocalizedString("Workout Name", comment: "Workout name field"), text: $name)
                
                CustomPicker(selection: $steps, label: NSLocalizedString("Steps", comment: "Steps count"), range: 1...100)
                CustomPicker(selection: $sets, label: NSLocalizedString("Sets", comment: "Sets count"), range: 1...20)
                DoublePicker(selection: $duration, label: NSLocalizedString("Duration for set", comment: "Duration per set"), range: stride(from: 0.0, through: 10.0, by: 0.5).map { $0 })
                DoublePicker(selection: $rest, label: NSLocalizedString("Rest", comment: "Rest time"), range: stride(from: 0.0, through: 20.0, by: 0.1).map { $0 })
                CustomPicker(selection: $type, label: NSLocalizedString("Workout Type", comment: "Type of workout"), options: types)
                
                NavigationLink(destination: WeekdayPicker(selectedDays: $selectedDays)) {
                    HStack {
                        Text(NSLocalizedString("Repeat", comment: "Repeat workout"))
                            .foregroundColor(.primary)
                        Spacer()
                        Text(selectedDays.isEmpty ? NSLocalizedString("None", comment: "No repeat days") : selectedDays.map { weekdays[$0] }.joined(separator: ", "))
                            .foregroundColor(.gray)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(NSLocalizedString("Edit Workout", comment: "Edit workout screen title"))
                        .font(.title3)
                        .bold()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "Save button")) {
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
        
        print("Workout updated: \(workout.name)")
    }
}

