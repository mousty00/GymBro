
import SwiftUI
import Combine
import AVFoundation
import UserNotifications

class WorkoutViewModel: ObservableObject {
    
    @Published var timeRemaining: Int
    @Published var progress: Double = 1.0
    @Published var currentPhase: String
    @Published var isStarted: Bool = false
    @Published var setsRemaining: Int
    @Published var showCompletionScreen: Bool = false
    @Published var isMuted: Bool = false
    
    private var timer: AnyCancellable?
    private var player: AVAudioPlayer?
    private var isResting: Bool = false
    var workout: Workout
    
    init(workout: Workout) {
        self.workout = workout
        self.timeRemaining = workout.duration
        self.setsRemaining = workout.sets
        self.currentPhase = NSLocalizedString("Workout", comment: "Workout phase")
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
                    
                    if self.timeRemaining <= 4 && !self.isMuted {
                        self.playSound()
                    }
                } else {
                    self.nextPhase()
                }
            }
    }

    
    func stopTimer() {
        timer?.cancel()
    }
    
    func nextPhase() {
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
    }
    
    func startRestTimer() {
        currentPhase = NSLocalizedString("Rest", comment: "Rest phase")
        isResting = true
        timeRemaining = workout.rest
        progress = 1.0
        startTimer()
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
        sendNotification()
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
    
    func sendNotification() {
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
    
    func playSound() {
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
    
    func toggleMute() {
        isMuted.toggle()
    }
}
