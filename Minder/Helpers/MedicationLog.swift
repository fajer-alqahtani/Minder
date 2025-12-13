import Foundation
import SwiftData

@Model
final class MedicationLog {
    var id: UUID
    var medicationName: String
    var medicationId: UUID
    var timeOfDay: TimeOfDay
    var doseIndex: Int  // Which dose this is (0, 1, 2, etc.)
    var wasTaken: Bool
    var date: Date
    
    init(medicationName: String, medicationId: UUID, timeOfDay: TimeOfDay, doseIndex: Int = 0, wasTaken: Bool, date: Date = Date()) {
        self.id = UUID()
        self.medicationName = medicationName
        self.medicationId = medicationId
        self.timeOfDay = timeOfDay
        self.doseIndex = doseIndex
        self.wasTaken = wasTaken
        self.date = Calendar.current.startOfDay(for: date)
    }
}
