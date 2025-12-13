import Foundation
import SwiftData

@Model
final class MedicationLog {
    var id: UUID
    var medicationName: String
    var medicationId: UUID
    var timeOfDay: TimeOfDay
    var doseIndex: Int
    var amount: Int
    var unit: MedicationUnit
    var wasTaken: Bool
    var date: Date
    
    init(medicationName: String, medicationId: UUID, timeOfDay: TimeOfDay, doseIndex: Int = 0, amount: Int = 0, unit: MedicationUnit = .mg, wasTaken: Bool, date: Date = Date()) {
        self.id = UUID()
        self.medicationName = medicationName
        self.medicationId = medicationId
        self.timeOfDay = timeOfDay
        self.doseIndex = doseIndex
        self.amount = amount
        self.unit = unit
        self.wasTaken = wasTaken
        self.date = Calendar.current.startOfDay(for: date)
    }
}
