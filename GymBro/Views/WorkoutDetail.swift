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
    @State private var currentPhase: String = NSLocalizedString("Workout", comment: "Workout phase")
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
                            Text(NSLocalizedString("Type", comment: "Workout type") + ": \(workout.type)")
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
                                Text(currentPhase)
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
                                        .foregroundColor(currentPhase == NSLocalizedString("Workout", comment: "Workout phase") ? (isStarted ? .orange : .green) : .red)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1), value: progress)
                                    
                                    Image(systemName: isStarted ? "pause" : "play.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .foregroundStyle(currentPhase == NSLocalizedString("Workout", comment: "Workout phase") ? (isStarted ? .orange : .green) : .red)
                                }
                            }
                            .frame(width: 100, height: 100)
                        }
                        .padding()
                    }
                    
                    Button {
                        skipPhase()
                    } label: {
                        Text(NSLocalizedString("Skip", comment: "Skip phase"))
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
                            Text(NSLocalizedString("Reps", comment: "Repetitions"))
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        }
                        Text("X")
                        VStack(alignment: .center){
                            Text("\(setsRemaining)")
                                .fontWeight(.semibold)
                                .font(.system(size: 40))
                            Text(NSLocalizedString("Sets", comment: "Workout sets"))
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
                        Text("\(workout.name) " + NSLocalizedString("Done", comment: "Workout completed"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text(NSLocalizedString("Great job! Keep pushing your limits!", comment: "Encouragement message"))
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text(NSLocalizedString("Continue", comment: "Continue button"))
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
        if currentPhase == NSLocalizedString("Workout", comment: "Workout phase") {
            startRestTimer()
        } else {
            completeSet()
        }
    }
    
    private func startWorkoutTimer() {
        currentPhase = NSLocalizedString("Workout", comment: "Workout phase")
        isResting = false
        timeRemaining = workout.duration * 60
        progress = 1.0
        startTimer()
    }
    
    private func startRestTimer() {
        currentPhase = NSLocalizedString("Rest", comment: "Rest phase")
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
    
    private func finishWorkout() {
        stopTimer()
        isStarted = false
        showCompletionScreen = true
    }

    private func skipPhase() {
        stopTimer()
        if currentPhase == NSLocalizedString("Workout", comment: "Workout phase") {
            startRestTimer()
        } else {
            completeSet()
        }
    }
}

