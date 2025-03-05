import SwiftUI

struct WorkoutCell: View {
    let workout: ModelWorkout
    let weekdays = Calendar.current.weekdaySymbols
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                NavigationLink(destination: WorkoutDetail(workout: workout)){
                    VStack(alignment: .leading, spacing: 10){
                        Text(workout.name)
                            .font(.headline)
                        
                        Text(workout.type)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Display the workout date
                        Text(NSLocalizedString("Date", comment: "Workout date") + ":  \(formattedDate())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workout.date)
    }
}

