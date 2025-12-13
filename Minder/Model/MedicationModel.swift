import Foundation
import SwiftData
import SwiftUI

// --- THE DATA ENUM ---
enum TimeOfDay: String, CaseIterable, Codable {
    case morning
    case afternoon
    case evening
    case night
    
    /// For SwiftUI Text – use in Text(...)
    var titleKey: LocalizedStringKey {
        switch self {
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        case .night:     return "Night"
        }
    }
    
    /// For String(format: ...) and alerts – real localized String
    var titleString: String {
        switch self {
        case .morning:   return String(localized: "Morning")
        case .afternoon: return String(localized: "Afternoon")
        case .evening:   return String(localized: "Evening")
        case .night:     return String(localized: "Night")
        }
    }
    
    /// Icon for each time of day
    var icon: String {
        switch self {
        case .morning:   return "sun.max.fill"
        case .afternoon: return "sun.min.fill"
        case .evening:   return "sunset.fill"
        case .night:     return "moon.fill"
        }
    }
    
    /// Color for each time of day
    var color: Color {
        switch self {
        case .morning:   return .yellow
        case .afternoon: return .orange
        case .evening:   return .pink
        case .night:     return .indigo
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
