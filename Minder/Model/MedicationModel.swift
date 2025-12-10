import Foundation
import SwiftData
import SwiftUI

// --- THE DATA ENUM ---
enum TimeOfDay: String, CaseIterable, Codable {
    case morning
    case night
    
    /// For SwiftUI Text – use in Text(...)
    var titleKey: LocalizedStringKey {
        switch self {
        case .morning: return "Morning"
        case .night:   return "Night"
        }
    }
    
    /// For String(format: ...) and alerts – real localized String
    var titleString: String {
        switch self {
        case .morning:
            return String(localized: "Morning")
        case .night:
            return String(localized: "Night")
        }
    }
}




// --- THE SWIFTDATA MODEL ---
@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: Int
    var timeOfDay: TimeOfDay?  // For single dose (dosage = 1)
    var dosageTimes: [TimeOfDay]  // For multiple doses (dosage >= 2)
    var timestamp: Date

    init(name: String, dosage: Int, timeOfDay: TimeOfDay? = nil, dosageTimes: [TimeOfDay] = []) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.timeOfDay = timeOfDay
        self.dosageTimes = dosageTimes
        self.timestamp = Date()
    }
}
