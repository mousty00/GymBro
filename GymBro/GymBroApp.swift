import SwiftUI
import SwiftData
import UserNotifications
import CoreLocation

@main
struct GymBroApp: App {
    let container: ModelContainer
    @StateObject private var locationManager = LocationManager()

    init() {
        do {
            let schema = Schema([ModelWorkout.self])
            self.container = try ModelContainer(for: schema, configurations: [])
        } catch {
            fatalError("Failed to load the model container: \(error)")
        }
        requestNotificationPermissions()
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(locationManager)
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
