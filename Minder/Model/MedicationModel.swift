import Foundation
import SwiftData

struct Medication {
    var name: String
    var dosage: Int
    var timeOfDay: TimeOfDay?
    
    enum TimeOfDay {
        case morning
        case night
    }
    
    var isValid: Bool {
        !name.isEmpty && dosage > 0 && timeOfDay != nil
    }
}
