import SwiftData
import Foundation

@Model
class ModelWorkout {
    var id: UUID
    var name: String
    var date: Date
    var steps: Int
    var sets: Int
    var duration: Int
    var rest: Int
    var type: String
    var notes: String?
    var lastCompletionDate: Date?
    
    var completedDays: String
    
    init(name: String, date: Date, steps: Int, sets: Int, duration: Int, rest: Int, type: String, notes: String?, completedDays: Set<Int> = []) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.steps = steps
        self.sets = sets
        self.duration = duration
        self.rest = rest
        self.type = type
        self.notes = notes
        self.lastCompletionDate = nil
        self.completedDays = completedDays.map { String($0) }.joined(separator: ",")
    }
    
    func getCompletedDays() -> Set<Int> {
        let daysArray = completedDays.split(separator: ",").compactMap { Int($0) }
        return Set(daysArray)
    }
}


