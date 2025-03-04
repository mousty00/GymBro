import SwiftUI

struct WorkoutDetail: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let workout: Workout
    @State private var isStarted: Bool = false
    @State private var progress: Double = 1.0
    @State private var timeRemaining: Double
    @State private var timer: Timer? = nil
    @State private var isResting: Bool = false
    @State private var currentPhase: String = "Workout"
    @State private var setsRemaining: Int
    @State private var showCompletionScreen: Bool = false

    init(workout: Workout) {
        self.workout = workout
        _timeRemaining = State(initialValue: workout.duration * 60)
        _setsRemaining = State(initialValue: workout.sets)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 10){
                            Text(workout.name)
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text("Type:  \(workout.type)")
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                        }
                        Spacer()
                        Image(systemName: {
                            switch workout.type.lowercased() {
                            case "yoga":
                                return "figure.yoga"
                            case "strength":
                                return "figure.strengthtraining.traditional"
                            case "cardio":
                                return "figure.run"
                            case "hiit":
                                return "bolt.fill"
                            default:
                                return "dumbbell"
                            }
                        }())
                        .resizable()
                        .frame(width: 40, height: 40)
                    }
                    .padding()
                    
                    VStack(alignment: .center, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                let minutes = floor(timeRemaining / 60)
                                let seconds = timeRemaining.truncatingRemainder(dividingBy: 60)
                                let displaySeconds = seconds >= 59.5 ? 59 : seconds

                                Text(String(format: "%.0f:%02.0f", minutes, displaySeconds))
                                    .font(.system(size: 50))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                                Text(currentPhase == "Rest" ? "Rest" : "Workout")
                                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                            }
                            
                            Spacer()
                            
                            Button {
                                isStarted.toggle()
                                if isStarted {
                                    startTimer()
                                } else {
                                    stopTimer()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .trim(from: 0.0, to: progress)
                                        .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                                        .foregroundColor(currentPhase == "Workout" ? (isStarted ? .orange : .green) : .red)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1), value: progress)
                                    
                                    Image(systemName: isStarted ? "pause" : "play.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .foregroundStyle(currentPhase == "Workout" ? (isStarted ? .orange : .green) : .red)
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                        .padding()
                    }
                    
                    Button {
                        skipPhase()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center) {
                        VStack(alignment: .center){
                            Text("\(workout.steps)")
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text("reps")
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                        Text("X")
                        VStack(alignment: .center){
                            Text("\(setsRemaining)")
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text("sets")
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding()
                
                // Splash screen at the end of the workout
                if showCompletionScreen {
                    VStack {
                        Text("\(workout.name) Done!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("Great job! Keep pushing your limits!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Continue")
                                .bold()
                                .padding()
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
                    .foregroundColor(.white)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                }
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
                let totalDuration = isResting ? workout.rest * 60 : workout.duration * 60
                progress = timeRemaining / totalDuration
            } else {
                nextPhase()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func nextPhase() {
        if currentPhase == "Workout" {
            startRestTimer()
        } else {
            completeSet()
        }
    }
    
    private func startWorkoutTimer() {
        currentPhase = "Workout"
        isResting = false
        timeRemaining = workout.duration * 60
        progress = 1.0
        startTimer()
    }
    
    private func startRestTimer() {
        currentPhase = "Rest"
        isResting = true
        timeRemaining = workout.rest * 60
        progress = 1.0
        startTimer()
    }
    
    private func completeSet() {
        stopTimer()
        if setsRemaining > 1 {
            setsRemaining -= 1
            startWorkoutTimer()
        } else {
            finishWorkout()
        }
    }
    
    private func deleteWorkout() {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date()) - 1

        if let index = workout.repeatDays.firstIndex(of: todayWeekday) {
            workout.repeatDays.remove(at: index)
            if workout.repeatDays.isEmpty {
                if let context = workout.modelContext {
                    context.delete(workout)
                }
            }
        }
    }
    
    private func finishWorkout() {
        stopTimer()
        isStarted = false
        deleteWorkout()
        showCompletionScreen = true
    }

    private func skipPhase() {
        stopTimer()
        if currentPhase == "Workout" {
            startRestTimer()
        } else {
            completeSet()
        }
    }
}

#Preview {
    let fakeWorkout = Workout(name: "Leg Press", date: Date(), steps: 10, sets: 3, duration: 0.5, rest: 0.4, type: "Strength", repeatDays: [1, 2, 3])
    
    return WorkoutDetail(workout: fakeWorkout)
}

