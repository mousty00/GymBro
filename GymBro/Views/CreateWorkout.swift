import SwiftUI

struct CreateWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Binding var selectedDate: Date
    @State private var name: String = ""
    @State private var steps: Int = 1
    @State private var sets: Int = 1
    @State private var durationMinutes: Int = 0
    @State private var durationSeconds: Int = 0
    @State private var restMinutes: Int = 0
    @State private var restSeconds: Int = 0
    @State private var type: String = NSLocalizedString("Cardio", comment: "Default workout type")
    @State private var notes: String = ""
    @State private var selectedDays: Set<Int> = Set()
    @State private var repeatUntilDate: Date = Date()

    private var textLimit: Int = 160
    
    let types = [
        NSLocalizedString("Cardio", comment: "Cardio workout type"),
        NSLocalizedString("Strength", comment: "Strength workout type"),
        NSLocalizedString("HIIT", comment: "HIIT workout type"),
        NSLocalizedString("Yoga", comment: "Yoga workout type")
    ]
    
    let weekdays = Calendar.current.weekdaySymbols // ["Sunday", "Monday", "Tuesday", ..., "Saturday"]
    
    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
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
                
                DatePicker("Repeat Until", selection: $repeatUntilDate, in: selectedDate..., displayedComponents: .date)
                
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
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(NSLocalizedString("New Workout", comment: "New workout screen title"))
                        .font(.title3)
                        .bold()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "Save button")) {
                        
                        let (correctedDurationMinutes, correctedDurationSeconds) = normalizeTime(minutes: durationMinutes, seconds: durationSeconds)
                        let totalDurationInSeconds = (correctedDurationMinutes * 60) + correctedDurationSeconds
                        
                        let (correctedRestMinutes, correctedRestSeconds) = normalizeTime(minutes: restMinutes, seconds: restSeconds)
                        let totalRestInSeconds = (correctedRestMinutes * 60) + correctedRestSeconds
                        
                        for day in selectedDays {
                            let workoutDates = getAllWorkoutDates(from: selectedDate, until: repeatUntilDate, forDay: day)
                            
                            for workoutDate in workoutDates {
                                let workout = ModelWorkout(
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
                                context.insert(workout)
                                print("Workout added: \(workout.name) for \(workoutDate) ")
                            }
                        }
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty || durationMinutes == 0 && durationSeconds == 0 || restMinutes == 0 && restSeconds == 0)
                }
            }
        }
    }
    
    private func normalizeTime(minutes: Int, seconds: Int) -> (Int, Int) {
        let extraMinutes = seconds / 60
        let correctedSeconds = seconds % 60
        let correctedMinutes = minutes + extraMinutes
        return (correctedMinutes, correctedSeconds)
    }
    
    private func getAllWorkoutDates(from startDate: Date, until endDate: Date, forDay day: Int) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate) - 1 // 0 = Sunday, 1 = Monday, etc.
        
        let daysToAdd = (day - weekday + 7) % 7
        currentDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)!
        
        // Add current date till end date
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    
}

