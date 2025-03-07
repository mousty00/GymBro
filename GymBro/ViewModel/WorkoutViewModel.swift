import SwiftUI
import Combine
import AVFoundation
import UserNotifications
import BackgroundTasks

class WorkoutViewModel: ObservableObject {
    
    @Published var timeRemaining: Int
    @Published var progress: Double = 1.0
    @Published var currentPhase: String
    @Published var isStarted: Bool = false
    @Published var setsRemaining: Int
    @Published var showCompletionScreen: Bool = false
    @Published var isMuted: Bool = true
    @Published var isWorkoutCompletedToday: Bool = false
    
    private var timer: AnyCancellable?
    private var player: AVAudioPlayer?
    private var isResting: Bool = false
    var workout: ModelWorkout
    
    init(workout: ModelWorkout) {
        self.workout = workout
        self.timeRemaining = workout.duration
        self.setsRemaining = workout.sets
        self.currentPhase = NSLocalizedString("Workout", comment: "Workout phase")
        self.isWorkoutCompletedToday = checkIfWorkoutCompletedToday()
    }
    
    var isWorkoutToday: Bool {
        return Calendar.current.isDateInToday(workout.date)
    }
    
    func startTimer() {
        let totalDuration = isResting ? workout.rest : workout.duration
        progress = 1.0
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    self.progress = Double(self.timeRemaining) / Double(totalDuration)
                } else {
                    self.nextPhase()
                }
            }
    }
    
    func stopTimer() {
        timer?.cancel()
    }
    
    func nextPhase() {
        self.playSound()
        if currentPhase == NSLocalizedString("Workout", comment: "Workout phase") {
            startRestTimer()
        } else {
            completeSet()
        }
    }
    
    func startWorkoutTimer() {
        currentPhase = NSLocalizedString("Workout", comment: "Workout phase")
        isResting = false
        timeRemaining = workout.duration
        progress = 1.0
        startTimer()
        // Setup background task for timer
        startBackgroundTask()
    }
    
    func startRestTimer() {
        currentPhase = NSLocalizedString("Rest", comment: "Rest phase")
        isResting = true
        timeRemaining = workout.rest
        progress = 1.0
        startTimer()
        // Setup background task for timer
        startBackgroundTask()
    }
    
    func completeSet() {
        stopTimer()
        if setsRemaining > 1 {
            setsRemaining -= 1
            startWorkoutTimer()
        } else {
            finishWorkout()
        }
    }
    
    func finishWorkout() {
        stopTimer()
        isStarted = false
        sendNotification(title: "\(workout.name) \(NSLocalizedString("Done", comment: ""))", body: NSLocalizedString("Great job! Keep pushing your limits!", comment: ""))
        isWorkoutCompletedToday = true
        workout.lastCompletionDate = Date()
        showCompletionScreen = true
    }
    
    func skipPhase() {
        stopTimer()
        if currentPhase == NSLocalizedString("Workout", comment: "Workout phase") {
            startRestTimer()
        } else {
            completeSet()
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    func playSound() {
        let soundName: String = "sound.mp3"
        
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
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func checkIfWorkoutCompletedToday() -> Bool {
        guard let lastCompletionDate = workout.lastCompletionDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastCompletionDate)
    }
    
    func startBackgroundTask() {
        _ = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundTask()
        })
        
        DispatchQueue.global().asyncAfter(deadline: .now() + Double(timeRemaining)) {
            self.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(UIApplication.shared.beginBackgroundTask(expirationHandler: nil))
    }
}

