import SwiftUI

struct EditWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String
    @State private var steps: Int
    @State private var sets: Int
    @State private var durationMinutes: Int
    @State private var durationSeconds: Int
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var type: String
    @State private var notes: String
    @State private var selectedDays: Set<Int> // Set of selected days
    
    private var textLimit: Int = 160
    
    let types = [
        NSLocalizedString("Cardio", comment: "Cardio workout type"),
        NSLocalizedString("Strength", comment: "Strength workout type"),
        NSLocalizedString("HIIT", comment: "HIIT workout type"),
        NSLocalizedString("Yoga", comment: "Yoga workout type")
    ]
    
    let weekdays = Calendar.current.weekdaySymbols // ["Sunday", "Monday", ..., "Saturday"]
    
    var workout: ModelWorkout

    init(workout: ModelWorkout) {
        self.workout = workout
        _name = State(initialValue: workout.name)
        _steps = State(initialValue: workout.steps)
        _sets = State(initialValue: workout.sets)
        _durationMinutes = State(initialValue: Int(workout.duration) / 60)
        _durationSeconds = State(initialValue: Int(workout.duration) % 60)
        _restMinutes = State(initialValue: Int(workout.rest) / 60)
        _restSeconds = State(initialValue: Int(workout.rest) % 60)
        _type = State(initialValue: workout.type)
        _notes = State(initialValue: workout.notes ?? "")
        _selectedDays = State(initialValue: workout.getCompletedDays())
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
                
                Section(header: Text(NSLocalizedString("Select Days", comment: "Days to repeat workout"))){
                    ForEach(0..<7, id: \.self) { dayIndex in
                        Toggle(isOn: Binding(
                            get: { selectedDays.contains(dayIndex) },
                            set: { newValue in
                                if newValue {
                                    selectedDays.insert(dayIndex)
                                } else {
                                    selectedDays.remove(dayIndex)
                                }
                            }
                        )) {
                            Text(weekdays[dayIndex])
                        }
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
        
        context.delete(workout)
        
        for day in selectedDays {
            let workoutDate = getNextWorkoutDate(from: workout.date, forDay: day)
            
            let updatedWorkout = ModelWorkout(
                name: name,
                date: workoutDate,
                steps: steps,
                sets: sets,
                duration: totalDurationInSeconds,
                rest: totalRestInSeconds,
                type: type,
                notes: notes,
                completedDays: selectedDays
            )
            context.insert(updatedWorkout)
            print("Workout updated: \(updatedWorkout.name) for \(workoutDate)")
        }
        
        try? context.save()
    }

    private func getNextWorkoutDate(from startDate: Date, forDay day: Int) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: startDate) - 1 // 0 = Sunday, 1 = Monday, etc.
        
        let daysToAdd = (day - weekday + 7) % 7
        let nextWorkoutDate = calendar.date(byAdding: .day, value: daysToAdd, to: startDate)!
        
        return nextWorkoutDate
    }
}

