import Foundation
import SwiftData
import SwiftUI

// --- MEDICATION UNIT ENUM ---
enum MedicationUnit: String, CaseIterable, Codable {
    case mg
    case ml
    
    var displayName: String {
        switch self {
        case .mg: return "mg"
        case .ml: return "ml"
        }
    }
}

// --- TIME OF DAY ENUM ---
enum TimeOfDay: String, CaseIterable, Codable {
    case morning
    case afternoon
    case evening
    case night
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        case .night:     return "Night"
        }
    }
    
    var titleString: String {
        switch self {
        case .morning:   return String(localized: "Morning")
        case .afternoon: return String(localized: "Afternoon")
        case .evening:   return String(localized: "Evening")
        case .night:     return String(localized: "Night")
        }
    }
    
    var icon: String {
        switch self {
        case .morning:   return "sun.max.fill"
        case .afternoon: return "sun.min.fill"
        case .evening:   return "sunset.fill"
        case .night:     return "moon.fill"
        }
    }
    
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
    var amount: Int
    var unit: MedicationUnit
    var timeOfDay: TimeOfDay?
    var dosageTimes: [TimeOfDay]
    var timestamp: Date

    init(name: String, dosage: Int, amount: Int = 0, unit: MedicationUnit = .mg, timeOfDay: TimeOfDay? = nil, dosageTimes: [TimeOfDay] = []) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.amount = amount
        self.unit = unit
        self.timeOfDay = timeOfDay
        self.dosageTimes = dosageTimes
        self.timestamp = Date()
    }
}
