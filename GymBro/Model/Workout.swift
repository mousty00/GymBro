import SwiftData
import Foundation

@Model
class Workout {
    var id: UUID
    var name: String
    var date: Date
    var steps: Int
    var sets: Int
    var duration: Double
    var rest: Double
    var type: String
    var repeatDays: [Int]
    
    init(name: String, date: Date, steps: Int, sets: Int, duration: Double, rest: Double, type: String, repeatDays: [Int]) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.steps = steps
        self.sets = sets
        self.duration = duration
        self.rest = rest
        self.type = type
        self.repeatDays = repeatDays
    }
    
}

