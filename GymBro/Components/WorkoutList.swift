import SwiftUI
import SwiftData

struct WorkoutList: View {
    
    @Environment(\.modelContext) private var context
    @State private var isShowingItemSheet = false
    @State private var selectedDate: Date = .now
    
    @Query(sort: \Workout.date, order: .reverse) private var allWorkouts: [Workout]

    var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate) - 1

        return allWorkouts.filter { workout in
            return workout.repeatDays.contains(selectedWeekday)
        }
    }

    var body: some View {
        NavigationStack {
            WeeklyCalendar(selectedDate: $selectedDate)
                .padding(.vertical, 15)
            
            List {
                ForEach(filteredWorkouts) { workout in
                    WorkoutCell(workout: workout)
                        .swipeActions(edge: .leading) {
                            NavigationLink(destination: EditWorkout(workout: workout)) {
                                Button {
                                } label: {
                                    Label(NSLocalizedString("Edit", comment: ""), systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                }
                .onDelete(perform: deleteWorkout)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(NSLocalizedString("Workouts", comment: ""))
                        .font(.largeTitle)
                        .bold()
                        .padding()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingItemSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .overlay {
                if filteredWorkouts.isEmpty {
                    ContentUnavailableView(label: {
                        Label(NSLocalizedString("No Workouts", comment: ""), systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text(NSLocalizedString("Start adding workouts to see your list.", comment: ""))
                    }, actions: {
                        Button(NSLocalizedString("Add Workout", comment: "")) {
                            isShowingItemSheet.toggle()
                        }
                        .foregroundStyle(.blue)
                    })
                }
            }
        }
        .sheet(isPresented: $isShowingItemSheet) {
            CreateWorkout()
                .presentationDetents([.large])
        }
        
        Button(NSLocalizedString("Delete All Workouts", comment: "")) {
            deleteAllWorkouts()
        }
        .padding()
        .foregroundStyle(.red)
    }

    private func deleteWorkout(at offsets: IndexSet) {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: selectedDate) - 1

        for index in offsets {
            let workout = filteredWorkouts[index]

            if let dayIndex = workout.repeatDays.firstIndex(of: selectedWeekday) {
                workout.repeatDays.remove(at: dayIndex)
            }

            if workout.repeatDays.isEmpty {
                context.delete(workout)
            }
        }
    }

    private func deleteAllWorkouts() {
        for workout in filteredWorkouts {
            context.delete(workout)
        }
    }
}

#Preview {
    WorkoutList()
}

