import SwiftUI
import SwiftData

struct WorkoutList: View {
    
    @Environment(\.modelContext) private var context
    @State private var isShowingItemSheet = false
    @State private var selectedDate: Date = .now
    @State private var showToast: Bool = false
    @State private var showDeleteDayAlert = false
    @State private var showDeleteAllAlert = false
    @State private var showDeleteSingleAlert = false
    @State private var workoutToDelete: ModelWorkout? = nil
    @State private var isDeleteConfirmed = false
    
    @Query(sort: \ModelWorkout.date, order: .reverse) private var allWorkouts: [ModelWorkout]

    var filteredWorkouts: [ModelWorkout] {
        return allWorkouts.filter { workout in
            let calendar = Calendar.current
            let workoutDate = workout.date
            return calendar.isDate(workoutDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                YearlyCalendar(selectedDate: $selectedDate)
                    .padding(.vertical, 15)
                
                if filteredWorkouts.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label(NSLocalizedString("No Workouts", comment: ""), systemImage: "list.bullet.rectangle.portrait")
                        },
                        description: {
                            Text(NSLocalizedString("Start adding workouts to see your list.", comment: ""))
                        },
                        actions: {
                            Button(NSLocalizedString("Add Workout", comment: "")) {
                                isShowingItemSheet.toggle()
                            }
                            .foregroundStyle(.blue)
                        }
                    )
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCell(workout: workout)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        workoutToDelete = workout
                                        showDeleteSingleAlert.toggle()
                                    } label: {
                                        Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                                    }
                                    .tint(.red)
                                    
                                    Button {
                                        deleteAllWorkouts(withName: workout.name)
                                    } label: {
                                        Label(NSLocalizedString("Delete All", comment: ""), systemImage: "trash.fill")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    
                    Button(NSLocalizedString("Delete All Workouts for this day", comment: "")) {
                        showDeleteDayAlert.toggle()
                    }
                    .padding(.bottom, 10)
                    .foregroundStyle(.red)
                    
                    if showToast {
                        Toast(message: NSLocalizedString("Workout Deleted", comment: ""), status: "info")
                    }
                }
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
            .sheet(isPresented: $isShowingItemSheet) {
                CreateWorkout(selectedDate: $selectedDate)
                    .presentationDetents([.large])
            }
            .alert(isPresented: $showDeleteDayAlert) {
                Alert(
                    title: Text(NSLocalizedString("Are you sure?", comment: "")),
                    message: Text(NSLocalizedString("This action will delete all workouts for the selected date.", comment: "")),
                    primaryButton: .destructive(Text(NSLocalizedString("Delete", comment: ""))) {
                        isDeleteConfirmed = true
                        deleteAllWorkouts()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showDeleteAllAlert) {
                Alert(
                    title: Text(NSLocalizedString("Are you sure?", comment: "")),
                    message: Text(NSLocalizedString("This action will delete all workouts", comment: "")),
                    primaryButton: .destructive(Text(NSLocalizedString("Delete", comment: ""))) {
                        isDeleteConfirmed = true
                        deleteAllWorkouts(withName: workoutToDelete?.name ?? "")
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showDeleteSingleAlert) {
                Alert(
                    title: Text(NSLocalizedString("Are you sure?", comment: "")),
                    message: Text(NSLocalizedString("This action will delete the selected workout.", comment: "")),
                    primaryButton: .destructive(Text(NSLocalizedString("Delete", comment: ""))) {
                        if let workout = workoutToDelete {
                            deleteWorkout(workout)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func viewToast() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }

    private func deleteWorkout(_ workout: ModelWorkout) {
        context.delete(workout)
        try? context.save()
        viewToast()
    }

    private func deleteAllWorkouts(withName name: String) {
        let workoutsToDelete = allWorkouts.filter { $0.name == name }
        for workout in workoutsToDelete {
            context.delete(workout)
        }
        try? context.save()
        viewToast()
    }

    private func deleteAllWorkouts() {
        if isDeleteConfirmed {
            for workout in filteredWorkouts {
                context.delete(workout)
            }
            try? context.save()
            viewToast()
            isDeleteConfirmed = false
        }
    }
}
