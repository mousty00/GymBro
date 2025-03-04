
import SwiftUI
import SwiftData

@main
struct GymBroApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([Workout.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        .modelContainer(container)
    }
}
