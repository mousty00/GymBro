import SwiftUI
import SwiftData

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
        print("Selected Weekday: \(calendar.weekdaySymbols[selectedWeekday])")

                return allWorkouts.filter { workout in
                    print("Workout: \(workout.name) - Repeat Days: \(workout.repeatDays)")
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
                            NavigationLink(destination: EditWorkout(workout: workout)){
                                Button { } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                                
                            }
                        }
                }
                .onDelete(perform: deleteWorkout)
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Workouts")
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
                        Label("No Workouts", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start adding workouts to see your list.")
                    }, actions: {
                        Button("Add Workout") {
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
        
        Button("Delete All Workouts") {
            deleteAllWorkouts()
        }
        .padding()
        .foregroundStyle(.red)
        
    }

    private func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredWorkouts[index])
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

