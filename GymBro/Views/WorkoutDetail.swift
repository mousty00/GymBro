import SwiftUI
import UserNotifications
import AVFoundation

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
    @State private var player: AVAudioPlayer?
    @State private var isPlayingSound: Bool = false
    @State private var isMuted: Bool = false

    
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
                    
                    HStack {
                        Spacer()
                        Button {
                            isMuted.toggle()
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.circle.fill" : "speaker.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
                .padding()
                
                // Splash screen at the end of the workout
                if showCompletionScreen {
                    WorkoutDone(name: workout.name)
                }
            }
            .onAppear {
                startBackgroundTask()
                configureAudioSession()
            }
            .onDisappear {
                stopBackgroundTask()
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
                
                if timeRemaining < 0 {
                    timeRemaining = 0
                }
                
                if timeRemaining <= 3 && !self.isPlayingSound {
                    if !isMuted {
                        playSound()
                        self.isPlayingSound = true
                    }
                }
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
        isPlayingSound = false
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
    
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        })
    }

    func stopBackgroundTask() {
        if backgroundTaskID != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
    
    private func playSound() {
        let soundName: String = "countdown.mp3"
        
        
            if let url = Bundle.main.url(forResource: soundName, withExtension: nil) {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.play()
                } catch {
                    print("Error playing sound: \(error)")
                }
            } else {
                print("Sound file not found!")
            }
    }
    
    private func sendNotification() {
            let content = UNMutableNotificationContent()
            content.title = "\(workout.name) " + NSLocalizedString("Done", comment: "")
            content.body = NSLocalizedString("Great job! Keep pushing your limits!", comment: "")
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    
    private func finishWorkout() {
        stopTimer()
        isStarted = false
        sendNotification()
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

