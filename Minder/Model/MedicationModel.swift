import Foundation
import SwiftData
import SwiftUI

// --- THE DATA ENUM ---
enum TimeOfDay: String, CaseIterable, Codable {
    case morning
    case night
    
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .morning: return "Morning"
        case .night:   return "Night"
        }
    }
}


// --- THE SWIFTDATA MODEL ---
@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: Int
    var timeOfDay: TimeOfDay?
    var timestamp: Date

    init(name: String, dosage: Int, timeOfDay: TimeOfDay? = nil) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.timeOfDay = timeOfDay
        self.timestamp = Date()

    }
}
