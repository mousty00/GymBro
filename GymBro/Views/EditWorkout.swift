import SwiftUI

struct EditWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String
    @State private var date: Date
    @State private var steps: Int
    @State private var sets: Int
    @State private var durationMinutes: Int
    @State private var durationSeconds: Int
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var type: String
    @State private var selectedDays: [Int]
    @State private var notes: String
    private var textLimit: Int = 160
    
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
        _durationMinutes = State(initialValue: Int(workout.duration) / 60)
        _durationSeconds = State(initialValue: Int(workout.duration) % 60)
        _restMinutes = State(initialValue: Int(workout.rest) / 60)
        _restSeconds = State(initialValue: Int(workout.rest) % 60)
        _type = State(initialValue: workout.type)
        _selectedDays = State(initialValue: workout.repeatDays)
        _notes = State(initialValue: workout.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(NSLocalizedString("Workout Name", comment: "Workout name field"), text: $name)

                CustomPicker(selection: $steps, label: NSLocalizedString("Steps", comment: "Steps count"), range: 1...100)
                CustomPicker(selection: $sets, label: NSLocalizedString("Sets", comment: "Sets count"), range: 1...20)

                TimePicker(label: NSLocalizedString("Duration for set", comment: ""), minutes: $durationMinutes, seconds: $durationSeconds)
                TimePicker(label: NSLocalizedString("Rest", comment: ""), minutes: $restMinutes, seconds: $restSeconds)
                
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
                
                Section(header: Text("\(NSLocalizedString("Notes", comment: "Notes for workout")) (\(notes.count)/\(textLimit))")) {
                    TextEditor(text: $notes)
                        .frame(height: 150)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(.primary)
                        .onChange(of: notes) { newValue, _ in
                            if newValue.count > textLimit {
                                notes = String(newValue.prefix(textLimit))
                            }
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
        let totalDurationInSeconds = durationMinutes * 60 + durationSeconds
        let totalRestInSeconds = restMinutes * 60 + restSeconds
        
        workout.name = name
        workout.date = date
        workout.steps = steps
        workout.sets = sets
        workout.duration = totalDurationInSeconds
        workout.rest = totalRestInSeconds
        workout.type = type
        workout.repeatDays = selectedDays
        workout.notes = notes
        
        try? context.save()
        
        print("Workout updated: \(workout.name)")
    }
}

