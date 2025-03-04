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
    @State private var type: String = NSLocalizedString("Cardio", comment: "Default workout type")
    @State private var selectedDays: [Int] = []
    @State private var notes: String = ""
    private var textLimit: Int = 160
    
    let types = [
        NSLocalizedString("Cardio", comment: "Cardio workout type"),
        NSLocalizedString("Strength", comment: "Strength workout type"),
        NSLocalizedString("HIIT", comment: "HIIT workout type"),
        NSLocalizedString("Yoga", comment: "Yoga workout type")
    ]
    
    let weekdays = Calendar.current.weekdaySymbols
    
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
                        let workout = Workout(name: name, date: date, steps: steps, sets: sets, duration: duration, rest: rest, type: type, repeatDays: selectedDays, notes: notes)
                        context.insert(workout)
                        print("Workout added: \(workout.name)")
                        dismiss()
                    }
                    .disabled(name.isEmpty || duration == 0.0 || rest == 0.0 || selectedDays.isEmpty)
                }
            }
        }
    }
}

