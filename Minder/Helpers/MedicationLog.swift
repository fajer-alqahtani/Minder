//
//  MedicationLog.swift
//  Minder
//
//  Created by Areeg Altaiyah on 09/12/2025.
//


import Foundation
import SwiftData

@Model
final class MedicationLog {
    var id: UUID
    var medicationName: String
    var medicationId: UUID  // Reference to original medication
    var timeOfDay: TimeOfDay
    var wasTaken: Bool  // Whether it was checked or not
    var date: Date  // Which day this log is for
    
    init(medicationName: String, medicationId: UUID, timeOfDay: TimeOfDay, wasTaken: Bool, date: Date = Date()) {
        self.id = UUID()
        self.medicationName = medicationName
        self.medicationId = medicationId
        self.timeOfDay = timeOfDay
        self.wasTaken = wasTaken
        self.date = Calendar.current.startOfDay(for: date)  // Normalize to start of day
    }
}