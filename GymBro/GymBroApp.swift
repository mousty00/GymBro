import SwiftUI
import SwiftData
import UserNotifications

@main
struct GymBroApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([Workout.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    init() {
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        .modelContainer(container)
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Authorization Granted")
            } else {
                print("Authorization Refused")
            }
        }
    }
    
    
}

